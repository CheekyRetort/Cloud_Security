# Cloud_Security
## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

![TODO: Update the path with the name of your diagram](Images/diagram_filename.png)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the configuration file may be used to install only certain pieces of it, such as Filebeat.

  - _TODO: Enter the playbook file._

This document contains the following details:
- Description of the Topology
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be available even if one of the servers goes down and has the dual purpose of restricting inbound access to the network. The load balancer splits the process of handling incoming traffic to both vulnerable web servers. Access controls will ensure that only authorized users will be able to connect in the first place.  By using a jump box we have one secured access point into the other virtual machines. 

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the file systems of the VMs on the network with FileBeat as well as system metrics, such as SSH login attempts, failed sudo escalation attempts, and changes to CPU/RAM statistics with MetricBeat.

- Filebeat is used to detect changes in the filesystem.
- MetricBeat detects SSH login attempts, failed sudo escalation attempts, and changes to CPU/RAM statistics.

The configuration details of each machine may be found below.

| Name                  | Function   | IP Address | Operating System |
|-----------------------|------------|------------|------------------|
| Jumpbox-Provisioner   | Gateway    | 10.0.0.4   | Linux            |
| Web-1                 | Web Server | 10.0.0.5   | Linux            |
| Web-2                 | Web Server | 10.0.0.6   | Linux            |
| Cadger_Imposing (ELK) | Monitoring | 10.1.0.4   | Linux            |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jumpbox machine can accept connections from the Internet. Access to this machine is only allowed from my private IP Address.

Machines within the network can only be accessed by each other. The DVWA 1 (Web-1) and DVWA (Web-2) Vms send traffic to the ELK server.

A summary of the access policies in place can be found in the table below.

| Name                  | Publicly Accessible | Allowed IP Addresses |
|-----------------------|---------------------|----------------------|
| Jumpbox-Provisioner   | Yes                 | Private IP Address   |
| Web-1                 | No                  | 10.0.0.1-254         |
| Web-2                 | No                  | 10.0.0.1-254         |
| Cadger_Imposing (ELK) | No                  | 10.0.0.1-254         |

### Elk Configuration

The jumpbox was configured with ansible to enable infastructure as code.  It automates the tasks of getting the servers up and running by a simple command.  This enables us to expand quickly as our network grows or, in case of errors, repair virtual machines. 


The playbook implements the following tasks:
- Configure Elk VM with Docker by using the apt module to install docker.io and python3-pip.
- Use the pip module to install the Python Docker module.
- Use the command module to increase the virtual memory and the systemctl module to use that newly availiable memory.
- Download and launch a docker ELK container and specify which ports it should run on.
- Use systemd module to enable docker to run on boot. 

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

![TODO: Update the path with the name of your screenshot of docker ps output](Images/docker_ps_output.png)

- The Playbook is duplicated below:

---
- name: Configure Elk VM with Docker
  hosts: elk
  remote_user: azureuser
  become: true
  tasks:
    # Use apt module
    - name: Install docker.io
      apt:
        update_cache: yes
        force_apt_get: yes
        name: docker.io
        state: present

      # Use apt module
    - name: Install python3-pip
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

      # Use pip module (It will default to pip3)
    - name: Install Docker module
      pip:
        name: docker
        state: present

      # Use command module
    - name: Increase virtual memory
      command: sysctl -w vm.max_map_count=262144

      # Use sysctl module
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: "262144"
        state: present
        reload: yes

      # Use docker container module
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        # Please list the ports that ELK runs on
        published_ports:
          -  5601:5601
          -  9200:9200
          -  5044:5044

      # Use systemd module
    - name: Enable service docker on boot
      systemd:
        name: docker
        enabled: yes


### Target Machines & Beats
This ELK server is configured to monitor the following machines:
- DVWA 1 (Web-1) and DVWA 2 (Test-2) at 10.0.0.5 and 10.0.0.6 respecitively.

We have installed the following Beats on these machines:
- FileBeat, MetricBeat, and PacketBeat.

These Beats allow us to collect the following information from each machine:
- Filebeat detects changes in filesystem.  In this instance we are using it to collect Apache logs.
- MetricBeat detects changes in the system metrics.  In this instance we are using it to detect SSH login attempts, failed sudo escalation attempts, and changes to CPU/RAM statistics.
- PacketBeat collects packets as they pass though the NIC.  In this instance we are using it to trace all the activity on the ntework for forensic analysis later, if needed. 


I combined the installation of fileBeat and metricBeat into one playbook which is duplicated below:

---
- name: installing and launching filebeat and metricbeat
  hosts: webservers
  become: yes
  tasks:

  - name: download filebeat deb
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb

  - name: install filebeat deb
    command: dpkg -i filebeat-7.4.0-amd64.deb

  - name: drop in filebeat.yml
    copy:
      src: /etc/ansible/files/filebeat-config.yml
      dest: /etc/filebeat/filebeat.yml

  - name: enable and configure system module
    command: filebeat modules enable system

  - name: setup filebeat
    command: filebeat setup

  - name: start filebeat service
    command: service filebeat start

  - name: enable service filebeat on boot
    systemd:
      name: filebeat
      enabled: yes
      
#install metricbeat

  - name: download metricbeat deb
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.4.0-amd64.deb

  - name: install metricbeat deb
    command: dpkg -i metricbeat-7.4.0-amd64.deb

  - name: drop in metricbeat.yml
    copy:
      src: /etc/ansible/files/metricbeat-config.yml
      dest: /etc/metricbeat/metricbeat.yml

  - name: enable and configure docker module for metricbeat
    command: metricbeat modules enable docker

  - name: setup metricbeat
    command: metricbeat setup

  - name: start metricbeat service
    command: service metricbeat start

  - name: enable service metricbeat on boot
    systemd:
      name: metricbeat
      enabled: yes

### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
- Copy the playbook file to ansible control node.
- Update the _____ file to include...
- Run the playbook, and navigate to ____ to check that the installation worked as expected.

_TODO: Answer the following questions to fill in the blanks:_
- _Which file is the playbook? Where do you copy it?_
- _Which file do you update to make Ansible run the playbook on a specific machine? How do I specify which machine to install the ELK server on versus which to install Filebeat on?_
- _Which URL do you navigate to in order to check that the ELK server is running?


In order to use the playbooks, you will need to have an Ansible control node already configured. We use the jump box for this purpose.
To use the playbooks, we must perform the following steps:

Copy the playbooks to the Ansible Control Node
Run each playbook on the appropriate targets


The easiest way to copy the playbooks is to use Git:

$ cd /etc/ansible
$ mkdir files
# Clone Repository + IaC Files
$ git clone https://github.com/yourusername/project-1.git
# Move Playbooks and hosts file Into `/etc/ansible`
$ cp project-1/playbooks/* .
$ cp project-1/files/* ./files


This copies the playbook files to the correct place.
Next, you must create a hosts file to specify which VMs to run each playbook on. Run the commands below:

$ cd /etc/ansible
$ cat > hosts <<EOF
[webservers]
10.0.0.5
10.0.0.6

[elk]
10.1.0.4
EOF


After this, the commands below run the playbook:

$ cd /etc/ansible
$ ansible-playbook install-elk.yml elk
$ ansible-playbook Inistall-FileBeat_MetricBeat.yml webservers

To verify success, wait five minutes to give ELK time to start up.
Then, run: curl http://10.1.0.4:5601. This is the address of Kibana. If the installation succeeded, this command should print HTML to the console.
