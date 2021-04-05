# git-deploy-scripts


## Background

- TODO


## My solution

- TODO


## Usage

- TODO


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

## Contributing

- Feel free to create issue, pull request, etc if there's anything that can be improved
