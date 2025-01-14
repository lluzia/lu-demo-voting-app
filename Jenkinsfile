pipeline {
  agent none
  stages {
    stage('worker-build') {
      agent {
        docker {
          image 'maven:3.6.1-jdk-8-alpine'
          args '-v $HOME/.m2:/root/.m2'
        }

      }
      steps {
        echo 'Compiling worker app..'
        dir(path: 'worker') {
          sh 'mvn compile'
        }

      }
    }

    stage('worker-test') {
      agent {
        docker {
          image 'maven:3.6.1-jdk-8-alpine'
          args '-v $HOME/.m2:/root/.m2'
        }

      }
      steps {
        echo 'Running Unit Tets on worker app..'
        dir(path: 'worker') {
          sh 'mvn clean test'
        }

      }
    }

    stage('worker-package') {
      agent {
        docker {
          image 'maven:3.6.1-jdk-8-alpine'
          args '-v $HOME/.m2:/root/.m2'
        }

      }
      steps {
        echo 'Packaging worker app'
        dir(path: 'worker') {
          sh 'mvn package -DskipTests'
          archiveArtifacts(artifacts: '**/target/*.jar', fingerprint: true)
        }

      }
    }

    stage('worker-docker-package') {
      agent any
      steps {
        echo 'Packaging worker app with docker'
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerlogin') {
            def workerImage = docker.build("luzia/worker:v${env.BUILD_ID}", "./worker")
            workerImage.push()
            workerImage.push("${env.BRANCH_NAME}")
            //   workerImage.push("latest")
          }
        }

      }
    }

    stage('result-build') {
      agent {
        docker {
          image 'node:8.16.0-alpine'
          args '-v $HOME/.m2:/root/.m2'
        }

      }
      steps {
        echo 'Compiling result app..'
        dir(path: 'result') {
          sh 'npm install'
        }

      }
    }

    stage('result-test') {
      agent {
        docker {
          image 'node:8.16.0-alpine'
          args '-v $HOME/.m2:/root/.m2'
        }

      }
      steps {
        echo 'Running Unit Tets on result app..'
        dir(path: 'result') {
          sh 'npm install'
          sh 'npm test'
        }

      }
    }

    stage('result-docker-package') {
      agent any
      steps {
        echo 'Packaging result app with docker'
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerlogin') {
            def resultImage = docker.build("luzia/result:v${env.BUILD_ID}", "./result")
            resultImage.push()
            resultImage.push("${env.BRANCH_NAME}")
            resultImage.push("latest")
          }
        }

      }
    }

    stage('vote-build') {
      agent {
        docker {
          image 'python:2.7.16-slim'
          args '--user root'
        }

      }
      steps {
        echo 'Compiling vote app..'
        dir(path: 'vote') {
          sh 'pip install --upgrade pip'
          sh 'pip install -r requirements.txt'
        }

      }
    }

    stage('vote-test') {
      agent {
        docker {
          image 'python:2.7.16-slim'
          args '--user root'
        }

      }
      steps {
        echo 'Running Unit Tets on vote app..'
        dir(path: 'vote') {
          sh 'pip install --upgrade pip'
          sh 'pip install -r requirements.txt'
          sh 'nosetests -v'
        }

      }
    }

    stage('vote-docker-package') {
      agent any
      steps {
        echo 'Packaging vote app with docker'
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerlogin') {
            def voteImage = docker.build("luzia/vote:v${env.BUILD_ID}", "./vote")
            voteImage.push()
            voteImage.push("${env.BRANCH_NAME}")
            voteImage.push("latest")
          }
        }

      }
    }

    stage('Deploy to Dev') {
      agent any
      steps {
        sh 'docker-compose up -d'
      }
    }
    
    // problemas com java version e jenkins
    // stage('Sonarqube') {
    //   agent any
    //   // when{
    //   //   branch 'master'
    //   // }
    //   tools {
    //     nodejs "NodeJS 8.9.0" // the name you have given the JDK installation in Global Tool Configuration
    //   }
  
    //   environment{
    //     sonarpath = tool 'SonarScanner'
    //   }
  
    //   steps {
    //         echo 'Running Sonarqube Analysis..'
    //         withSonarQubeEnv('sonar-instavote') {
    //           sh "${sonarpath}/bin/sonar-scanner -Dproject.settings=sonar-project.properties -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=86400"
    //         }
    //   }
    // }
  
  
    // stage("Quality Gate") {
    //     steps {
    //         timeout(time: 1, unit: 'HOURS') {
    //             // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
    //             // true = set pipeline to UNSTABLE, false = don't
    //             waitForQualityGate abortPipeline: true
    //         }
    //     }
    // }
    
      stage('vote integration'){
        agent any
        when{
          changeset "**/vote/**"
          // branch 'master'
        } 
        steps{
          echo 'Running Integration Tests on vote app'
          dir('vote'){
            sh 'sh integration_test.sh'
          }
        } 
        
      }
  

  }
  post {
    always {
      echo 'Consolidated Pipeline for instavote app.'
    }

  }
}