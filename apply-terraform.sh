source ~/.ssh/aws-keys
terraform apply \
    -var "access_key=$accessKey" \
      -var "secret_key=$secretKey"
