# Ansible Tools Deployer

## Description

This Ansible project is designed to automate the deployment of various scripts to a local machine. It ensures that the scripts are placed in the `$HOME/bin` directory and that this directory is added to the system's PATH, allowing the scripts to be run from anywhere.

## Getting Started

### Dependencies

* Ansible
* Bash or Zsh

### Installing

* Clone the repository to your local machine.
* Create a venv and install the requirements with ansible dependencies (you can use the venv created during the mac installation):
```
python3 -m venv ansible-venv
source ansible-venv/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt

or use pyenv or your favorite method
```

### Executing

* Run the Ansible playbook:
  `ansible-playbook deploy_tools.yaml`

### Tools

* run_toolium:

A tool to run toolium command locally for the novum-test proyect.
When running the toolium command you need to pass the user data according to the platform, app and the jira fields if needed.
With this tool just pass the runner and the type of execution and that's it.

Before using the tool set your workdir directory and the credentials

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

The version will be retrieved automatically but can override it if needed it. To get the version you'll need
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
* pushealo:

Just a wrapper of the git commit and push commands to avoid adding unwanted files, like the setup or the android/ios_toolium.cfg.
It'll unstaged and checkout the files if they were modified and/or staged, and then commit and push the changes setting the remote branch automatically.

Notice that the command won't add untracked files for you, only modified files.

Before using the tool set your workdir directory

* get_jira_ids:

Just parse a file and returns de JQL query with the ids. This might be useful for bulk updates when deprecating scenarios for example.
