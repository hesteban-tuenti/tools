# Ansible Local Script Deployer

## Description

This Ansible project is designed to automate the deployment of various scripts to a local machine. It ensures that the scripts are placed in the `$HOME/bin` directory and that this directory is added to the system's PATH, allowing the scripts to be run from anywhere.

## Getting Started

### Dependencies

* Ansible
* Bash or Zsh

### Installing

* Clone the repository to your local machine.
* Install Ansible if not already installed:
  ```shell
  sudo apt update
  sudo apt install ansible
  ```

### Executing

* Run the Ansible playbook:
  `ansible-playbook deploy_tools.yaml`