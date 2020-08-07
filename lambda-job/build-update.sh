#! /bin/bash
# Build a package under src/ of the contents of src/ and the venv to be uploaded and invoked in Lambda.

if ! [ -d src/package ]
then
    mkdir src/package
fi

pip install --target ./src/package -r ../requirements.txt 2>/dev/null
cp src/get-vulns.py src/package
cd src/package || exit
zip -r9 ../package.zip .
cd - || exit

if [ -d src/package ]
then
    rm -rf src/package
fi
