#!/usr/bin/env groovy
@Library(value='jenkins-pipeline-scripts@master', changelog=false) _

String DOCKER_REGISTRY_HUB=env.DOCKER_REGISTRY_HUB ?: "registry.hub.docker.com".toLowerCase().trim() // registry.hub.docker.com
String DOCKER_ORGANISATION_HUB=env.DOCKER_ORGANISATION_HUB ?: "nabla".trim()



String DOCKER_IMAGE_TAG=dockerImageTag()
//String DOCKER_USERNAME="nabla"


String DOCKER_TAG="1.0.0".trim()
String DOCKER_TAG_NEXT="1.0.1".trim()
//String DOCKER_TAG_NEXT_UBUNTU_1809="1.2.2".trim()
String DOCKER_NAME="ansible-jenkins-slave".trim()
//String DOCKER_NAME="ansible-jenkins-slave-windows".trim()


String DOCKER_IMAGE="${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_IMAGE_TAG}".trim()

String DOCKER_OPTS_COMPOSE = getDockerOpts(isDockerCompose: false, isLocalJenkinsUser: true)
DOCKER_OPTS_COMPOSE +=" -v /jenkins/:/jenkins:rw,z "  // this is specific for molecule nodes in order for ansible to have permission to access /jenkins/.ssh/known_hosts (BUT dangerous for security reasons). It will give access to all infra

containers = [:]

