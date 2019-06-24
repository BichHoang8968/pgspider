def NODE_NAME = 'AWS_Instance_CentOS'
def MAIL_TO = '$DEFAULT_RECIPIENTS'
def BRANCH_NAME = 'Branch [' + env.BRANCH_NAME + ']'
def BUILD_INFO = 'Jenkins: ' + env.BUILD_URL
def MYSQL_FDW_URL = 'https://tccloud2.toshiba.co.jp/swc/gitlab/g3033310/mysql-fdw.git'
def SQLITE_FDW_URL = 'https://github.com/pgspider/sqlite_fdw.git'
def TINYBRACE_FDW_URL = 'https://tccloud2.toshiba.co.jp/accio/svn/accio/branches/tinybrace_fdw'

def retrySh(String shCmd) {
    def MAX_RETRY = 10
    script {
        int status = 1;
        for (int i = 0; i < MAX_RETRY; i++) {
            status = sh(returnStatus: true, script: shCmd)
            if (status == 0) {
                echo "SUCCESS: "+shCmd
                break
            } else {
                echo "RETRY: "+shCmd 
                sleep 5
            }
        }
        if (status != 0) {
            sh(shCmd)
        }
    }
}

pipeline {
    agent {
        node {
            label NODE_NAME
        }
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
        stage('Build') {
            steps {
                // Build PGSpider
                sh '''
                    rm -rf install || true
                    mkdir install || true
                    INSTALL_DIR="$(pwd)/install"
                    ./configure --prefix=$INSTALL_DIR --enable-cassert --enable-debug CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer"
                    make clean && make && make install
                '''
                // Build fdw
                dir("contrib/") {
                    // Build mysql_fdw 
                    sh 'rm -rf mysql_fdw || true'
                    retrySh('git clone ' + MYSQL_FDW_URL)
                    sh '''
                        cd mysql_fdw
                        make clean && make && make install
                    '''
                    // Build sqlite_fdw 
                    sh 'rm -rf sqlite_fdw || true'
                    retrySh('git clone ' + SQLITE_FDW_URL)
                    sh '''
                        cd sqlite_fdw
                        make clean && make && make install
                    '''
                    // Build tinybrace_fdw 
                    sh 'rm -rf tinybrace_fdw || true'
                    retrySh('svn co ' + TINYBRACE_FDW_URL)
                    sh '''
                        cd tinybrace_fdw
                        make clean && make && make install
                    '''
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] BUILD PGSpider FAILED ' + BRANCH_NAME, body: BUILD_INFO + "\nGit commit: " + env.GIT_URL.replace(".git", "/commit/") + env.GIT_COMMIT + "\n" + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                }
            }
        }
        stage('make_check') {
            steps {
                // Execute "make check" and output log to 'make_check.out'
                catchError() {
                    sh '''
                        pwd
                        rm -rf make_check.out || true
                        make check | tee make_check.out
                    '''
                }
                // Check test result
                script {
                    // Check if 'make_check.out' contains 'All [0-9]* tests passed'
                    status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check.out'")
                    if (status != 0) {
                        unstable(message: "Set UNSTABLE result")
                        // Send mail
                        emailext subject: '[CI PGSpider] "make check" Test FAILED ' + BRANCH_NAME, body: BUILD_INFO + "\nGit commit: " + env.GIT_URL.replace(".git", "/commit/") + env.GIT_COMMIT + "\n" + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                        sh 'cat src/test/regress/regression.diffs || true'
                    }
                }
            }
        }
        stage('pgspider_core_fdw.sql') {
            steps {
                // Change working directory to 'contrib/pgspider_core_fdw/'
                dir("contrib/pgspider_core_fdw/") {
                    // Execute 'test.sh'
                    catchError() {
                        sh '''
                            rm -rf make_check.out || true
                            chmod +x ./*.sh
                            chmod +x ./init/*.sh
                            ./test.sh
                        '''
                    }
                    script {
                        // Check if 'make_check.out' contains 'All [0-9]* tests passed'
                        status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check.out'")
                        if (status != 0) {
                            unstable(message: "Set UNSTABLE result")
                            // Send email and attach test results
                            emailext subject: '[CI PGSpider] pgspider_core_fdw Test FAILED ' + BRANCH_NAME, body: BUILD_INFO + "\nGit commit: " + env.GIT_URL.replace(".git", "/commit/") + env.GIT_COMMIT + "\n" + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                            sh 'cat regression.diffs || true'
                        }
                    }
                }
            }
        }
    }
}