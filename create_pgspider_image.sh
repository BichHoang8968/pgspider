#!/bin/sh

IMAGE_NAME=pgspider
DOCKERFILE=Dockerfile

PGSPIDER_BASE_POSTGRESQL_VERSION=16
PGSPIDER_RELEASE_VERSION=4.0.0
RPM_DISTRIBUTION_TYPE="rhel8"

set -eE

# User need to specified proxy and no_proxy as environment variable before executing
#   Example:
#       export proxy=http://username:password@proxy:port
#       export no_proxy=127.0.0.1,localhost
if [[ -z "${proxy}" ]]; then
  echo "proxy environment variable not set"
  exit 1
fi

if [[ -z "${no_proxy}" ]]; then
  echo "no_proxy environment variable not set"
  exit 1
fi

# Choose location to push PGSpider image
read -p "Location to push PGSpider image: " location 
if [[ $location != [gG][iI][tT][hH][uU][bB] && $location != [gG][iI][tT][lL][aA][bB] ]]; then
    echo "Please choose: [GITHUB], [GITLAB]"
    exit 1
fi

# Input necessary information
#   Project on a self-contained GitLab server: https://git.mycompany.com/department/db/PGSpider.git
#           "db" is group
#           "PGSpider" is project (no case sensitive)
#           -> PGSPIDER_REPO = db/pgspider
#   Public projects Github server: https://github.com/public-username/public-repo.git
#           -> PGSPIDER_REPO = public-username
read -p "Access Token: " ACCESS_TOKEN
read -p "ID of PGSPIDER RPM PACKAGES: " PGSPIDER_RPM_ID
read -p "PGSpider Group/Project: " PGSPIDER_REPO
read -p "PGSpider Container Registry: " PGSPIDER_CONTAINER_REGISTRY
read -p "Username for PGSpider Container Registry: " USERNAME_PGS_CONTAINER_REGISTRY
read -p "Password for PGSpider Container Registry: " PASSWORD_PGS_CONTAINER_REGISTRY

if [[ ${PGSPIDER_RPM_ID} ]]; then
    PGSPIDER_RPM_ID_POSTFIX="-${PGSPIDER_RPM_ID}"
fi

# Push binary on repo
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then 
    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${PGSPIDER_REPO}/${IMAGE_NAME}:${PGSPIDER_RPM_ID} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg ACCESS_TOKEN=${ACCESS_TOKEN} \
        --build-arg RPM_DISTRIBUTION_TYPE=${RPM_DISTRIBUTION_TYPE} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_ID=${PGSPIDER_RPM_ID_POSTFIX} .
else
    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${PGSPIDER_REPO}/${IMAGE_NAME}:${PGSPIDER_RPM_ID} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg RPM_DISTRIBUTION_TYPE=${RPM_DISTRIBUTION_TYPE} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_ID=${PGSPIDER_RPM_ID_POSTFIX} .
fi

docker push ${PGSPIDER_CONTAINER_REGISTRY}/${PGSPIDER_REPO}/${IMAGE_NAME}:${PGSPIDER_RPM_ID}

# Clean
docker rmi ${PGSPIDER_CONTAINER_REGISTRY}/${PGSPIDER_REPO}/${IMAGE_NAME}:${PGSPIDER_RPM_ID}
