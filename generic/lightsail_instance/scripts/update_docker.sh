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
CONTAINER=$1
shift
IP=$1
shift
PORT=$1
shift


ENVS=""
for env in "$@"
do
    ENVS="$ENVS -e $env"
done

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
echo "$LOGIN" | docker login --username AWS --password-stdin  $DOCKER_REPO_URL
docker pull $CONTAINER
docker stop $APP_NAME || true
docker rm $APP_NAME || true
docker run --name $APP_NAME --restart unless-stopped -m 7680m  -d -p 80:$PORT $ENVS $CONTAINER 
"