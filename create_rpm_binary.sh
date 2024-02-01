#!/bin/sh

IMAGE_TAG=pgspider_create_rpm
DOCKERFILE=Dockerfile_rpm
RPM_ARTIFACT_DIR=PGSpider_rpm

PGSPIDER_BASE_POSTGRESQL_VERSION=16
PGSPIDER_RELEASE_VERSION=4.0.0
RPM_DISTRIBUTION_TYPE="rhel8"

OWNER_GITHUB=pgspider
PGSPIDER_PROJECT_GITHUB=pgspider

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

# Choose location to push PGSpider RPM binaries
read -p "Location to push PGSpider RPM binaries: " location
if [[ $location != [gG][iI][tT][hH][uU][bB] && $location != [gG][iI][tT][lL][aA][bB] ]]; then
    echo "Please choose: [GITHUB], [GITLAB]"
    exit 1
fi

# Input necessary information
#   For Github API require RELEASE_ID. Example:
#        Public projects: https://github.com/public-username/public-repo.git
#           "public-username" is OWNER
#           "public-repo" is REPO
#           Release ID is system value. You can get it by command: curl https://api.github.com/repos/OWNER/REPO/releases/latest
read -p "Access Token: " ACCESS_TOKEN
if [[ $location == [gG][iI][tT][hH][uU][bB] ]]; then
    read -p "PGSpider Release ID: " PGSPIDER_RELEASE_ID
else
    read -p "PGSpider PROJECT ID: " PGSPIDER_PROJECT_ID
fi

# download postgres documentation
if [[ ! -f postgresql-16-A4.pdf ]]; then
    wget https://www.postgresql.org/files/documentation/pdf/16/postgresql-16-A4.pdf
fi

# Create Docker image for creating RPM file of PGSpider.
docker build -t $IMAGE_TAG \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg RPM_DISTRIBUTION_TYPE=${RPM_DISTRIBUTION_TYPE} \
        -f $DOCKERFILE .

# Get RPM file from container image.
rm -rf $RPM_ARTIFACT_DIR || true
mkdir -p $RPM_ARTIFACT_DIR
docker run --rm -v $(pwd)/$RPM_ARTIFACT_DIR:/tmp \
                -u "$(id -u $USER):$(id -g $USER)" \
                -e LOCAL_UID=$(id -u $USER) \
                -e LOCAL_GID=$(id -g $USER) $IMAGE_TAG /bin/sh \
                -c "cp /home/user1/rpmbuild/RPMS/x86_64/pgspider16*.rpm /tmp/"
rm -f $RPM_ARTIFACT_DIR/*-debuginfo-*.rpm

# Push rpm binary to registry
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then
    curl_command="curl --header \"PRIVATE-TOKEN: ${ACCESS_TOKEN}\" --insecure --upload-file"
    package_uri="https://tccloud2.toshiba.co.jp/swc/gitlab/api/v4/projects/${PGSPIDER_PROJECT_ID}/packages/generic/rpm_${RPM_DISTRIBUTION_TYPE}/${PGSPIDER_BASE_POSTGRESQL_VERSION}"

    # pgspider
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # contrib
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # debugsource
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # devel
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # docs
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # libs
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # llvmjit
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # plperl
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # pltcl
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # server
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # test
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
else
    curl_command="curl -L \
                            -X POST \
                            -H \"Accept: application/vnd.github+json\" \
                            -H \"Authorization: Bearer ${ACCESS_TOKEN}\" \
                            -H \"X-GitHub-Api-Version: 2022-11-28\" \
                            -H \"Content-Type: application/octet-stream\" \
                            --insecure"
    assets_uri="https://uploads.github.com/repos/${OWNER_GITHUB}/${PGSPIDER_PROJECT_GITHUB}/releases/${PGSPIDER_RELEASE_ID}/assets"
    binary_dir="--data-binary \"@${RPM_ARTIFACT_DIR}\""

    # pgspider
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # contrib
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # debugsource
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # devel
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # docs
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # libs
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # llvmjit
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # plperl
    eval "$curl_command $assets_uri?name=name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # pltcl
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # server
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # test
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
fi

# Clean
docker rmi $IMAGE_TAG
