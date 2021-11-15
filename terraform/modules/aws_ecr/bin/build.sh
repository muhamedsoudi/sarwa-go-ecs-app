#!/bin/bash

# Inspiration from https://github.com/onnimonni/terraform-ecr-docker-build-module
# This script is designed to:
# 1- login to ECR Repository
# 2- Build Docker Image
# 3- Tag and push the image to the repo.


# Fail fast
set -e

# This is the order of arguments
build_folder=$1
aws_ecr_repository_url=$2
region=$3
aws_account_no=$4

# Check that aws is installed
which aws > /dev/null || { echo 'ERROR: aws-cli is not installed' ; exit 1; }

# Connect into aws
aws_ecr_repo_name=${aws_ecr_repository_url#*/}
echo $aws_ecr_repo_name

aws ecr get-login-password \
    --region $region \
| docker login \
    --username AWS \
    --password-stdin $aws_account_no.dkr.ecr.$region.amazonaws.com

# Check that docker is installed and running
which docker > /dev/null && docker ps > /dev/null || { echo 'ERROR: docker is not running' ; exit 1; }

# Some Useful Debug
echo "Building $aws_ecr_repository_url from $build_folder Dockerfile"
# Build image
docker build -t $aws_ecr_repo_name $build_folder
echo "Taging Image With tag: latest"
# Tag image
docker tag $aws_ecr_repo_name:latest $aws_ecr_repository_url:latest
echo "Pushing Image.."
# Push image
docker push $aws_ecr_repository_url:latest
