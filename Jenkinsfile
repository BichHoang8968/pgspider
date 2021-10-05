def NODE_NAME = 'AWS_Instance_CentOS'
def MAIL_TO = '$DEFAULT_RECIPIENTS'
def BRANCH_NAME = 'Branch [' + env.BRANCH_NAME + ']'
def BUILD_INFO = 'Jenkins job: ' + env.BUILD_URL + '\n'
def PGSPIDER_DOCKER_PATH = '/home/tsdv/jenkins/Docker/Server/PGSpider'
def ENHANCE_TEST_DOCKER_PATH = '/home/tsdv/jenkins/Docker'

def BRANCH_PGSPIDER = env.BRANCH_NAME
def BRANCH_TINYBRACE_FDW = 'port14beta2'
def BRANCH_MYSQL_FDW = 'port14beta2'
def BRANCH_SQLITE_FDW = 'port14beta2'
def BRANCH_GRIDDB_FDW = 'port14beta2'
def BRANCH_INFLUXDB_FDW = 'port14beta2'
def BRANCH_PARQUET_S3_FDW = 'port14beta2'

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
            branchFilterType: 'All',
            secretToken: "14edd1f2fc244d9f6dfc41f093db270a"
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
                        cd ${PGSPIDER_DOCKER_PATH}
                        docker-compose up -d
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
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" pgspider'
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
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_makecheck" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/make_check.out pgspider_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] make_check Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/src/test/regress/regression.diffs pgspider_make_check_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/src/test/regress/results results_make_check'
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
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_pgspider_fdw" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_fdw/make_check.out pgspider_fdw_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_fdw_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_fdw_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_fdw/regression.diffs pgspider_fdw_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_fdw/results results_pgspider_fdw'
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
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_postgres_fdw" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/postgres_fdw/make_check.out postgres_fdw_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'postgres_fdw_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] postgres_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="postgres_fdw_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/postgres_fdw/regression.diffs postgres_fdw_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/postgres_fdw/results results_postgres_fdw'
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
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_pgspider_multii.sh --test_core ${BRANCH_PGSPIDER}" postgres'
                        docker exec mysqlserver_multi_existed_test /bin/bash -c '/tmp/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}'
                        docker exec tinybraceserver_multi_existed_test /bin/bash -c '/tmp/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}'
                        docker exec -w /usr/local/tinybrace tinybraceserver_multi_existed_test /bin/bash -c 'bin/tbserver &'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_core" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_fdw'
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
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_pgspider_multii.sh --test_ported ${BRANCH_PGSPIDER}" postgres'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_ported" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_ported_postgres_fdw_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_ported_postgres_fdw_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] ported_postgres_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_ported_postgres_fdw_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspidder_ported_postgres_fdw_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_ported_postgres_fdw'
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
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_pgspider_multii.sh --test_multi ${BRANCH_PGSPIDER}" postgres'
                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}"
                        docker exec tinybraceserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}"
                        docker exec -w /usr/local/tinybrace tinybraceserver_multi_existed_test /bin/bash -c 'bin/tbserver &'
                        docker exec influxserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}"
                        docker exec gridserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_multii.sh ${BRANCH_PGSPIDER}"
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" pgspider'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" pgspider'
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_multi.sh --pgs2" pgspider'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_multi.sh --pgs3" pgspider'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_multi" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_multi_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_multi_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_multi Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_multi_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_multi_regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_multi_fdw'
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
                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_selectfunc.sh ${BRANCH_PGSPIDER}"
                        docker exec influxserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_selectfunc.sh ${BRANCH_PGSPIDER}"
                        docker exec gridserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_selectfunc.sh ${BRANCH_PGSPIDER}"
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" pgspider'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW} ${BRANCH_PARQUET_S3_FDW}" pgspider'
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_selectfunc.sh --pgs2" pgspider'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_selectfunc.sh --pgs3" pgspider'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_selectfunc" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out pgspider_core_fdw_selectfunc_make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'pgspider_core_fdw_selectfunc_make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_selectfunc Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="pgspider_core_fdw_selectfunc_make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs pgspider_core_fdw_selectfunc.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_pgspider_core_fdw_selectfunc'
                        sh 'cat pgspider_core_fdw_selectfunc.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_selectfunc', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_selectfunc', state: 'success'
                    }
                }
            }
        }
        /*stage('Start_containers_Enhance_Test') {
            steps {
                catchError() {
                    sh """
                        cd ${ENHANCE_TEST_DOCKER_PATH}
                        docker-compose up -d
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
                        docker exec mysqlserver1_enhance_test /bin/bash -c '/tmp/start_enhance_test.sh'
                        docker exec mysqlserver2_enhance_test /bin/bash -c '/tmp/start_enhance_test.sh'
                        docker exec postgresserver1_enhance_test /bin/bash -c '/tmp/start_enhance_test_1.sh'
                        docker exec postgresserver2_enhance_test /bin/bash -c '/tmp/start_enhance_test_2.sh'
                        docker exec tinybraceserver1_enhance_test /bin/bash -c '/tmp/start_enhance_test_1.sh'
                        docker exec -w /usr/local/tinybrace tinybraceserver1_enhance_test /bin/bash -c 'bin/tbserver &'
                        docker exec tinybraceserver2_enhance_test /bin/bash -c '/tmp/start_enhance_test_2.sh'
                        docker exec -w /usr/local/tinybrace tinybraceserver2_enhance_test /bin/bash -c 'bin/tbserver &'
                        docker exec influxserver1_enhance_test /bin/bash -c '/tmp/start_enhance_test.sh'
                        docker exec influxserver2_enhance_test /bin/bash -c '/tmp/start_enhance_test.sh'
                        docker exec gridserver1_enhance_test /bin/bash -c '/tmp/start_enhance_test_1.sh'
                        docker exec gridserver2_enhance_test /bin/bash -c '/tmp/start_enhance_test_2.sh'
                        docker exec pgspiderserver1_enhance_test /bin/bash -c 'su -c "/tmp/start_enhance_test.sh ${BRANCH_PGSPIDER} ${BRANCH_TINYBRACE_FDW} ${BRANCH_MYSQL_FDW} ${BRANCH_SQLITE_FDW} ${BRANCH_GRIDDB_FDW} ${BRANCH_INFLUXDB_FDW}" pgspider'
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
                        docker exec pgspiderserver1_enhance_test /bin/bash -c 'su -c "/tmp/start_enhance_test.sh --test_enhance" pgspider'
                        docker cp pgspiderserver1_enhance_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out make_check_enhancetest.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check_enhancetest.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        sh 'docker cp pgspiderserver1_enhance_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs regression_enhancetest.diffs'
                        sh 'docker cp pgspiderserver1_enhance_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_enhancetest'
                        // sh 'cat regression_enhancetest.diffs || true'
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
                docker-compose down
            """
        }
    }
}
