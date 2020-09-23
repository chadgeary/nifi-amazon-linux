# Reference
Secure installation of an Apache nifi cluster with zookeeper, called via terraform-built SSM/S3 resources. 

# Ports
- **2170** NiFi Web Interface (Forwarded from HTTPS TCP/443 @ ELB)
- **2171** NiFi Cluster Node Communcation
- **2172** NiFi Cluster Load Balance Communcation
- **2173** Zookeeper Server for Clients
- **2174** Zookeeper Peer Communication
- **2175** Zookeeper Leader Election
- **2176** Zookeeper Web Interface

# Files (and their purpose)
# Initial Playbook/Installation
- zookeepers.yml
  - Ansible playbook to bootstrap, download, install, and configure Zookeeper/NiFi on zookeeper instances.
  - Called via SSM when Zookeeper EC2 instances are built.

# NiFi
- authorizers.xml
  - The initial admin identity and zookeeper nodes defined for NiFi
- nifi.properties
  - Configuration file for NiFi - used to define heartbeats/timeouts, cluster configuration, and secure transport.
- nifi.service/.timer
  - .service is a systemd unit to start/stop/restart NiFi.
  - .timer starts the .service on boot (normally not required, required due to Java/NiFi forking).

# Zookeeper
- myid
  - Unique identity of the zookeeper node (1 2 or 3)
- zoo.cfg
  - Configuration file for Zookeeper - defines the zookeeper cluster members.
- zookeeper.service
  - .service is a systemd unit to start/stop/restart Zookeeper.
  - Starts on boot, does not require a timer.

# Node Management
- nifi-join.service/.timer/.yml
  - .yml is an Ansible playbook to check/invite new nodes
  - .service is a systemd unit to call the script (.yml)
  - .timer spawns the service every minute with a randomized 30 second delay

- cli.properties
  - Configuration file for NiFi CLI tool - used to talk with the NiFi cluster securely.
