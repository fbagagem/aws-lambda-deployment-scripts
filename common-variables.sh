#!/bin/bash

# Environment variables
# -------------------------------------------------------------------------------------
# Virtual environment package location
export packages_path=~/tmp/lambda_package/lib 
# Current bash root directory
export bash_dir=$(pwd) 

# Account variables
# -------------------------------------------------------------------------------------
# The profile under ~/.aws/config and ~/.aws/credentials files are configured
export profile="default"
# The region to which the code is deployed. TODO: try to find a way to automate this field through AWS CLI commands
export region="eu-west-1" 
# Fetch the Account identifier from AWS
export aws_account_id=$(aws sts get-caller-identity --query 'Account' --profile $profile | tr -d '\"')
# Name of the template to use; The Cloudformation YAML file in the project directory should also use this name: template.yaml
export template="template" 

# Application variables
# -------------------------------------------------------------------------------------
# Name of the S3 bucket where the code will be stored
export bucket="devenvironmentbucket"
# Path in the S3 bucket to the directory where the code will be stored
export prefix="lambda-layers" 
# Python version used by the project
export python_version="python3.6"
# Directory name where Python dependencies packages are stored (stage directory before zipping it into a single file). This directory is created inside the project root folder
export source_build_folder=build
# Directory name where project deliverables are stored (both layers and source code). This directory is created inside the project root folder
export target_package_folder=package

#Lambda variables
# -------------------------------------------------------------------------------------
# Relative path to the main handler python script (relative to the project root folder)
export lambda_folder=.
# Name of the main handler python script
export lambda_file="lambda_crud.py"
# Name of the zip file to be created with the code
export zip_file="lambda-crud.zip"

#Layers variables
# -------------------------------------------------------------------------------------
# Name of the zip file to be created with the layer code
export layers_zip_file="lambda-flask-mongo-layer.zip"
# Relative path to the directory where all dependency packages are located
export target_layer_path=${source_build_folder}/python/lib/${python_version}/site-packages
# Name of the layer
export layer_name="flask-mongo"
# Version of the layer
export layer_version=9
