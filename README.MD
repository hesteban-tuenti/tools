# Ansible Tools Deployer

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

### Tools

* run_toolium:

A tool to run toolium command locally for the novum-test proyect.
When running the toolium command you need to pass the user data according to the platform , app , the jira executions if needed.
With this tool just pass the runner and the type of execution and that's it.

Run toolium for testing purposes:
`run_toolium -f acceptance/settings/o2uk/cert0/runners/explore/android/postpay.json`

and you'll get the confirmation to run the command:
```Execution with parameters: 
Runner: settings/o2uk/cert0/runners/explore/android/postpay.json
Brand: o2uk
Platform: android
Execution Type: 
Version: 
Are you sure to launch toolium? (y/n)
```

Run toolium for hardening/BER task:
`run_toolium -f acceptance/settings/o2uk/cert0/runners/explore/android/postpay.json -t HARDENING/BER`

The version will be retrieved automatically but can override it if needed it. To get the credentials you'll need
to fill the credentials: ID, and PASS, or just the ID and the PASS will be prompted.
```
Is it the correct version?: 24.0 (y/n) y
Execution with parameters: 
Runner: settings/o2uk/cert0/runners/explore/android/postpay.json
Brand: o2uk
Platform: android
Execution Type: HARDENING
Version: 24.0
Are you sure to launch toolium? (y/n)
```
* novum_push:

Just a wrapper of the git commit and push commands to avoid adding unwanted files , like the setup or the android/ios_toolium.cfg.
It'll unstaged and checkout the files it they were modified and staged, and then commit and push, you won't have to add the remote branch manually.

Notice that the command won't add untracked files for you, only modified files.


* get_jira_ids:

Just parse a file and returns de JQL query with the ids. This might be useful for bulk updates when deprecating scenarios for example.