#!/bin/bash

# Check if argument is received
if [ -z "$1" ]
  then
    echo "No argument supplied. Please provide the full path to the Lambda project"
		echo "Example: "
		echo "$ ./build-package-deploy-lambda-mongo-data-api.sh /home/vagrant/code/aws-serverless/aws-poc-serverless-python-app"
		exit 1
fi
echo -n "Setting project directory... "
__project_dir=$1
echo "Done! Project directory: $__project_dir"

#Variables
echo -n "Setting script directory... "
__script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Done! Script directory: $__script_dir"
echo -n "Setting common variables ... "
source ${__script_dir}/common-variables.sh
echo "Done!"


#Create Zip file of your Lambda code (works on Windows and Linux)
echo -n "Creating ZIP file with lambda code... "
${__script_dir}/create-lambda-package.sh ${__project_dir}
if [ $? -eq 0 ]
then
  echo "Done!"
else
  echo "Could not create file" >&2
	exit 1
fi

#Package your Serverless Stack using SAM + Cloudformation
aws cloudformation package \
    --template-file ${__project_dir}/$template.yaml \
    --output-template-file ${__project_dir}/${target_package_folder}/$template-output.yaml \
    --s3-bucket $bucket \
    --s3-prefix $prefix \
    --region $region \
    --profile $profile

#Deploy your Serverless Stack using SAM + Cloudformation
aws cloudformation deploy \
    --template-file ${__project_dir}/${target_package_folder}/$template-output.yaml \
    --stack-name $template \
    --capabilities CAPABILITY_IAM \
    --region $region \
    --profile $profile \
    --parameter-overrides \
        AccountId=${aws_account_id} \
        LayerName=${layer_name} \
        LayerVersion=${layer_version} \
        PythonVersion=${python_version} 