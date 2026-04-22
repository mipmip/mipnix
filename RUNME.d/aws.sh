make_command "setup_aws_key" "bootstrap AWS configuration on new machine"
setup_aws_key(){
  mkdir -p ~/.aws
  chmod 700 ~/.aws

  if [ -f ~/.aws/credentials ]; then
    cp ~/.aws/credentials ~/.aws/credentials.bak
    chmod 600 ~/.aws/credentials.bak
  fi
  age --decrypt -i ~/.ssh/id_ed25519 ./secrets/aws-credentials-copy.age > ~/.aws/credentials
  chmod 600 ~/.aws/credentials

  if [ -f ~/.aws/config ]; then
    cp ~/.aws/config ~/.aws/config.bak
    chmod 600 ~/.aws/config.bak
  fi
  age --decrypt -i ~/.ssh/id_ed25519 ./secrets/aws-config-copy-first-time-only.age > ~/.aws/config
  chmod 600 ~/.aws/config

  copy_aws_other_accounts
  technativeawsupdate
}

make_command "txn_aws_update" "update AWS account info from technative"
txn_aws_update(){
  aws-mfa --profile technative --device arn:aws:iam::521402697040:mfa/pim@technative.nl
  aws --profile=technative-web_dns s3 cp s3://docs-mcs.technative.eu-longhorn/managed_service_accounts.json ~/.aws/
  echo "Don't forget to run home-manager again"
}

make_command "copy_aws_other_accounts" "copy AWS other accounts"
copy_aws_other_accounts(){
  age --decrypt -i ~/.ssh/id_ed25519 ./secrets/aws-accounts.json.age > ~/.aws/other_accounts.json
  chmod 600 ~/.aws/other_accounts.json
  echo "Don't forget to run home-manager again"

}
