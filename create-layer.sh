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

#Setup common environment variables
echo -n "Setting script directory... "
__script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Done! Script directory: $__script_dir"
echo -n "Setting common variables ... "
source ${__script_dir}/common-variables.sh
echo "Done!"

# Specify the dependent package folders
# Note that the names specified here may not be the same as detailed in requirements.txt
declare -a packages_array=("flask" "flask_mongoengine" "bson" "awsgi" "werkzeug" "jinja2" "markupsafe" "itsdangerous" "click")
# Extracts list from lambda-requirements.txt directly -> challenge is that package "dnspython" is called under "dns"
#declare -a packages_array=($(python extract_packages.py 2>&1))


: <<'END'
END

# Installs packages in virtualenv
sudo apt-get install python3-pip -y
sudo pip3 install virtualenv --upgrade
sudo pip3 install boto3 --upgrade

# Cleanup and re-install virtual environment
(sudo rm -r ${packages_path};
mkdir ~/tmp -p && cd ~/tmp;
sudo virtualenv -p "${python_version}" lambda_package \
		--distribute;
. ./lambda_package/bin/activate && python -V;
sudo pip3 install \
		--upgrade pip;
sudo pip3 install -r ${__project_dir}/${lambda_folder}/requirements.txt \
    -t ${packages_path}/${python_version}/site-packages/ \
		--upgrade \
    --no-binary \
		--no-compile \
		--disable-pip-version-check \
    --no-deps \
		--isolated;
ls ${packages_path}/${python_version}/site-packages;
deactivate;
)

#Delete old folders and create new folder structure
rm -r ${__project_dir}/${source_build_folder}
mkdir -p ${__project_dir}/${source_build_folder}
rm -r ${__project_dir}/${target_layer_path}
mkdir -p ${__project_dir}/${target_layer_path}

# Copy selected packages to new folder
for package in "${packages_array[@]}"
do
    echo "Copying $package to ${target_layer_path}"
    sudo rsync -av \
				--exclude="__pycache__" \
				--exclude="*tests/"  \
				${packages_path}/${python_version}/site-packages/${package} \
				${__project_dir}/${target_layer_path}
done

# Create Layers Zip archive
sudo apt-get install zip -y;
rm -r ${__project_dir}/${target_package_folder};
(mkdir -p ${__project_dir}/${target_package_folder};
cd ${__project_dir}/${source_build_folder};
zip -FSr ${__project_dir}/${target_package_folder}/"${layers_zip_file}" .;
ls -l ${__project_dir}/${target_package_folder}/"${layers_zip_file}";
)

# Push Zip archive to S3
aws s3 cp \
		${__project_dir}/${target_package_folder}/${layers_zip_file} \
		s3://${bucket}/${prefix}/${layers_zip_file} \
		--region ${region}

# Create new layer
aws lambda publish-layer-version \
    --layer-name ${layer_name} \
    --description "${layer_name}" \
    --license-info "Apache-2.0" \
    --content S3Bucket=${bucket},S3Key=${prefix}/${layers_zip_file} \
    --compatible-runtimes ${python_version} \
    --region ${region}
