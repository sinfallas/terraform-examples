#!/usr/bin/env bash
# Made by Sinfallas <sinfallas@yahoo.com>
# Licence: GPL-2
export HTTP_PROXY=http://192.168.1.21:3128
export HTTPS_PROXY=http://192.168.1.21:3128
export AWS_PAGER=""
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export TF_VAR_aws_region=$AWS_DEFAULT_REGION

clear
echo "Configurar AWSCLI"
configuraraws
echo "Inicializar terraform"
terraform init
echo "Validar los .TF"
terraform validate
echo "Aplicar los cambios"
terraform apply -auto-approve

echo "finalizado."
exit 0
