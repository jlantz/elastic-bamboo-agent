#!/bin/bash
#set -x

# Get versions from env or use defaults
if [ "$DOCKER_COMPOSE_VERSION" == "" ]; then
    export DOCKER_COMPOSE_VERSION=1.6.1
fi

if [ "$BAMBOO_AGENT_VERSION" == "" ]; then
    export BAMBOO_AGENT_VERSION=5.6
fi

# Timeout for the agent start.
# Increase the timeout if the script does not get to `Bamboo agent 'Elastic Agent on <ec2-instance-id>' ready to receive builds.`.
AGENT_TIMEOUT="3m"

# Enable the multiverse repos
sudo sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
sudo apt-get update

echo -e "\n\n[Bamboo Agent installation script]: Installing AWS Tools...\n\n"
#sudo apt-add-repository ppa:awstools-dev/awstools -y
sudo apt-get install -y awscli ec2-api-tools

echo -e "\n\n[Bamboo Agent installation script]: Installing Java...\n\n"
sudo apt-get install -y openjdk-7-jdk
echo -e "\nexport JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" | sudo tee -a /etc/environment

java -version

echo -e "\n\n\[Bamboo Agent installation script]: Installing other packages...\n\n"
sudo apt-get install -y mc unzip htop

echo -e "\n\n[Bamboo Agent installation script]: Installing Docker, Docker Compose...\n\n"
curl -sSL https://get.docker.com/ | sh
sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo docker version
sudo docker-compose --version

echo -e "\n\n[Bamboo Agent installation script]: Configuring users..\n\n"
sudo useradd -m bamboo --shell /bin/bash
sudo usermod -aG docker ubuntu
sudo usermod -aG docker bamboo

echo -e "\n\n[Bamboo Agent installation script]: Installing Bamboo Agent...\n\n"
wget https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/bamboo/atlassian-bamboo-elastic-image/${BAMBOO_AGENT_VERSION}/atlassian-bamboo-elastic-image-${BAMBOO_AGENT_VERSION}.zip
sudo mkdir -p /opt/bamboo-elastic-agent
sudo unzip -o atlassian-bamboo-elastic-image-${BAMBOO_AGENT_VERSION}.zip -d /opt/bamboo-elastic-agent
sudo chown -R bamboo /opt/bamboo-elastic-agent
sudo chmod u+r+w /opt/bamboo-elastic-agent
sudo chmod 755 /opt/bamboo-elastic-agent/*

echo -e "\n\n[Bamboo Agent installation script]: Configuring paths...\n\n"
echo -e "\nexport PATH=$PATH:$JAVA_HOME/bin:/opt/bamboo-elastic-agent/bin"  | sudo tee -a /etc/profile.d/bamboo.sh

echo -e "\n\n[Bamboo Agent installation script]: Configuring Bamboo Agent autostart\n\n"
# Configure automatic startup of the Bamboo agent (add before line 14 of /etc/rc.local
sudo sed -i '14 i . /opt/bamboo-elastic-agent/etc/rc.local\n' /etc/rc.local
#sudo sed -i 's/exit 0/#exit 0/' /etc/rc.local
#echo -e "\n#Configure automatic startup of the Bamboo agent\n. /opt/bamboo-elastic-agent/etc/rc.local\n" | sudo tee -a /etc/rc.local

echo -e "\n\n[Bamboo Agent installation script]: Starting Bamboo Agent...\n\n"
sudo su -c "timeout $AGENT_TIMEOUT /opt/bamboo-elastic-agent/bin/bamboo-elastic-agent" - bamboo

echo -e "\n\n[Bamboo Agent installation script]: Finalizing ...\n\n"
# Welcome screen
sudo cp /opt/bamboo-elastic-agent/etc/motd /etc/motd
echo bamboo-agent-${BAMBOO_AGENT_VERSION}  | sudo tee -a /etc/motd
sudo rm -f /root/firstlogin /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key.pub /etc/ssh/ssh_host_key /etc/ssh/ssh_host_key.pub /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key.pub /root/.ssh/authorized_keys
sudo touch /root/firstrun
sudo /opt/bamboo-elastic-agent/bin/prepareInstanceForSaving.sh
