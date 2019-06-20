def MAIL_TO='$DEFAULT_RECIPIENTS'

def retrySh(String shCmd) {
    script {
        int status = 1;
        for (int i = 0; i < 10; i++) {
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
            label 'AWS_CentOS_Instant'
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
            addCiMessage: true,
            branchFilterType: 'All',
            secretToken: "14edd1f2fc244d9f6dfc41f093db270a"
        )
    }
    stages {
        stage('Build') {
            steps {
                // Build PGSpider
                sh '''
                    pwd
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
                    retrySh('git clone https://github.com/EnterpriseDB/mysql_fdw.git')
                    sh '''
                        cd mysql_fdw
                        make clean && make && make install
                    '''
                    // Build sqlite_fdw 
                    sh 'rm -rf sqlite_fdw || true'
                    retrySh('git clone https://github.com/pgspider/sqlite_fdw.git')
                    sh '''
                        cd sqlite_fdw
                        make clean && make && make install
                    '''
                    // Build tinybrace_fdw 
                    sh 'rm -rf tinybrace_fdw || true'
                    retrySh('svn co --username Tung3 https://tccloud2.toshiba.co.jp/accio/svn/accio/branches/tinybrace_fdw')
                    sh '''
                        cd tinybrace_fdw
                        make clean && make && make install
                    '''
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] BUILD PGSpider FAILED', body: '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
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
                        emailext attachLog: false, body: '${FILE,path="make_check.out"}', subject: '[CI PGSpider] make check Test FAILED', to: "${MAIL_TO}"
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
                            emailext attachLog: false, body: '${FILE,path="make_check.out"}', subject: '[CI PGSpider] pgspider_core_fdw Test FAILED', to: "${MAIL_TO}"
                        }
                    }
                }
            }
        }
    }
}