pipeline {
  //agent none
  //agent {
  //  label 'molecule||docker-compose||docker32G||docker16G'
  //}
  agent {
    docker {
      image DOCKER_IMAGE
      alwaysPull true
      reuseNode true
      registryUrl DOCKER_REGISTRY_ACR_URL
      registryCredentialsId DOCKER_REGISTRY_ACR_CREDENTIAL
      args DOCKER_OPTS_COMPOSE
      label 'molecule'
    }
  }
  parameters {
    string(name: 'DRY_RUN', defaultValue: '--check', description: 'Default mode used to test playbook')
    string(name: 'DOCKER_RUN', defaultValue: '', description: 'Default inventory used to test playbook')
    string(name: 'ANSIBLE_INVENTORY', defaultValue: 'inventory/production', description: 'Default inventory used to test playbook')
    string(name: 'TARGET_SLAVE', defaultValue: 'FR1SWAZUDO00291.misys.global.ad', description: 'Default server used to test playbook')
    string(name: 'TARGET_PLAYBOOK', defaultValue: 'windows.yml', description: 'Default playbook to override')
    string(name: 'TARGET_PLAYBOOK_CLEANING', defaultValue: 'cleaning.yml', description: 'Default playbook to override')
    booleanParam(name: 'CLEAN_RUN', defaultValue: false, description: 'Clean before run')
    booleanParam(name: 'SKIP_LINT', defaultValue: false, description: 'Skip Linter - requires ansible galaxy roles, so it is time consuming')
    booleanParam(name: 'SKIP_DOCKER', defaultValue: false, description: 'Skip Docker - requires image rebuild from scratch')
    booleanParam(name: 'MOLECULE_DEBUG', defaultValue: false, description: 'Enable --debug flag for molecule - does not affect executions of other tests')
    booleanParam(defaultValue: false, description: 'Build only to have package. no test / no docker', name: 'BUILD_ONLY')
    booleanParam(defaultValue: false, description: 'Build sample project', name: 'BUILD_SAMPLE')
    booleanParam(defaultValue: false, description: 'Run molecule tests', name: 'BUILD_MOLECULE')
    booleanParam(defaultValue: false, description: 'Build jenkins docker images', name: 'BUILD_DOCKER')
    booleanParam(defaultValue: false, description: 'Build jenkins docker windows 18 images', name: 'BUILD_DOCKER_WIN1809')
    booleanParam(defaultValue: false, description: 'Build with sonar', name: 'BUILD_SONAR')
    booleanParam(defaultValue: true, description: 'Test windows', name: 'BUILD_WINDOWS')
    booleanParam(defaultValue: false, description: 'Test cleaning', name: 'BUILD_CLEANING')
    booleanParam(defaultValue: false, description: 'Run sphinx', name: 'BUILD_DOC')
  }
  options {
    disableConcurrentBuilds()
    skipStagesAfterUnstable()
    //parallelsAlwaysFailFast() // this is hidding failure and unstable stage
    ansiColor('xterm')  // Missing on bm-ci-pl
    timeout(time: 300, unit: 'MINUTES') // 5 hours
    timestamps()
  }
  stages {
    stage('Setup') {
      steps {
        script {
          setUp(description: "Ansible")

          lock("${params.TARGET_SLAVE}") {
            echo "Lock on ${params.TARGET_SLAVE} released" // we do not have many molecule label
            sh "rm -f *.log || true"
          } // lock
        }
      }
    }
    stage("Ansible pre-commit check") {
      steps {
        script {
          // TODO testPreCommit
          tee("pre-commit.log") {
            sh "#!/bin/bash \n" +
              "whoami \n" +
              "source ./scripts/run-python.sh\n" +
              "pre-commit run -a || true\n" +
              "find . -name 'kube.*' -type f -follow -exec kubectl --kubeconfig {} cluster-info \\; || true\n"
          } // tee
        } // script
      }
    } // stage pre-commit
    stage('Documentation') {
      when {
        expression { params.BUILD_ONLY == false && params.BUILD_DOC == true }
      }
      environment {
        PYTHON_MAJOR_VERSION = "3.8"
      }
      // Creates documentation using Sphinx and publishes it on Jenkins
      // Copy of the documentation is rsynced
      steps {
        script {
          runSphinx(shell: "export PYTHON_MAJOR_VERSION=3.8 && ../scripts/run-python.sh && ./build.sh", targetDirectory: "fusionrisk-ansible/")
        }
      }
    }
    stage('Windows tests') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_ONLY == false && params.BUILD_WINDOWS == true }
      }
      steps {
        script {
          // bm-ci-pl
          if (JENKINS_URL ==~ /.*nabla-jenkins.*|.*tmp-jenkins.*|.*test-jenkins.*|.*localhost.*/ ) {
            sh "ls -lrta /tmp || true"
            sh "ls -lrta ~/.ssh || true"
            sh "export PYTHON_MAJOR_VERSION=3.8 && ../scripts/run-python.sh  && pip install pywinrm==0.4.2 || true"
            configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: 'ANSIBLE_VAULT_PASS')]) {
              // ansiblePlaybook no on bm-ci-pl
              ansiblePlaybook colorized: true,
                credentialsId: 'jenkins_unix_slaves',
                //vaultCredentialsId: 'ansible_vault_credentials',
                vaultCredentialsId: 'fr-ansible-vault-password',
                disableHostKeyChecking: true,
                //extras: '-e ansible_python_interpreter="/usr/bin/python2.7"',
                extras: '-e ansible_python_interpreter="/opt/ansible/env38/bin/python3.8 --skip-tags=restart,vm,python35,python36,vs,vs2008,pacman,msys2-native,custom,pscx,mklink,perl,scons,scons230,sqlserver-database,objc,jenkins_user,docker,kubernetes,security"',
                forks: 5,
                installation: 'ansible-latest',
                inventory: "${params.ANSIBLE_INVENTORY}",
                limit: "${params.TARGET_SLAVE}",
                playbook: "${params.TARGET_PLAYBOOK}"
            } // configFileProvider

            echo "Init result: ${currentBuild.result}"
            echo "Init currentResult: ${currentBuild.currentResult}"

          } // JENKINS_URL
        } // script
      } // steps
    } // stage Cleaning tests
    stage('Cleaning tests') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_ONLY == false && params.BUILD_CLEANING == true }
      }
      steps {
        script {
          // bm-ci-pl
          if (JENKINS_URL ==~ /.*nabla-jenkins.*|.*tmp-jenkins.*|.*test-jenkins.*|.*localhost.*/ ) {
            sh "ls -lrta /tmp || true"
            sh "ls -lrta ~/.ssh || true"
            configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: 'ANSIBLE_VAULT_PASS')]) {
              // ansiblePlaybook
              ansiblePlaybook colorized: true,
                credentialsId: 'jenkins_unix_slaves',
                //vaultCredentialsId: 'ansible_vault_credentials',
                vaultCredentialsId: 'fr-ansible-vault-password',
                disableHostKeyChecking: true,
                //extras: '-e ansible_python_interpreter="/usr/bin/python2.7"',
                //extras: '-e ansible_python_interpreter="/usr/bin/python3.7"',
                forks: 5,
                installation: 'ansible-latest',
                inventory: "${params.ANSIBLE_INVENTORY}",
                limit: "${params.TARGET_SLAVE}",
                playbook: "${params.TARGET_PLAYBOOK_CLEANING}"
            } // configFileProvider

            echo "Init result: ${currentBuild.result}"
            echo "Init currentResult: ${currentBuild.currentResult}"

          } // JENKINS_URL
        } // script
      } // steps
    } // stage Cleaning tests

    stage('SonarQube analysis') {
      environment {
        SONAR_SCANNER_OPTS = "-Xmx4g"
        SONAR_USER_HOME = "$WORKSPACE"
      }
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_ONLY == false && params.BUILD_SONAR == true }
      }
      steps {
        script {
          echo "Init result: ${currentBuild.result}"
          echo "Init currentResult: ${currentBuild.currentResult}"

          withSonarQubeWrapper(verbose: true,
             skipMaven: true,
             skipSonarCheck: false,
             reportTaskFile: ".scannerwork/report-task.txt",
             isScannerHome: false,
             sonarExecutable: "/usr/local/sonar-runner/bin/sonar-scanner",
             project: "MD",
             repository: "fusionrisk-ansible")
        }
      } // steps
    } // stage SonarQube analysis
    stage('Molecule - Java') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_MOLECULE == true && params.BUILD_ONLY == false }
      }
      steps {
        script {

          testAnsibleRole(roleName: "java-m")

        }
      }
    } // stage
    stage('Molecule') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_MOLECULE == true && params.BUILD_ONLY == false }
      }
      //environment {
      //  MOLECULE_DEBUG="${params.MOLECULE_DEBUG ? '--debug' : ' '}"  // syntax: important to have the space ' '
      //}
      parallel {
        stage("javascript") {
          steps {
            script {
              testAnsibleRole(roleName: "javascript")
            }
          }
        }
        stage("base_tools") {
          steps {
            script {
              testAnsibleRole(roleName: "base_tools" )
            }
          }
        }
        stage("git") {
          steps {
            script {
              testAnsibleRole(roleName: "git")
            }
          }
        }
      }
    }
    stage('Molecule parallel') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_MOLECULE == true && params.BUILD_ONLY == false }
      }
      parallel {
        stage("cleaning") {
          steps {
            script {
              testAnsibleRole(roleName: "cleaning")
            }
          }
        }
        stage("DNS") {
          steps {
            script {
              testAnsibleRole(roleName: "dns")
            }
          }
        }
      }
    }
    stage('Docker') {
      parallel {
        stage('Windows 1809') {
          when {
            expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
            expression { params.BUILD_ONLY == false && params.BUILD_DOCKER == true && params.BUILD_DOCKER_WIN1809 == true }
          }
          environment {
            CST_CONFIG = "docker/servercore1809/config.yaml"
          }
          steps {
            script {
              if (!params.SKIP_DOCKER && JENKINS_URL ==~ /.*almonde-jenkins.*|.*risk-jenkins.*|.*bm-ci-pl.*|.*test-jenkins.*|.*localhost.*/ ) {

                echo "Init result: ${currentBuild.result}"
                echo "Init currentResult: ${currentBuild.currentResult}"

                tee('docker-build-windows-1809.log') {

                  try {

                    configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: 'ANSIBLE_VAULT_PASS_FILE')]) {

                      withCredentials([string(credentialsId: 'fr-ansible-vault-password', variable: 'ANSIBLE_VAULT_PASS')]) {
                        echo "${ANSIBLE_VAULT_PASS}"

                        sh 'mkdir -p .ssh/ || true'

                        DOCKER_BUILD_ARGS="--pull --build-arg ANSIBLE_VAULT_PASS=${ANSIBLE_VAULT_PASS} "
                        DOCKER_BUILD_ARGS+= getDockerProxyOpts(isProxy: true)

                        if (isCleanRun() == true) {
                          DOCKER_BUILD_ARGS+=" --no-cache"
                        }

                        withCredentials([
                            [$class: 'UsernamePasswordMultiBinding',
                            credentialsId: DOCKER_REGISTRY_ACR_CREDENTIAL,
                            usernameVariable: 'USERNAME',
                            passwordVariable: 'PASSWORD']
                        ]) {
                          def container = docker.build("${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT}", "${DOCKER_BUILD_ARGS} -f docker/servercore1809/Dockerfile . ")
                          container.inside {
                            sh 'echo test'
                            //sh 'cat *.log'
                            archiveArtifacts artifacts: '*.log, /home/jenkins/npm/cache/_logs/*-debug.log', excludes: null, fingerprint: false, onlyIfSuccessful: false
                          }

                          docker.image("${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT}").withRun("-u root --entrypoint='/entrypoint.sh'", "/bin/bash") {c ->
                            logs = sh (
                              script: "docker logs ${c.id}",
                              returnStatus: true
                            )

                            echo "LOGS RETURN CODE : ${logs}"
                            if (logs == 0) {
                                echo "LOGS SUCCESS"
                            } else {
                                echo "LOGS FAILURE"
                                sh "exit 1" // this fails the stage
                                //currentBuild.result = 'FAILURE'
                            }

                          } // docker.image

                          containers.put("windows-1809", container)

                        } // withCredentials

                      } // ANSIBLE_VAULT_PASS

                    } // vault configFileProvider

                  } catch (exc) {
                    echo 'Error: There were errors in tests : ' + exc.toString()
                    currentBuild.result = 'UNSTABLE'
                    logs = "FAIL" // make sure other exceptions are recorded as failure too
                    //error 'There are errors in tests'
                  } finally {
                    echo "finally"
                  } // finally

                  // export CST_CONFIG=docker/servercore1809/config.yaml &&
                  cst = sh (
                    script: "bash scripts/docker-test.sh ${DOCKER_NAME} ${DOCKER_TAG_NEXT} 2>&1 > docker-build-windows-1809-cst.log ",
                    returnStatus: true
                  )

                  echo "CONTAINER STRUCTURE TEST RETURN CODE : ${cst}"
                  if (cst == 0) {
                    echo "CONTAINER STRUCTURE TEST SUCCESS"
                  } else {
                    echo "CONTAINER STRUCTURE TEST FAILURE"
                    echo "WARNING : CST failed, check output at ${env.BUILD_URL}artifact/docker-build-windows-1809-cst.log"
                    // and ${env.BUILD_URL}artifact/docker-build-cst.json
                    currentBuild.result = 'UNSTABLE'
                  }

                  echo "Init result: ${currentBuild.result}"
                  echo "Init currentResult: ${currentBuild.currentResult}"

                } // tee
              } // if
            } // script
          } // steps
          post {
            always {
              archiveArtifacts artifacts: "docker-build-cst.json, *.log, target/ansible-lint*, docker/**/config*.yaml, docker/**/Dockerfile*", onlyIfSuccessful: false, allowEmptyArchive: true
            }
          } // post
        } // stage Windows 1809
      }
    }
  }
  post {
    always {
      node('molecule') {

        withLogParser(failBuildOnError:false, unstableOnWarning: false)

      } // node
      archiveArtifacts artifacts: "*.log, .scannerwork/*.log, roles/*.log, target/ansible-lint*", onlyIfSuccessful: false, allowEmptyArchive: true

    }
    cleanup {
      wrapCleanWsOnNode()
    } // cleanup
  } // post
}
