# git-deploy-scripts


## Background

- This is example scripts to deploy application (copy files from git) to production server
- These scripts are made to show git-beginners on how to automate the process of copying files to production server
- Example scenario:
  - Production server is accessible via ssh
  - There's no additional step in deployment (e.g.: build/compile/etc.), just copy files and done
  - There is a remote git server containing the most updated version (e.g.: github/gitlab/bitbucket)
  - Production server already configured, also contain repository but not latest/most updated version
  - Goal: update application in production server to latest version


## My solution

- Three alternative to do those file-copy operation: SSH pull, SSHFS, push
  - SSH pull: send command to production server via ssh to do these: "pull latest from remote git repository"
  - SSHFS: mount production server's filesystem to local computer, then cd to document root, then pull latest from remote repository
  - push: in local repository, do a "git push" to production server via ssh (not to remote git repository, e.g.: github/gitlab/bitbucket; but to production server's non-bare repo)


## Usage

- common arguments:
  - important:
    - `-s server_ssh_destination ` = qualified ssh destination (ex: 'produser@production.server.com')
    - `-d directory_in_deployment_server` = path/name of directory in deployment server (ex: '/var/www/html')
  - optional:
    - `-n name_of_remote_git` = name of 'git remote' URL from where we should clone, default to 'origin'
    - `-b branch_target` = name of target branch, default to 'master'
    - `-w wait_seconds` = waiting for ... seconds before executing (default to 5), if you're sure about the operation then just set it to 0
    - `-v` = verbose
    - `-h` = show help (please refer to help of each scripts rather than this README.md file)
- specific arguments:
  - push:
    - `-t target_repository` = path to repository in local computer, default to current directory
    - `-r remote_repository` = remote git repository that is clone-able, if target_repository doesn't exist then script will try to clone from this source, default is empty
    - `-f force_flag` = will add '--force' to 'git push' option


## Comparison of each method

| Requirement                          | SSH Pull                                | SSHFS                        | Push                                |
| ------------------------------------ | --------------------------------------- | ---------------------------- | ----------------------------------- |
| local have ssh-client                | MANDATORY                               | MANDATORY                    | MANDATORY                           |
| local have git                       | -                                       | MANDATORY                    | MANDATORY                           |
| local have sshfs (linux or WSL)      | -                                       | local run linux or WSL       | -                                   |
| local can reach remote git repo      | -                                       | MANDATORY                    | MANDATORY                           |
| prod have ssh-client and ssh-server  | MANDATORY                               | MANDATORY                    | MANDATORY                           |
| prod have git                        | MANDATORY                               | -                            | minimum version v2.4.0              |
| prod can reach remote git repo       | MANDATORY                               | -                            | -                                   |
| SUMMARY                              | prod must be able to reach remote repo  | local must run linux or WSL  | prod must have git v2.4.0 or newer  |


## Installation

#### Automatic Installation

- copy paste below command into your terminal:
```bash
git clone https://github.com/Kristian-Tan/git-deploy-scripts.git
cd git-deploy-scripts
sudo bash install.sh
```
- or this one-line: ```git clone https://github.com/Kristian-Tan/git-deploy-scripts.git ; cd git-deploy-scripts ; sudo bash install.sh```
- or another one-line: ```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Kristian-Tan/git-deploy-scripts/HEAD/get)"```

#### Manual Installation

- installation for all users:
  - copy `git-deploy-*.sh` to `/usr/bin` or `/bin` (you can also remove the extension)
  - give other user permission to execute it
  - example:
  ```bash
    cp git-deploy-*.sh /usr/bin/
    chown root:root /usr/bin/git-deploy-*.sh
    chmod 0755 /usr/bin/git-deploy-*.sh
  ```
- installation for one user:
  - copy it to any directory that is added to your PATH variable

#### Uninstallation

- just remove copied files (or just use uninstall.sh script: ```git clone https://github.com/Kristian-Tan/git-deploy-scripts.git ; sudo bash git-deploy-scripts/uninstall.sh```)
- or another one-line: ```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Kristian-Tan/git-deploy-scripts/HEAD/remove)"```

## Contributing

- Feel free to create issue, pull request, etc if there's anything that can be improved
