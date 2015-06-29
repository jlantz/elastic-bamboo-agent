# elastic-bamboo-agent
Scripts to build an Elastic Bamboo Agent


## Installation

ubuntu-trusty-14.04-amd64-server-20141125 (ami-4ae27e22)

**Option 1**
1. Clone the repo and cd into the folder
2. ssh -i <ssh private key> <user@host> < install-bamboo-agent.sh


**Option 2**
`curl -s https://raw.githubusercontent.com/blinkreaction/elastic-bamboo-agent/master/install-bamboo-agent.sh | ssh -i <ssh private key> <user@host> 'bash -s'`

`<ssh private key>` - private SSH key to authenticate with the Elastic Bamboo instance
`<user@host>` - Elastic Bamboo instance user@host
