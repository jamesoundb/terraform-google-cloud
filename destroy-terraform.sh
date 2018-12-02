source ~/.ssh/aws-keys
terraform destroy \
    -var "access_key=$accessKey" \
      -var "secret_key=$secretKey"
