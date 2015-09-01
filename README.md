# elastic-bamboo-agent
Scripts to build an Elastic Bamboo Agent.

Can be used to build your own HVM based Elastic Bamboo Agent image able to run Docker containers.


## Installation

1. Create an HVM image configuration in Bamboo `using ami-4ae27e22` (ubuntu-trusty-14.04-amd64-server-20141125) as the base. This will be the **AMI Builder** instance.
2. Start a new elestic instance using the configuration.
3. Clone this repo and `cd` into the folder
4. `ssh -i <ssh private key> <user@host> < install-bamboo-agent.sh`

   `<ssh private key>` - private SSH key to authenticate with the Elastic Bamboo instance  
   `<user@host>` - Elastic Bamboo instance user@host

    E.g. `ssh -i ~/.ssh/elasticbamboo.pk ubuntu@ec2-52-2-45-223.compute-1.amazonaws.com < install-bamboo-agent.sh`

5. Wait for the installation process to finish.

    You should see "Bamboo agent 'Elastic Agent on i-xxxxxxxx' ready to receive builds" in the logs.

6. Create an AMI from the running instance. This will be your **Docker Bamboo Agent AMI**.
7. Terminate the instance started in step 2.
8. Create an HVM image configuration using the **Docker Bamboo Agent AMI** from step 6.
9. Start a new elestic instance using the configuration.

You should now have an up to date Docker Bamboo Agent
