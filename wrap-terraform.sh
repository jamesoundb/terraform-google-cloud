source ~/.ssh/aws-keys
terraform $1 \
    -var "access_key=$accessKey" \
      -var "secret_key=$secretKey"
