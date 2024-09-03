#!/bin/sh

source docker/env_rpm_optimize_image.conf
set -eE

if [[ ${PGSPIDER_RPM_ID} ]]; then
    PGSPIDER_RPM_ID_POSTFIX="-${PGSPIDER_RPM_ID}"
    IMAGE_TAG=${PGSPIDER_RPM_ID}
else
    IMAGE_TAG="latest"
fi

# Push binary on repo
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then
    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${IMAGE_TAG} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg ACCESS_TOKEN=${ACCESS_TOKEN} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PACKAGE_RELEASE_VERSION=${PACKAGE_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_URL="${API_V4_URL}/projects/${PGSPIDER_PROJECT_ID}/packages/generic/rpm_rhel8/${PGSPIDER_BASE_POSTGRESQL_VERSION}" \
        --build-arg PGSPIDER_RPM_ID=${PGSPIDER_RPM_ID_POSTFIX} \
        -f docker/Dockerfile .
    
    docker push ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
    docker rmi ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
else
    IMAGE_TAG=${PGSPIDER_RELEASE_VERSION}

    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PACKAGE_RELEASE_VERSION=${PACKAGE_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_URL="https://github.com/$OWNER_GITHUB/$PGSPIDER_PROJECT_GITHUB/releases/download/$PGSPIDER_RELEASE_VERSION" \
        -f docker/Dockerfile .

    docker push ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG}
    docker rmi ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG}
fi
