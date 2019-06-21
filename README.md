# AWS Lambda deployment scripts

Set of scripts that aims to help and automatize deployemnt actions of AWS Lambda functions and its dependencies in AWS cloud.

**Note**: So far, these scripts are highly coupled to Python scripting language, and was not tested with any other language (NodeJS, Java, etc). Nevertheless, it is very likely it will **not work** with any other language but Python.

These scripts are splitted into two main operations, as follows:

- Create/Update a [Lambda Layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html)
- Create and deploy a lambda package to an AWS account

## Requirements

TODO: add the roles needed to be configured in AWS IAM user so it is allowed to do these actions

## Usage

First of all, we need to prepare the variables.
Open the file ``common-variables.sh`` and check every single line to adjust to your needs &rarr; special attention to the last block "Layers Variables".

Only then we are ready to move to create stuff.

### Layers

In order to create a layer, open the file ``create-layer.sh`` and edit the line 25 to list the packages to include in the layer:

```sh
declare -a packages_array=( ... )
```

Example:

```sh
declare -a packages_array=("flask" "flask_mongoengine" "bson" "awsgi" "werkzeug" "jinja2" "markupsafe" "itsdangerous" "click")
```

Then, execute the ``create-layer.sh`` script:

```console
foo@bar:aws-lambda-scripts$ ./create-layer.sh <full path to project root directory>
```

Example:

```console
foo@bar:aws-lambda-scripts$ ./create-layer.sh /home/vagrant/code/aws-serverless/aws-serverless-python-app
```

During the execution of the script, the shell will print a lot of stuff related to packages downloaded from the internet and zipping them into a zip file. In the end, it will display something like:

```json
...
upload: ../aws-poc-serverless-python-app/package/lambda-flask-mongo-layer.zip to s3://devenvironmentbucket/lambda-layers/lambda-flask-mongo-layer.zip
{
    "Content": {
        "Location": "https://awslambda-eu-west-1-layers.s3.eu-west-1.amazonaws.com/snapshots/933956199999/flask-mongo-377e7c96-3622-4fee-b2fd-1fbfc53bbd9d?versionId=JfJtpEPd4amQr2TJQHWSl.3PFnukLSFc&X-Amz-Security-Token=AgoJb3JpZ2luX2VjECAaCWV1LXdlc3QtMSJHMEUCIHmYBC%2FgNoxcWGPQoZjgpdCY3dYNJ2QV%2BxPxmJTAVVMZAiEAtz0VFMh1Ziz%2FOheJne9sx8WPNQBtrAiabUpOUGS4IiIq2gMISRABGgw5NTQzNjkwODI1MTEiDLJUJ7FCVncXbBqKVCq3AzVTe3AvvsxU4wguCrdIKyeIABq%2FO9fG7m5sOC0%2BY...6de4ed4e992e8134f422a0af8d16df023",
        "CodeSha256": "eebjpHTfHgYwZv2eRWjxgXvddWb4ryXlUxaaaaaaaaa=",
        "CodeSize": 676244
    },
    "LayerArn": "arn:aws:lambda:eu-west-1:933956199999:layer:flask-mongo",
    "LayerVersionArn": "arn:aws:lambda:eu-west-1:933956199999:layer:flask-mongo:10",
    "Description": "flask-mongo",
    "CreatedDate": "2019-06-07T16:34:52.822+0000",
    "Version": 10,
    "CompatibleRuntimes": [
        "python3.6"
    ],
    "LicenseInfo": "Apache-2.0"
}
```

Grab the "Version" value and go back to the ``common-variables.sh`` file to set the ``layer_version`` variable with it!

### Lambda package

Execute the ``build-package-deploy-lambda-mongo-data-api.sh`` script:

```console
foo@bar:aws-lambda-scripts$ ./build-package-deploy-lambda-mongo-data-api.sh <full path to project root directory>
```

Example:

```console
foo@bar:aws-lambda-scripts$ ./build-package-deploy-lambda-mongo-data-api.sh /home/vagrant/code/aws-serverless/aws-serverless-python-app
```
