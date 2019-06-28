def NODE_NAME = 'AWS_Instance_CentOS'
def MAIL_TO = '$DEFAULT_RECIPIENTS'
def BRANCH_NAME = 'Branch [' + env.BRANCH_NAME + ']'
def BUILD_INFO = 'Jenkins job: ' + env.BUILD_URL + '\n'
def MYSQL_FDW_URL = 'https://tccloud2.toshiba.co.jp/swc/gitlab/g3033310/mysql-fdw.git'
def SQLITE_FDW_URL = 'https://github.com/pgspider/sqlite_fdw.git'
def TINYBRACE_FDW_URL = 'https://tccloud2.toshiba.co.jp/accio/svn/accio/branches/tinybrace_fdw'
def INFLUXDB_FDW_URL = 'https://github.com/pgspider/influxdb_fdw.git'
def GRIDDB_FDW_URL = 'https://github.com/pgspider/griddb_fdw.git'
def GRIDDB_CLIENT_DIR = '/home/jenkins/GridDB/c_client_4.1.0/griddb'
def PGSPIDER_1_DIR = '/home/jenkins/PGSpider/PGS1'
def PGSPIDER_1_PORT = 5433
def PGSPIDER_2_DIR = '/home/jenkins/PGSpider/PGS2'
def PGSPIDER_2_PORT = 5434

// Get result of previous build on current branch
def prevResult = 'SUCCESS'
if (currentBuild.previousBuild != null) {
    prevResult = currentBuild.previousBuild.result
}

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

def install_pgspider(String install_dir, int port) {
    sh install_dir + "/bin/pg_ctl -D " + install_dir + "/databases stop || true"
    sh "rm -rf " + install_dir + " || true"
    sh "mkdir " + install_dir + " || true"
    sh "./configure --prefix=" + install_dir
    sh '''
        make install
        cd contrib/file_fdw/
        make install
        cd ../postgres_fdw/
        make install
        cd ../pgspider_fdw/
        make install
        cd ../pgspider_core_fdw/
        make install
        cd ../sqlite_fdw/
        make install
        cd ../mysql_fdw/
        make install
        cd ../tinybrace_fdw/
        make install
        cd ../influxdb_fdw/
        make install
        cd ../griddb_fdw/
        make install
    '''
    dir(install_dir + "/bin") {
        sh './initdb ../databases'
        sh "sed -i 's/#port = 5432.*/port = "+ port + "/' ../databases/postgresql.conf"
        sh './pg_ctl -D ../databases -l logfile start'
        sh './createdb -p ' + port
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
                script {
                    if (env.GIT_URL != null) {
                        BUILD_INFO = BUILD_INFO + "Git commit: " + env.GIT_URL.replace(".git", "/commit/") + env.GIT_COMMIT + "\n"
                    }
                }
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
                    sh 'rm -rf mysql_fdw || true && mkdir mysql_fdw'
                    dir("mysql_fdw") {
                        git credentialsId: 'dac43358-2ffd-4a4b-b9c4-879554f2e1be', url: MYSQL_FDW_URL
                        sh 'cp -a mysql_fdw/* ./ && rm -rf mysql_fdw'
                        sh 'make clean && make && make install'
                    }
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
                    // Build influxdb_fdw
                    sh 'rm -rf influxdb_fdw || true'
                    retrySh('git clone ' + INFLUXDB_FDW_URL)
                    sh '''
                        cd influxdb_fdw
                        make clean && make && make install
                    '''
                    // Build griddb_fdw
                    sh 'rm -rf griddb_fdw || true'
                    retrySh('git clone ' + GRIDDB_FDW_URL)
                    sh 'cd griddb_fdw && cp -a ' + GRIDDB_CLIENT_DIR + ' ./'
                    sh '''
                        cd griddb_fdw
                        export GRIDDB_HOME=/home/jenkins/GridDB/griddb_nosql-4.1.0/
                        export LD_LIBRARY_PATH=LD_LIBRARY_PATH:$(pwd)/griddb/bin/
                        make clean && make && make install
                    '''
                }
            }
            post {
                failure {
                    echo '** BUILD FAILED !!! NEXT STAGE WILL BE SKIPPED **'
                    emailext subject: '[CI PGSpider] BUILD PGSpider FAILED ' + BRANCH_NAME, body: BUILD_INFO + '{BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                }
            }
        }
        stage('make_check') {
            steps {
                // Execute "make check" and output log to 'make_check.out'
                catchError() {
                    sh '''
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
                        emailext subject: '[CI PGSpider] "make check" Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
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
                            // Send email
                            emailext subject: '[CI PGSpider] pgspider_core_fdw Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                            sh 'cat regression.diffs || true'
                        }
                    }
                }
            }
        }
        stage('pgspider_core_fdw_multi.sql') {
            steps {
                install_pgspider(PGSPIDER_1_DIR, PGSPIDER_1_PORT)
                install_pgspider(PGSPIDER_2_DIR, PGSPIDER_2_PORT)
                dir("contrib/pgspider_core_fdw") {
                    sh '''
                        chmod +x ./*.sh
                        chmod +x ./init/*.sh
                        ./test_multi.sh
                    '''
                    script {
                        // Check if 'make_check.out' contains 'All [0-9]* tests passed'
                        status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check.out'")
                        if (status != 0) {
                            unstable(message: "Set UNSTABLE result")
                            emailext subject: '[CI PGSpider] pgspider_core_fdw_multi Test FAILED on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                            sh 'cat regression.diffs || true'
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                if (prevResult != 'SUCCESS') {
                    emailext subject: '[CI PGSpider] PGSpider_Test BACK TO NORMAL on ' + BRANCH_NAME, body: BUILD_INFO + '${FILE,path="make_check.out"}', to: "${MAIL_TO}", attachLog: false
                }
            }
        }
    }
}