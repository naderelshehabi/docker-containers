FROM jenkins/jenkins:alpine

# Avoid initial setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/jenkins-config.yml

RUN jenkins-plugin-cli --plugins configuration-as-code \
    blueocean \
    docker-plugin \
    email-ext \
    matrix-auth \
    locale

HEALTHCHECK CMD curl http://localhost:8080 || exit 1