def NODE_NAME = 'AWS_Instance_CentOS'
def MAIL_TO = '$DEFAULT_RECIPIENTS'
def BRANCH_NAME = 'Branch [' + env.BRANCH_NAME + ']'
def BUILD_INFO = 'Jenkins job: ' + env.BUILD_URL + '\n'

def PGSPIDER_DOCKER_PATH = '/home/jenkins/Docker/Server/PGSpider'
def ENHANCE_TEST_DOCKER_PATH = '/home/jenkins/Docker'
def DCT_DOCKER_PATH = '/home/jenkins/Docker/Server/GCP'
def GITLAB_DOCKER_PATH = '/home/jenkins/Docker/Server/Gitlab'
def OBJSTORAGE_MIGRATE_PATH = '/home/jenkins/Docker/Server/Objstorage/PGSMigrate'
def SETUP_CLUSTER_TEST_PATH = '/home/jenkins/Docker/Server/SetupCluster'

def BRANCH_PGSPIDER = env.BRANCH_NAME
def BRANCH_TINYBRACE_FDW = 'master'
def BRANCH_MYSQL_FDW = 'master'
def BRANCH_SQLITE_FDW = 'master'
def BRANCH_GRIDDB_FDW = 'master'
def BRANCH_INFLUXDB_FDW = 'master'
def BRANCH_PARQUET_S3_FDW = 'master'
def BRANCH_MONGO_FDW = 'master'
def BRANCH_DYNAMODB_FDW = 'master'
def BRANCH_ORACLE_FDW = 'master'
def BRANCH_ODBC_FDW = 'master'
def BRANCH_JDBC_FDW = 'master'
def BRANCH_REDMINE_FDW = 'master'
def BRANCH_PGSPIDER_COMPRESSION = 'main'
def BRANCH_GITLAB_FDW = 'main'
def BRANCH_OBJSTORAGE_FDW = 'dev_main'
def BRANCH_SQLUMDASH_FDW = 'master'
def BRANCH_POSTGREST_FDW= 'master'

