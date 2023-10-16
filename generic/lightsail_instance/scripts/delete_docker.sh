#!/bin/bash
set -o xtrace



PROFILE=$1
shift
REGION=$1
shift
LIGHTSAIL_INSTANCE_NAME=$1
shift
APP_NAME=$1
shift
IP=$1


DOCKER_REPO_URL=$(echo $CONTAINER | cut -d ":" -f 1)
aws lightsail download-default-key-pair --profile $PROFILE --region $REGION --output text --query 'privateKeyBase64' > private_key
chmod 600 private_key
cat <<EOT > ssh_config
Host lightsail_instance
    HostName $IP
    User admin
    IdentityFile private_key
EOT

chmod 600 ssh_config
LOGIN=$(aws ecr get-login-password --profile=$PROFILE --region=$REGION)
ssh -o StrictHostKeyChecking=accept-new -F ssh_config lightsail_instance  "
docker stop $APP_NAME || true
docker rm $APP_NAME || true
"