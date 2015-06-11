#!/bin/bash
#set -x

# Timeout for the agent start.
# Increase the timeout if the script does not get to `Bamboo agent 'Elastic Agent on <ec2-instance-id>' ready to receive builds.`.
AGENT_TIMEOUT="5m"

echo "    [Bamboo Agent installation script]: Installing Java and other packages.."
sudo apt-get update
sudo apt-get install openjdk-7-jdk -y

java -version

echo "    [Bamboo Agent installation script]: Installing other packages..."
sudo apt-get install unzip htop -y

echo "    [Bamboo Agent installation script]: Installing Docker, Docker Compose..."
wget -qO- https://get.docker.com/ | sh
curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` | sudo dd of=/usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo docker version
sudo docker-compose --version

echo "    [Bamboo Agent installation script]: Configuring users.."
sudo useradd -m bamboo --shell /bin/bash
sudo usermod -aG docker ubuntu
sudo usermod -aG docker bamboo

echo "    [Bamboo Agent installation script]: Installing Bamboo Agent..."
export imageVer=4.1
wget https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/bamboo/atlassian-bamboo-elastic-image/${imageVer}/atlassian-bamboo-elastic-image-${imageVer}.zip
sudo mkdir -p /opt/bamboo-elastic-agent
sudo unzip -o atlassian-bamboo-elastic-image-${imageVer}.zip -d /opt/bamboo-elastic-agent
sudo chown -R bamboo /opt/bamboo-elastic-agent
sudo chmod u+r+w /opt/bamboo-elastic-agent
sudo chmod 755 /opt/bamboo-elastic-agent/*

echo "    [Bamboo Agent installation script]: Configuring paths..."
echo -e "\nexport JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" | sudo tee -a /etc/profile.d/bamboo.sh
echo -e "\nexport PATH=/opt/bamboo-elastic-agent/bin:$JAVA_HOME/bin:$PATH"  | sudo tee -a /etc/profile.d/bamboo.sh

echo "    [Bamboo Agent installation script]: Configuring Bamboo Agent autostart"
sudo sed -i 's/exit 0/#exit 0/' /etc/rc.local
echo -e "\n#Configure automatic startup of the Bamboo agent\n. /opt/bamboo-elastic-agent/etc/rc.local\n" | sudo tee -a /etc/rc.local

echo "    [Bamboo Agent installation script]: Starting Bamboo Agent..."
sudo su -c "timeout $AGENT_TIMEOUT /opt/bamboo-elastic-agent/bin/bamboo-elastic-agent" - bamboo

echo "    [Bamboo Agent installation script]: Finalizing ..."
sudo cp /opt/bamboo-elastic-agent/etc/motd /etc/motd
echo bamboo-${imageVer}  | sudo tee -a /etc/motd
sudo rm -f /root/firstlogin /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key.pub /etc/ssh/ssh_host_key /etc/ssh/ssh_host_key.pub /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key.pub /root/.ssh/authorized_keys
sudo touch /root/firstrun
sudo /opt/bamboo-elastic-agent/bin/prepareInstanceForSaving.sh
