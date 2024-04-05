#!/bin/sh
set -e

# Read the environment 
ENV=$1
AWS_PROFILE=$2

export AWS_PROFILE=$AWS_PROFILE
VERSION=$(git rev-parse --short HEAD)

echo deploying $ENV using $AWS_PROFILE

terraform init
terraform workspace select -or-create $ENV

terraform apply -var="env=$ENV"