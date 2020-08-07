#! /bin/bash
# Build a package under src/ of the contents of src/ to be uploaded to Lambda.

if ! [ -d src/package ]
then
    mkdir src/package
fi

pip install --target ./src/package -r ../requirements.txt 2>/dev/null
cp src/get-vulns.py src/package
zip -r9 src/package.zip src/package

if [ -d src/package ]
then
    rm -rf src/package
fi