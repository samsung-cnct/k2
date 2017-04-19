podTemplate(label: 'k2', containers: [
    containerTemplate(name: 'jnlp', image: 'jenkinsci/jnlp-slave:2.62-alpine', args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'k2-tools', image: 'quay.io/samsung_cnct/k2-tools:latest', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
  ], volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    secretVolume(mountPath: '/home/jenkins/.docker/', secretName: 'coffeepac-quay-robot-dockercfg')
  ]) {
    node('k2') {
        container('k2-tools'){

            stage('checkout') {
                checkout scm
            }    

            stage('fetch credentials') {
                sh 'build-scripts/fetch-credentials.sh'
            }

            stage('config generation') {
                sh './up.sh --generate k2/config.yaml'
            }

            stage('update generated config') {
                sh 'build-scripts/update-generated-config.sh k2/config.yaml'
            }

            stage('create k2 cluster') {
                sh './up.sh --config k2/config.yaml --output k2/cluster'
            }

            stage('run e2e tests') {
                sh 'echo "not doing this yet"'
            }

            stage('destroy k2 cluster') {
                sh './down.sh --config k2/config.yaml --output k2/cluster'
            }
        }

        container('docker') {
            stage('docker build') {
                sh 'docker build -t quay.io/coffeepac/k2:jenkins docker/'
            }

            stage('docker push') {
                sh 'docker push quay.io/coffeepac/k2:jenkins'
            }
        }
    }
  }  