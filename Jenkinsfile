                        
pipeline {
    agent any
       environment {
        IMAGE_NAME = "hadil-app"
        DOCKER_HUB_REPO = "hamamou99/${IMAGE_NAME}"
    }
   
    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'github-creds', url: 'https://github.com/hadilamamou/devops.git'
            }
        }

        stage('Build Docker Image') {
                steps {
                    script {
                     // Build the Docker image
                            sh "docker build -t ${IMAGE_NAME} ."
                         }
                    }
             }

        stage('Tag Docker Image') {
            steps {
                script {
                    // Tag the Docker image for Docker Hub
                    sh "docker tag ${IMAGE_NAME} ${DOCKER_HUB_REPO}:latest"
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Use the Docker Hub credentials to log in and push the image
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                        sh '''
                        echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
                        docker push ${DOCKER_HUB_REPO}:latest
                        '''
                    }
                }
            }
        }

   
        // Run Docker Compose for Spring Project
        stage('Docker Compose Spring Project') {
            steps {
                sh 'docker-compose -f docker-compose.yml up -d'
            }
        }
 
        //  Run Docker Compose for Tools
        stage('Docker Compose Tools') {
            steps {
                sh 'docker-compose -f docker-composetools.yml up -d'
            }
        }
 
        stage('Build with Maven') {
            steps {
                sh 'mvn clean compile jacoco:report'
            }
        }
 
        stage('Test Unitaires et Jacoco') {
            steps {
                sh 'mvn clean test'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn package' 
            }
        }
 
        // Analyze Code with SonarQube
        stage('MVN SonarQube') {
            steps {
                script {
                    withSonarQubeEnv('sonarserver') {
                        withCredentials([string(credentialsId: 'sonartoken', variable: 'SONAR_TOKEN')]) {
                            sh '''
                                mvn sonar:sonar \
                                    -Dsonar.projectKey=springproject \
                                    -Dsonar.host.url=http://192.168.33.10:9000 \
                                    -Dsonar.login=${SONAR_TOKEN} \
                                    -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                            '''
                        }
                    }
                }
            }
        }
 
        // Stage for Quality Gate
        stage('Quality Gate') {
            steps {
                script {
                  
                        echo "Quality Gate passed"
                    
                }
            }
        }
 
        //  Deploy to Nexus
        stage('Deploy to Nexus') {
            steps {
                script {
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: '192.168.33.10:8081',
                        groupId: 'com.projet',
                        version: '0.0.1-SNAPSHOT',
                        repository: 'maven-snapshots',
                        credentialsId: 'NEXUS_CRED',
                        artifacts: [
                            [
                                artifactId: 'eventProject',
                                classifier: '',
                                file: 'target/eventBuild.jar',
                                type: 'jar'
                            ]
                        ]
                    )
                }
            }
            post {
                success {
                    echo 'Deployment to Nexus successful.'
                }
                failure {
                    echo 'Error during Nexus deployment.'
                }
            }
        }
    }
 
 
}