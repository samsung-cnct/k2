// Configuration variables
repo_org="samsung_cnct"
cloud_test_timeout=8 // Should be about 5 min
e2e_test_timeout=18  // Should be about 15 min
cleanup_timeout=9    // Should be about 6 min
kubernetes_version="v1.6.7"
e2etester_version="0.2"


podTemplate(label: 'k2', containers: [
    containerTemplate(name: 'jnlp', image: "quay.io/${repo_org}/custom-jnlp:0.1", args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'k2-tools', image: "quay.io/${repo_org}/k2-tools:latest", ttyEnabled: true, command: 'cat', alwaysPullImage: true, resourceRequestMemory: '1Gi', resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'e2e-tester', image: "quay.io/${repo_org}/e2etester:${e2etester_version}", ttyEnabled: true, command: 'cat', alwaysPullImage: true, resourceRequestMemory: '1Gi', resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
  ], volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    hostPathVolume(hostPath: '/var/lib/docker/scratch', mountPath: '/mnt/scratch'),
    secretVolume(mountPath: '/home/jenkins/.docker/', secretName: 'samsung-cnct-quay-robot-dockercfg')
  ]) {
    node('k2') {
        customContainer('k2-tools'){

            stage('Checkout') {
                checkout scm
            }
            stage('Configure') {
                kubesh 'build-scripts/fetch-credentials.sh'
                kubesh './up.sh --generate cluster/aws/config.yaml'
                kubesh "build-scripts/update-generated-config.sh cluster/aws/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
                kubesh 'mkdir -p cluster/gke'
                kubesh 'cp ansible/roles/kraken.config/files/gke-config.yaml cluster/gke/config.yaml'
                kubesh "build-scripts/update-generated-config.sh cluster/gke/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
        }
            // Dry Run Test
            stage('Test: Dry Run') {
                kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ -t dryrun'
            }

            // Unit tests
            stage('Test: Unit') {
                kubesh 'true' // Add unit test call here
            }

            // Live tests
            try {
                try {
                    err=false
                    timeout(cloud_test_timeout) {
                        stage('Test: Cloud') {
                            parallel (
                                "aws": {
                                    kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/'

                                },
                                "gke": {
                                    kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                                }
                            )
                        }
                    }
                } catch (caughtError) {
                    err = caughtError
                    currentBuild.result = "FAILURE"                
                } finally {
                    // This keeps the stage view from deleting prior history when the E2E test isn't run
                    if (err) {
                        stage('Test: E2E') {
                            echo 'E2E test not run due to stage failure.'
                            currentBuild.result = "NOT_BUILT"                
                        }
                        throw err
                    }
                }
                timeout(e2e_test_timeout) {
                    stage('Test: E2E') {
                        customContainer('e2e-tester') {
                            kubesh "PWD=`pwd` && build-scripts/conformance-tests.sh ${kubernetes_version} ${env.JOB_BASE_NAME}-${env.BUILD_ID} /mnt/scratch"
                            junit "output/artifacts/*.xml"
                        }
                    }
                }
            } finally {
                timeout(cleanup_timeout) {
                    stage('Clean up') {
                        parallel (
                            "aws": {
                                kubesh 'PWD=`pwd` && ./down.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ || true'
                            },
                            "gke": {
                                kubesh 'PWD=`pwd` && ./down.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                            }
                        )
                    }
                }
            }
        }

        customContainer('docker') {
            // add a docker rmi/docker purge/etc.
            stage('Build') {
                kubesh "docker build --no-cache -t quay.io/${repo_org}/k2:k2-${env.JOB_BASE_NAME}-${env.BUILD_ID} docker/"
            }

            //only push from master if we are on samsung-cnct fork
            stage('Publish') {
                if (env.BRANCH_NAME == "master" && env.GIT_URL ==~ "/${repo_org}/") {
                    kubesh "docker tag quay.io/${repo_org}/k2:k2-${env.JOB_BASE_NAME}-${env.BUILD_ID} quay.io/${repo_org}/k2:latest"
                    kubesh "docker push quay.io/${repo_org}/k2:latest"
                } else {
                    echo 'not master branch, not pushing to docker repo'
                    currentBuild.result = "NOT_BUILT"                
                }
            }
        }
    }
}

def kubesh(command) {
  if (env.CONTAINER_NAME) {
    if ((command instanceof String) || (command instanceof GString)) {
      command = kubectl(command)
    }

    if (command instanceof LinkedHashMap) {
      command["script"] = kubectl(command["script"])
    }
  }

  sh(command)
}

def kubectl(command) {
  "kubectl exec -i ${env.HOSTNAME} -c ${env.CONTAINER_NAME} -- /bin/sh -c 'cd ${env.WORKSPACE} && ${command}'"
}

def customContainer(String name, Closure body) {
  withEnv(["CONTAINER_NAME=$name"]) {
    body()
  }
}

// vi: ft=groovy
