#!/bin/bash

# Check if argument is received
if [ -z "$1" ]
  then
    echo "No argument supplied. Please provide the full path to the Lambda project"
		echo "Example: "
		echo "$ ./create-lambda-package.sh /home/vagrant/code/aws-serverless/aws-poc-serverless-python-app"
		exit 1
fi
__project_dir=$1

# This script creates a Zip package of the Lambda source files
__script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__script_dir}/common-variables.sh

(
mkdir -p ${__project_dir}/${target_package_folder};
zip -jFS ${__project_dir}/${target_package_folder}/${zip_file} \
    ${__project_dir}/${lambda_folder}/${lambda_file};
ls ${__project_dir}/${target_package_folder}/${zip_file};
)