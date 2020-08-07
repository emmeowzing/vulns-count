#! /usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Query an org. and return a list of unmonitored EC2 instances.
"""

from typing import Tuple, Dict, Any

from mohawk import Sender
from datadog import initialize as dd_initialize, api as dd_api
from botocore.exceptions import ClientError

import json
import requests
import boto3


class DataDogAPI:
    """
    Quick CM interface for Data Dog.
    """
    def __init__(self, api_key: str, app_key: str) -> None:
        # Set up the API connection.
        dd_initialize(api_key, app_key)

    def __enter__(self) -> 'DataDogAPI':
        return self

    def __exit__(self, *args: Any) -> None:
        pass

    def publishMetric(self, datum: int, metricName: str) -> None:
        """
        Publish a metric to DD for display as a metric in a dashboard.
        """
        dd_api.Metric.send(metric=metricName, points=datum)


def make_vulns_request(credentials: Dict[str, str], org_id: str, endpoint: str, content: str) -> Tuple[dict, int]:
    """
    Make a request on the vulnerabilities endpoint.

    Returns:
        A list of CVEs, followed by the total count, respecting pagination.
    """

    def _req(token: str ='') -> dict:
        nonlocal credentials, org_id, endpoint, content
        sender = Sender(
            credentials=credentials,
            url=endpoint + (content if not token else f'?token={token}'),
            method='GET',
            always_hash_content=False,
            content_type='application/json',
            ext=org_id
        )
        response = requests.get(
            endpoint + (content if not token else f'?token={token}'),
            headers={
                'Authorization': sender.request_header,
                'Content-Type': 'application/json'
            }
        )
        return response.json()

    _cves = _req()
    _token = _cves['token']
    while _token:
        data = _req(_token)
        _token = data['token']
        _cves['cves'].append(data['cves'])
    _cves['token'] = None
    return _cves, len(_cves['cves'])


def get_secret(client: Any, secret_name: str) -> str:
    """
    Get a secret from AWS Secrets manager.

    Args:
        client: the boto3 client instance with which to make the request.
        secret_name: name of the secret to retrieve.
        region: AWS region in which the secret is stored.

    Returns:
        The secrets as a JSON string.
    """

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
            return secret
        else:
            raise KeyError('secret was not retrieved successfully')


def entrypoint() -> None:
    """
    Entry point of my Lambda function.

    Returns:
        None.
    """
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name='us-east-2'
    )

    endpoint = 'https://api.threatstack.com/v2/vulnerabilities'

    # The agent IDs we'd like to monitor.
    agent_ids = {
        'ubuntu18': '1b2b713b-d8c5-11ea-b6f8-03a608d4baeb',
        'centos7': '4908c645-d8c5-11ea-b58a-03108fc8af85'
    }

    # Get my TS API credentials from my secrets manager.
    credentials = {
        'algorithm': 'sha256'
    }
    secret = get_secret(client, secret_name='brandon-org-creds')
    credentials.update(json.loads(secret))

    # My org. ID.
    org_id = '5d7bb7c49f4d069836a064c2'

    # Snag my DD API credentials from my secrets manager as well.
    dd_credentials = json.loads(get_secret(client, secret_name='datadog-app'))

    for instance in agent_ids:
        cves, count = make_vulns_request(credentials, org_id, endpoint, content='?status=active&agentId=' + agent_ids[instance])
        print(instance, count)
        with DataDogAPI(**dd_credentials) as dd_api:
            dd_api.publishMetric(datum=count, metricName=instance)


if __name__ == '__main__':
    entrypoint()
