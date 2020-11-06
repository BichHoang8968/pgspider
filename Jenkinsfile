def NODE_NAME = 'AWS_Instance_CentOS'
def MAIL_TO = 'db-jenkins@swc.toshiba.co.jp'
def BRANCH_NAME = 'Branch [' + env.BRANCH_NAME + ']'
def BUILD_INFO = 'Jenkins job: ' + env.BUILD_URL + '\n'

def PGSPIDER_DOCKER_PATH = '/home/jenkins/Docker/Server/PGSpider'
def ENHANCE_TEST_DOCKER_PATH = '/home/jenkins/Docker'
def TEST_TYPE = 'PGSPIDER'


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
                }
                catchError() {
                    sh """
                        cd ${PGSPIDER_DOCKER_PATH}
                        docker-compose up --build -d
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
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh ${env.GIT_BRANCH}" pgspider'
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
        stage('make_check_Existed_Test') {
            steps {
                catchError() {
                    sh """
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_pgspider" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/make_check.out make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] make_check Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/src/test/regress/regression.diffs regression.diffs'
                        sh 'cat regression.diffs || true'
                        updateGitlabCommitStatus name: 'make_check', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'make_check', state: 'success'
                    }
                }
            }
        }
        stage('pgspider_core_fdw.sql') {
            steps {
                catchError() {
                    sh """
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_pgspider_multii.sh --test_core ${env.GIT_BRANCH}" postgres'
                        docker exec mysqlserver_multi_existed_test /bin/bash -c '/tmp/start_existed_test_pgspider_multii.sh ${env.GIT_BRANCH}'
                        docker exec tinybraceserver_multi_existed_test /bin/bash -c '/tmp/start_existed_test_pgspider_multii.sh ${env.GIT_BRANCH}'
                        docker exec -d -w /usr/local/tinybrace tinybraceserver_multi_existed_test /bin/bash -c 'bin/tbserver &' 
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_core" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_core_fdw'
                        sh 'cat regression.diffs || true'
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
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_pgspider_multii.sh --test_ported ${env.GIT_BRANCH}" postgres'

                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_ported" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] ported_postgres_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_ported_fdw '
                        sh 'cat regression.diffs || true'
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
                        docker exec postgresserver_multi_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_pgspider_multii.sh --test_multi ${env.GIT_BRANCH}" postgres'
                        docker exec mysqlserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_multii.sh ${env.GIT_BRANCH}"
                        docker exec tinybraceserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_multii.sh ${env.GIT_BRANCH}"
                        docker exec -d -w /usr/local/tinybrace tinybraceserver_multi_existed_test /bin/bash -c 'bin/tbserver &' 
                        docker exec -d influxserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_multii.sh ${env.GIT_BRANCH}"
                        docker exec -d gridserver_multi_existed_test /bin/bash -c "/tmp/start_existed_test_pgspider_multii.sh ${env.GIT_BRANCH}"
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh ${env.GIT_BRANCH}" pgspider'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh ${env.GIT_BRANCH}" pgspider'
                        docker exec pgspiderserver_multi2_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_multi.sh --pgs2" pgspider'
                        docker exec pgspiderserver_multi3_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test_multi.sh --pgs3" pgspider'
                        docker exec pgspiderserver_multi1_existed_test /bin/bash -c 'su -c "/tmp/start_existed_test.sh --test_multi" pgspider'
                        docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/make_check.out make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        emailext subject: '[CI PGSpider] pgspider_core_fdw_multi Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/regression.diffs regression.diffs'
                        sh 'docker cp pgspiderserver_multi1_existed_test:/home/pgspider/PGSpider/contrib/pgspider_core_fdw/results results_core_multi_fdw '
                        sh 'cat regression.diffs || true'
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_multi', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'pgspider_core_fdw_multi', state: 'success'
                    }
                }
            }
        }
        stage('Start_containers_Enhance_Test') {
            steps {
                catchError() {
                    sh """
                        cd ${ENHANCE_TEST_DOCKER_PATH}
                        docker-compose up --build -d 
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
                        docker exec -d -w /usr/local/tinybrace tinybraceserver1_enhance_test /bin/bash -c 'bin/tbserver &' 
                        docker exec tinybraceserver2_enhance_test /bin/bash -c '/tmp/start_enhance_test_2.sh'
                        docker exec -d -w /usr/local/tinybrace tinybraceserver2_enhance_test /bin/bash -c 'bin/tbserver &' 
                        docker exec influxserver1_enhance_test /bin/bash -c '/tmp/start_enhance_test.sh'
                        docker exec influxserver2_enhance_test /bin/bash -c '/tmp/start_enhance_test.sh'
                        docker exec -d gridserver1_enhance_test /bin/bash -c '/tmp/start_enhance_test_1.sh'
                        sleep 10
                        docker exec -d gridserver2_enhance_test /bin/bash -c '/tmp/start_enhance_test_2.sh'
                        sleep 10
                        docker exec pgspiderserver1_enhance_test /bin/bash -c 'su -c "/tmp/start_enhance_test.sh ${env.GIT_BRANCH} ${TEST_TYPE}" pgspider'
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
                        rm -rf make_check.out regression.diffs Degrade_Bug.out Previous_TC_NG.out || true
                        mv New_TC_NG.out Previous_TC_NG.out 
                        rm -rf New_TC_NG.out || true
                        docker exec -w /home/pgspider/GIT/PGSpider/contrib/pgspider_core_fdw pgspiderserver1_enhance_test /bin/bash -c 'su -c "chmod a+x *.sh" pgspider'
                        docker exec -w /home/pgspider/GIT/PGSpider/contrib/pgspider_core_fdw pgspiderserver1_enhance_test /bin/bash -c 'su -c "./test_enhance.sh" pgspider'
                        docker cp pgspiderserver1_enhance_test:/home/pgspider/GIT/PGSpider/contrib/pgspider_core_fdw/make_check.out make_check.out
                    """
                }
                script {
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        sh 'docker cp pgspiderserver1_enhance_test:/home/pgspider/GIT/PGSpider/contrib/pgspider_core_fdw/regression.diffs regression.diffs'
                        sh 'cat regression.diffs || true'
                        updateGitlabCommitStatus name: 'make_check', state: 'failed'
                    } else {
                        updateGitlabCommitStatus name: 'make_check', state: 'success'
                    }
                }
            }
        }
        stage('Detect_Degrade_Bug') {
             steps {
                sh """
                    python contrib/pgspider_core_fdw/init/detect_degrade_bug.py
                """
                script {
                    def make_check_exists = fileExists 'make_check.out'
                    def degrade_bug_exists = fileExists 'Degrade_Bug.out'
                    if (make_check_exists) {
                        unstable(message: "Set UNSTABLE result")
                        if (degrade_bug_exists) {
                            emailext subject: '[CI PGSpider] make_check Test and Detect Degrade Bug for Enhance Test FAILED ' + BRANCH_NAME, body: BUILD_INFO + '\n\nList of Degrade Test Case ID:' + '\n\n' + '${FILE,path="Degrade_Bug.out"}' + 'For detail results. Please refer below:' + '\n\n' + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        } else {
                            emailext subject: '[CI PGSpider] make_check Test for Enhance Test FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        }
                        updateGitlabCommitStatus name: 'Detect_Degrade_Bug', state: 'success'
                    } else { 
                        updateGitlabCommitStatus name: 'Detect_Degrade_Bug', state: 'failed'
                    }
                }
            }
        }
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
                cd ${ENHANCE_TEST_DOCKER_PATH}
                docker-compose down
            """
        }
    }
}