pipeline {
    agent {
        node {
            label NODE_NAME
        }
    }
    options {
        gitLabConnection('GitLabConnection')
    }
    triggers {
        gitlab(
            triggerOnPush: true,
            triggerOnMergeRequest: false,
            triggerOnClosedMergeRequest: false,
            triggerOnAcceptedMergeRequest: true,
            triggerOnNoteRequest: false,
            setBuildDescription: true,
            branchFilterType: 'All'
        )
    }
    stages {
        stage('Start_containers_Existed_Test') {
            steps {
                script {
                    if (env.GIT_URL != null) {
                        BUILD_INFO = BUILD_INFO + "Git commit: " + env.GIT_URL.replace(".git", "/commit/") + env.GIT_COMMIT + "\n"
                    }
                    sh 'rm -rf results_* || true'
                }
                catchError() {
                    sh """
                        rm -rf /tmp/minio_pgspider/* || true
                        cp -a contrib/pgspider_core_fdw/init/test-bucket /tmp/minio_pgspider
                        cp -a contrib/pgspider_core_fdw/init/parquets3 /tmp/minio_pgspider
                        rm -rf /tmp/data_s3_1/* || true
                        rm -rf /tmp/data_s3_2/* || true
                        mkdir -p /tmp/data_s3_1/data/source && mkdir -p /tmp/data_s3_1/data/dest && mkdir -p /tmp/data_s3_2/data/source && mkdir -p /tmp/data_s3_2/data/dest
                        cd ${PGSPIDER_DOCKER_PATH}
                        docker compose up -d
                    """
                }
            }
            post {
                failure {
                    echo '** Start containers FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] Start containers FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }
        stage('Build_PGSpider1') {
            steps {
                catchError() {
                    sh """
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW} ${BRANCH_MONGO_FDW} ${BRANCH_DYNAMODB_FDW} ${BRANCH_ORACLE_FDW} ${BRANCH_ODBC_FDW} ${BRANCH_JDBC_FDW} ${BRANCH_REDMINE_FDW}" vagrant'
                    """
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] BUILD PGSpider FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }
        stage('pgspider_make_check') {
            steps {
                catchError() {
                    sh """
                        rm -rf pgspider_make_check.out || true
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_makecheck" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/make_check.out pgspider_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] make_check Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/src/test/regress/regression.diffs pgspider_make_check_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/src/test/regress/results results_make_check'
                        sh 'cat pgspider_make_check_regression.diffs || true'
                        updateGitlabCommitStatus name: 'make_check', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'make_check', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_fdw') {
            steps {
                catchError() {
                    sh """
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_pgspider_fdw" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_fdw/make_check.out pgspider_fdw_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_fdw_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_fdw_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_fdw/regression.diffs pgspider_fdw_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_fdw/results results_pgspider_fdw'
                        sh 'cat pgspider_fdw_regression.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw', state: 'success'
                    }
                }
            }
        }
        stage('postgres_fdw') {
            steps {
                catchError() {
                    sh """
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_postgres_fdw" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/postgres_fdw/make_check.out postgres_fdw_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'postgres_fdw_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] postgres_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="postgres_fdw_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/postgres_fdw/regression.diffs postgres_fdw_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/postgres_fdw/results results_postgres_fdw'
                        sh 'cat postgres_fdw_regression.diffs || true'
                        updateGitlabCommitStatus name: 'postgres_fdw', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'postgres_fdw', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_core_fdw.sql') {
            steps {
                catchError() {
                    sh """
                        docker exec oracle_multi_existed_test /bin/bash -c '/home/test/start_oracle_config.sh'
                        docker exec -u oracle oracle_multi_existed_test /bin/bash -c '/home/test/setup_oracle_server.sh'
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgspider_multii.sh --test_core ${BRANCH_PGSPIDER}" postgres'
                        docker exec mysqlserver_multi_existed_test /bin/bash -c '/home/test/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}'
                        docker exec tinybraceserver_multi_existed_test /bin/bash -c '/home/test/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}'
                        docker exec -w /usr/local/tinybrace tinybraceserver_multi_existed_test /bin/bash -c 'bin/tbserver &'
                        docker exec redmine_server_for_existed_test /bin/bash -c 'bundle exec rails runner -e production /home/test/create_redmine_data.rb'
                        docker exec redmine_server_for_existed_test /bin/bash -c 'bundle exec rails runner -e production /home/test/create_customfields_data.rb'
                        docker exec redmine_mysql_db /bin/bash -c '/home/test/update_date_time_fields.sh'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_core" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_fdw'
                        sh 'cat pgspider_core_fdw_regression.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw', state: 'success'
                    }
                }
            }
        }
        stage('ported_postgres_fdw.sql') {
            steps {
                catchError() {
                    sh """
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgspider_multii.sh --test_ported ${BRANCH_PGSPIDER}" postgres'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_ported" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_ported_postgres_fdw_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_ported_postgres_fdw_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] ported_postgres_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_ported_postgres_fdw_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspidder_ported_postgres_fdw_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_ported_postgres_fdw'
                        sh 'cat pgspidder_ported_postgres_fdw_regression.diffs || true'
                        updateGitlabCommitStatus name: 'ported_postgres_fdw', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'ported_postgres_fdw', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_core_fdw_multi.sql') {
            steps {
                catchError() {
                    sh """
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgspider_multii.sh --test_multi ${BRANCH_PGSPIDER}" postgres'
                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}"
                        docker exec tinybraceserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}"
                        docker exec -w /usr/local/tinybrace tinybraceserver_multi_existed_test /bin/bash -c 'bin/tbserver &'
                        docker exec influxserver_multi_existed_test /bin/bash -c 'systemctl stop influxd'
                        docker exec influxserver_multi_existed_test /bin/bash -c 'sed -i "s/.*store-enabled.*/  store-enabled = false/" /etc/influxdb/influxdb.conf'
                        docker exec -d influxserver_multi_existed_test /bin/bash -c 'influxd -config /etc/influxdb/influxdb.conf'
                        docker exec gridserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}"
                        docker exec influxserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}"
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" vagrant'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" vagrant'
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_multi.sh --pgs2" vagrant'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_multi.sh --pgs3" vagrant'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_multi" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_multi_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_multi_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_multi Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_multi_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_multi_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_multi_fdw'
                        sh 'cat pgspider_core_fdw_multi_regression.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_multi', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_multi', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_selectfunc') {
            steps {
                catchError() {
                    sh """
                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_selectfunc.sh ${BRANCH_PGSPIDER}"
                        # docker exec influxserver_multi_existed_test /bin/bash -c 'systemctl stop influxd'
                        # docker exec -d influxserver_multi_existed_test /bin/bash -c 'influxd -config /etc/influxdb/influxdb.conf'
                        docker exec influxserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_selectfunc.sh ${BRANCH_PGSPIDER}"
                        docker exec gridserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_selectfunc.sh ${BRANCH_PGSPIDER}"
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" vagrant'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" vagrant'
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_selectfunc.sh --pgs2" vagrant'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_selectfunc.sh --pgs3" vagrant'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_selectfunc" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_selectfunc_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_selectfunc_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_selectfunc Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_selectfunc_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_selectfunc.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_fdw_selectfunc'
                        sh 'cat pgspider_core_fdw_selectfunc.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_selectfunc', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_selectfunc', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_limit') {
            steps {
                catchError() {
                    sh """
                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_limit.sh ${BRANCH_PGSPIDER}"
                        # docker exec influxserver_multi_existed_test /bin/bash -c 'systemctl stop influxd'
                        # docker exec -d influxserver_multi_existed_test /bin/bash -c 'influxd -config /etc/influxdb/influxdb.conf'
                        docker exec influxserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_limit.sh ${BRANCH_PGSPIDER}"
                        docker exec gridserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_limit.sh ${BRANCH_PGSPIDER}"
                        docker exec gridserver_multi1_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_limit_1.sh ${BRANCH_PGSPIDER}"
                        docker exec gridserver_multi2_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_limit_2.sh ${BRANCH_PGSPIDER}"
                        docker exec tinybraceserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_limit.sh ${BRANCH_PGSPIDER}"
                        docker exec -w /usr/local/tinybrace tinybraceserver_multi_existed_test /bin/bash -c 'bin/tbserver &'
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgspider_limit.sh ${BRANCH_PGSPIDER}" postgres'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_limit.sh" vagrant'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_limit" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_limit_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_limit_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_limit Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_limit_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_limit.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_fdw_limit'
                        sh 'cat pgspider_core_fdw_limit.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_limit', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_limit', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_modify') {
            steps {
                catchError() {
                    sh """
                        docker exec -w /dynamodblocal dynamodbserver_multi1_existed_test /bin/bash -c 'java -jar DynamoDBLocal.jar -sharedDb &'
                        docker exec -w /dynamodblocal dynamodbserver_multi2_existed_test /bin/bash -c 'java -jar DynamoDBLocal.jar -sharedDb &'
                        docker exec mongoserver_multi_existed_test /bin/bash -c '/usr/bin/mongod --dbpath /data/db --bind_ip_all --tlsMode disabled &'
                        docker exec -u oracle oracle_multi_existed_test /bin/bash -c '/home/test/start_existed_test_pgmodify.sh ${BRANCH_PGSPIDER}'
                        docker exec mongoserver_multi_existed_test /bin/bash -c '/home/test/start_existed_test_pgmodify.sh ${BRANCH_PGSPIDER}'
                        docker exec dynamodbserver_multi1_existed_test /bin/bash -c '/home/test/start_existed_test_pgmodify.sh --dynamo1'
                        docker exec dynamodbserver_multi2_existed_test /bin/bash -c '/home/test/start_existed_test_pgmodify.sh --dynamo2'

                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgmodify.sh ${BRANCH_PGSPIDER}"
                        docker exec mysqlserver_multi1_existed_test /bin/bash -c "/home/test/start_existed_test_pgmodify_1.sh ${BRANCH_PGSPIDER}"
                        docker exec gridserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgmodify.sh ${BRANCH_PGSPIDER}"
                        docker exec tinybraceserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgmodify.sh ${BRANCH_PGSPIDER}"
                        docker exec -w /usr/local/tinybrace tinybraceserver_multi_existed_test /bin/bash -c 'bin/tbserver &'
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgmodify.sh ${BRANCH_PGSPIDER}" postgres'

                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgmodify.sh" vagrant'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c '/home/test/start_odbc_for_pgmodify.sh'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_pgmodify" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_pgmodify_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_pgmodify_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_pgmodify Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_pgmodify_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_pgmodify.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_fdw_pgmodify'
                        sh 'cat pgspider_core_fdw_pgmodify.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_pgmodify', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_pgmodify', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_modify_multi') {
            steps {
                catchError() {
                    sh """
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgmodify_multi.sh ${BRANCH_PGSPIDER}" postgres'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c '/home/test/start_odbc_for_pgmodify.sh'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgmodify.sh --multi" vagrant'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_pgmodify_multi" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_pgmodify_multi_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_pgmodify_multi_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_pgmodify_multi Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_pgmodify_multi_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_pgmodify_multi.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_fdw_pgmodify_multi'
                        sh 'cat pgspider_core_fdw_pgmodify_multi.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_pgmodify_multi', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_pgmodify_multi', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_migrate_postgres') {
            steps {
                catchError() {
                    sh """
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgspider_migrate.sh ${BRANCH_PGSPIDER}" postgres'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgspider_migrate.sh" vagrant'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_migrate_postgres" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out test_migrate_postgres_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'test_migrate_postgres_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] test_migrate_postgres_make_check Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="test_migrate_postgres_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs test_migrate_postgres_make_check.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results test_migrate_postgres_make_check'
                        sh 'cat test_migrate_postgres_make_check.diffs || true'

                    } else {
                        updateGitlabCommitStatus name: 'test_migrate_postgres', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_migrate_multi') {
            steps {
                catchError() {
                    sh """
                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_migrate_multi.sh"
                        # docker exec influxserver_multi_existed_test /bin/bash -c 'systemctl stop influxd'
                        # docker exec -d influxserver_multi_existed_test /bin/bash -c 'influxd -config /etc/influxdb/influxdb.conf'
                        docker exec influxserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_migrate_multi.sh"
                        docker exec gridserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_migrate_multi_1.sh"
                        docker exec gridserver_multi1_existed_test /bin/bash -c "/home/test/start_existed_test_pgspider_migrate_multi_2.sh"

                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_pgspider_migrate_multi.sh" postgres'
                        docker exec oracle_multi_existed_test /bin/bash -c '/home/test/start_oracle_config.sh'
                        docker exec -u oracle oracle_multi_existed_test /bin/bash -c '/home/test/start_existed_test_pgspider_migrate_multi.sh'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_migrate_multi" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_migrate_multi_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_migrate_multi_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_migrate_multi Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_migrate_multi_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_migrate_multi.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_fdw_migrate_multi'
                        sh 'cat pgspider_core_fdw_migrate_multi.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_migrate_multi', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_migrate_multi', state: 'success'
                    }
                }
            }
        }
        stage('prepare_for_pgspider_data_compression') {
            steps {
                catchError() {
                    sh """
                        cd ${PGSPIDER_DOCKER_PATH}
                        docker compose down
                        sleep 10
                        rm -rf /tmp/minio1_compression/bucket/* && rm -rf /tmp/minio2_compression/bucket/* && rm -rf /tmp/minio3_compression/bucket/* || true
                        mkdir -p /tmp/minio1_compression/bucket/ && mkdir -p /tmp/minio2_compression/bucket/ && mkdir -p /tmp/minio3_compression/bucket/ || true
                        cd ${DCT_DOCKER_PATH}
                        docker compose up -d
                        sleep 10
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/initialize_pgspider_compression_test.sh ${BRANCH_PGSPIDER} --build_data_compress ${BRANCH_MYSQL_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_ORACLE_FDW} ${BRANCH_OBJSTORAGE_FDW}" pgspider'
                    """
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] Prepare for Test Data Compression Transfer FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }
        stage('pgspider_data_compression') {
            steps {
                catchError() {
                    sh """
                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_compression.sh"
                        docker exec -d influx2_multi_existed_test /bin/bash -c 'influxd --storage-write-timeout=100s --http-bind-address=:38086'
                        docker exec influx2_multi_existed_test /bin/bash -c '/home/test/start_existed_test_compression.sh'
                        docker exec gridserver_multi_existed_test /bin/bash -c "/home/test/start_existed_test_compression.sh"
                        docker exec gridserver_multi1_existed_test /bin/bash -c "/home/test/start_existed_test_compression_1.sh"
                        docker exec gridserver_multi2_existed_test /bin/bash -c "/home/test/start_existed_test_compression_2.sh"
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_compression.sh" postgres'
                        docker exec oracle_multi_existed_test /bin/bash -c '/home/test/start_oracle_config.sh'
                        docker exec -u oracle oracle_multi_existed_test /bin/bash -c '/home/test/start_existed_test_compression.sh ${BRANCH_PGSPIDER}'

                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" vagrant'
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_compression.sh" vagrant'
                        docker exec gcpserver_for_compression_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test_compression.sh ${BRANCH_PGSPIDER_COMPRESSION}" pgspider'
                        docker exec -d -w /tmp/pgspider_compression/FunctionGCP gcpserver_for_compression_existed_test /bin/bash -c 'su -c " source ~/.bashrc && mvn function:run" pgspider'

                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c '/home/test/influxdb_cxx_client_build.sh'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_data_compression_test.sh --test_data_compression" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_data_compression_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_data_compression_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_data_compression Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_data_compression_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_data_compression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results pgspider_core_fdw_data_compression'
                        sh 'cat pgspider_core_fdw_data_compression.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_data_compression', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_data_compression', state: 'success'
                    }
                }
            }
        }
        stage('prepare_for_pgspider_core_gitlab') {
            steps {
                catchError() {
                    sh """
                        cd ${DCT_DOCKER_PATH}
                        docker compose down
                        sleep 10
                        cd ${GITLAB_DOCKER_PATH}
                        docker compose up --wait
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh ${BRANCH_PGSPIDER} --build_gitlab ${BRANCH_GITLAB_FDW}" vagrant'
                    """
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] Prepare for Test Gitlab FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }
        stage('pgspider_core_gitlab') {
            steps {
                catchError() {
                    sh """
                        docker exec gitlab_server_existed_test /bin/bash -c '/home/test/init_gitlab_test.sh'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_existed_test.sh --test_pgspider_core_gitlab" vagrant'
                        docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_gitlab_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_gitlab_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_gitlab Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_gitlab_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_gitlab.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_gitlab'
                        sh 'cat pgspider_core_gitlab.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_gitlab', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_gitlab', state: 'success'
                    }
                }
            }
        }
        stage('prepare_for_pgspider_objstorage_migrate') {
            steps {
                catchError() {
                    sh """
                        cd ${GITLAB_DOCKER_PATH}
                        docker compose down
                        sleep 10
                        cd ${OBJSTORAGE_MIGRATE_PATH}
                        docker compose up -d
                    """
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] Prepare for Test Objstorage migrate FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }
        stage('pgspider_objstorage_migrate') {
            steps {
                catchError() {
                    sh """
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/init_pgspider_migrate_objstorage.sh ${BRANCH_PGSPIDER} ${BRANCH_OBJSTORAGE_FDW}" pgspider'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/home/test/start_migrate_test.sh" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_objstorage_migrate_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_objstorage_migrate_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_objstorage_migrate Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_objstorage_migrate_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_objstorage_migrate.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_objstorage_migrate'
                        sh 'cat pgspider_objstorage_migrate.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_objstorage_migrate', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_objstorage_migrate', state: 'success'
                    }
                }
            }
        }
        stage('prepare_for_setup_cluster') {
            steps {
                catchError() {
                    sh """
                        rm -rf /tmp/minio_parquet/* || true
                        mkdir -p /tmp/minio_parquet/setupcluster || true
                        cp contrib/setup_cluster/test/init_data/tbl_parquetminio.parquet /tmp/minio_parquet/setupcluster
                        cd ${OBJSTORAGE_MIGRATE_PATH}
                        docker compose down
                        sleep 10
                        cd ${SETUP_CLUSTER_TEST_PATH}
                        docker compose up -d
                        sleep 10
                        docker exec pgspiderserver_setup_cluster_test /bin/bash -c 'su -c "/home/test/start_setup_cluster_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW} ${BRANCH_MONGO_FDW} ${BRANCH_DYNAMODB_FDW} ${BRANCH_ORACLE_FDW} ${BRANCH_ODBC_FDW} ${BRANCH_JDBC_FDW} ${BRANCH_REDMINE_FDW} ${BRANCH_GITLAB_FDW} ${BRANCH_SQLUMDASH_FDW} ${BRANCH_OBJSTORAGE_FDW} ${BRANCH_POSTGREST_FDW}" vagrant'
                        docker exec pgspiderserver_setup_cluster_test /bin/bash -c 'su -c "/home/test/start_setup_cluster_test.sh --init_setupcluster" vagrant'
                    """
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] Prepare for Test Setup Cluster FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }
        stage('pgspider_setup_cluster') {
            steps {
                catchError() {
                    sh """
                        docker exec -w /dynamodblocal dynamodbserver_setup_cluster_test /bin/bash -c 'java -jar DynamoDBLocal.jar -sharedDb &'
                        docker exec mongoserver_setup_cluster_test /bin/bash -c '/usr/bin/mongod --dbpath /data/db --bind_ip_all &'
                        docker exec -d influxserverv2_setup_cluster_test /bin/bash -c 'influxd --storage-write-timeout=100s --http-bind-address=:38086'
                        docker exec influxserver1_auth_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_create_cxx_users.sh'    
                        docker exec -d influxserver1_auth_setup_cluster_test /bin/bash -c 'export INFLUXDB_HTTP_AUTH_ENABLED=true && influxd -config /etc/influxdb/influxdb.conf'                       
                        docker exec oracle_setup_cluster_test /bin/bash -c '/home/test/start_oracle_config.sh'
                        docker exec dynamodbserver_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_dynamodb_init.sh ${BRANCH_PGSPIDER}'
                        docker exec mysqlserver_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_mysql_init.sh ${BRANCH_PGSPIDER}'
                        docker exec mongoserver_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_mongo_init.sh ${BRANCH_PGSPIDER}' || true
                        docker exec influxserver_setup_cluster_test /bin/bash -c 'sed -i "s/.*store-enabled.*/  store-enabled = false/" /etc/influxdb/influxdb.conf'
                        docker exec -d influxserver_setup_cluster_test /bin/bash -c 'influxd -config /etc/influxdb/influxdb.conf'
                        docker exec influxserver_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_influxv1_init.sh ${BRANCH_PGSPIDER}'
                        docker exec influxserver1_auth_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_influxv1_auth_init.sh ${BRANCH_PGSPIDER}'
                        docker exec influxserverv2_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_influxv2_init.sh ${BRANCH_PGSPIDER}'
                        docker exec gridserver_setup_cluster_test /bin/bash -c "/home/test/setup_cluster_griddb_init.sh ${BRANCH_PGSPIDER}"
                        docker exec gridjdbcserver_setup_cluster_test /bin/bash -c "/home/test/setup_cluster_jdbc_init.sh ${BRANCH_PGSPIDER}"
                        docker exec postgresserver_setup_cluster_test /bin/bash -c 'su -c "/home/test/setup_cluster_postgres_init.sh ${BRANCH_PGSPIDER}" user_postgres'
                        docker exec -u oracle oracle_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_oracle_init.sh ${BRANCH_PGSPIDER}'
                        docker exec tinybraceserver_setup_cluster_test /bin/bash -c "/home/test/setup_cluster_tinybrace_init.sh ${BRANCH_PGSPIDER}"
                        docker exec -w /usr/local/tinybrace tinybraceserver_setup_cluster_test /bin/bash -c 'bin/tbserver &'
                        docker exec sqlumdashserver_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_sqlumdash_init.sh ${BRANCH_PGSPIDER}'
                        docker exec redmine_server_for_existed_test /bin/bash -c 'bundle exec rails runner -e production /home/test/create_redmine_data.rb'
                        docker exec redmine_server_for_existed_test /bin/bash -c 'bundle exec rails runner -e production /home/test/create_customfields_data.rb'
                        docker exec redmine_mysql_db /bin/bash -c '/home/test/update_date_time_fields.sh'
                        docker exec redmine1_server_for_existed_test /bin/bash -c 'bundle exec rails runner -e production /home/test/create_redmine_data.rb'
                        docker exec redmine1_server_for_existed_test /bin/bash -c 'bundle exec rails runner -e production /home/test/create_customfields_data.rb'
                        docker exec redmine1_mysql_db /bin/bash -c '/home/test/update_date_time_fields.sh'
                        docker exec redmine2_server_for_existed_test /bin/bash -c 'bundle exec rails runner -e production /home/test/create_redmine_data.rb'
                        docker exec redmine2_server_for_existed_test /bin/bash -c 'bundle exec rails runner -e production /home/test/create_customfields_data.rb'
                        docker exec redmine2_mysql_db /bin/bash -c '/home/test/update_date_time_fields.sh'
                        docker exec gitlab_server_existed_test /bin/bash -c '/home/test/init_gitlab_test.sh' || true
                        docker exec pgspiderserver_setup_cluster_test /bin/bash -c '/home/test/influxdb_cxx_client_build.sh'
                        docker exec pgspiderserver_setup_cluster_test /bin/bash -c '/home/test/odbc_jdbc_setup.sh'
                        docker exec pgspiderserver_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_objstorage_init.sh'
                        docker exec restapiserver_setup_cluster_test /bin/bash -c '/home/test/setup_cluster_postgrest_init.sh'
                        docker exec -d restapiserver_setup_cluster_test /bin/bash -c '/home/test/postgrest /home/test/postgrest.conf'
                        docker exec pgspiderserver_setup_cluster_test /bin/bash -c 'su -c "/home/test/start_setup_cluster_test.sh --test_setupcluster" vagrant' || true
                        docker cp pgspiderserver_setup_cluster_test:/home/vagrant/PGSpider/contrib/setup_cluster/make_check.out pgspider_setup_cluster.out
                        cat pgspider_setup_cluster.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_setup_cluster.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_setup_cluster Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_setup_cluster.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_setup_cluster_test:/home/vagrant/PGSpider/contrib/setup_cluster/regressions.diff pgspider_setup_cluster.diff'
                        sh 'docker cp pgspiderserver_setup_cluster_test:/home/vagrant/PGSpider/contrib/setup_cluster/results results_pgspider_setup_cluster'
                        sh 'cat pgspider_setup_cluster.diff || true'
                        updateGitlabCommitStatus name: 'pgspider_setup_cluster', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_setup_cluster', state: 'success'
                    }
                }
            }
        }
        /*stage('Start_containers_Enhance_Test') {
            steps {
                catchError() {
                    sh """
                        cd ${ENHANCE_TEST_DOCKER_PATH}
                        docker compose up -d
                    """
                }
            }
            post {
                failure {
                    echo '** Start containers Enhace_Test FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] Start containers FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }
        stage('Initialize_for_Enhance_Test') {
            steps {
                catchError() {
                    sh """
                        docker exec mysqlserver1_enhance_test /bin/bash -c '/home/test/start_enhance_test.sh'
                        docker exec mysqlserver2_enhance_test /bin/bash -c '/home/test/start_enhance_test.sh'
                        docker exec postgresserver1_enhance_test /bin/bash -c '/home/test/start_enhance_test_1.sh'
                        docker exec postgresserver2_enhance_test /bin/bash -c '/home/test/start_enhance_test_2.sh'
                        docker exec tinybraceserver1_enhance_test /bin/bash -c '/home/test/start_enhance_test_1.sh'
                        docker exec -w /usr/local/tinybrace tinybraceserver1_enhance_test /bin/bash -c 'bin/tbserver &'
                        docker exec tinybraceserver2_enhance_test /bin/bash -c '/home/test/start_enhance_test_2.sh'
                        docker exec -w /usr/local/tinybrace tinybraceserver2_enhance_test /bin/bash -c 'bin/tbserver &'
                        docker exec influxserver1_enhance_test /bin/bash -c 'systemctl stop influxd'
                        docker exec -d influxserver1_enhance_test /bin/bash -c 'influxd -config /etc/influxdb/influxdb.conf'
                        docker exec influxserver2_enhance_test /bin/bash -c 'systemctl stop influxd'
                        docker exec -d influxserver2_enhance_test /bin/bash -c 'influxd -config /etc/influxdb/influxdb.conf'
                        docker exec influxserver1_enhance_test /bin/bash -c '/home/test/start_enhance_test.sh'
                        docker exec influxserver2_enhance_test /bin/bash -c '/home/test/start_enhance_test.sh'
                        docker exec gridserver1_enhance_test /bin/bash -c '/home/test/start_enhance_test_1.sh'
                        docker exec gridserver2_enhance_test /bin/bash -c '/home/test/start_enhance_test_2.sh'
                        docker exec pgspiderserver1_enhance_test /bin/bash -c 'su -c "/home/test/start_enhance_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW}" vagrant'
                    """
                }
            }
            post {
                failure {
                    echo '** Init data for Enhance Test FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] Init data for Enhance Test FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Init_Data', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Init_Data', state: 'success'
                }
            }
        }
        stage('make_check_Enhance_Test') {
            steps {
                catchError() {
                    sh """
                        docker exec pgspiderserver1_enhance_test /bin/bash -c 'su -c "/home/test/start_enhance_test.sh --test_enhance" vagrant'
                        docker cp pgspiderserver1_enhance_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/make_check.out make_check_enhancetest.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check_enhancetest.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_enhance Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check_enhancetest.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver1_enhance_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/regression.diffs regression_enhancetest.diffs'
                        sh 'docker cp pgspiderserver1_enhance_test:/home/vagrant/PGSpider/contrib/pgspider_core_fdw/results results_enhancetest'
                        sh 'cat regression_enhancetest.diffs || true'
                        updateGitlabCommitStatus name: 'make_check', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'make_check', state: 'success'
                    }
                }
            }
        }
        stage('run_enhance_test_on_local_machine') {
            steps {
                catchError() {
                    sh """
                        cd ${ENHANCE_TEST_DOCKER_PATH}
                        chmod a+x run_enhance_local.sh
                        ./run_enhance_local.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW}
                    """
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] ENHANCE TEST FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }*/
    }
    post {
        success {
            script {
                //Get result of previous build on current branch
                prevResult = 'SUCCESS'
                if (currentBuild.previousBuild != null) {
                    prevResult = currentBuild.previousBuild.result.toString()
                }
                if (prevResult != 'SUCCESS') {
                    emailext subject: '[CI PGSpider] PGSpider_Test BACK TO NORMAL on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                }
            }
        }
        always {
            sh """
                cd ${PGSPIDER_DOCKER_PATH}
                docker compose down
                cd ${DCT_DOCKER_PATH}
                docker compose down
                cd ${GITLAB_DOCKER_PATH}
                docker compose down
                cd ${OBJSTORAGE_MIGRATE_PATH}
                docker compose down
                cd ${SETUP_CLUSTER_TEST_PATH}
                docker compose down              
                #cd ${ENHANCE_TEST_DOCKER_PATH}
                #docker compose down
            """
        }
    }
}
