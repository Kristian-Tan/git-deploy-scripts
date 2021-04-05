#! /bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.

# boilerplate
set -o errexit # exit when any command return non-zero exit code
set -o nounset # exit when using undeclared variables
exit_on_error() {
    if test $# -eq 1; then
        echo ">>> $1"
    fi
    exit 1
}

install_directory_target=""

if test $# -eq 0; then
    install_directory_target="/bin"
else
    install_directory_target="$1"
fi

install_directory_target=`readlink -f "$install_directory_target"`

echo ">>> installing to $install_directory_target"

cp "git-deploy-push.sh" "$install_directory_target/git-deploy-push.sh" || exit_on_error "cannot copy git-deploy-push.sh, is it already installed?"
ln "$install_directory_target/git-deploy-push.sh" "$install_directory_target/git-deploy-push" || exit_on_error "cannot copy git-deploy-push, is it already installed?"

cp "git-deploy-sshfs.sh" "$install_directory_target/git-deploy-sshfs.sh" || exit_on_error "cannot copy git-deploy-sshfs.sh, is it already installed?"
ln "$install_directory_target/git-deploy-sshfs.sh" "$install_directory_target/git-deploy-sshfs" || exit_on_error "cannot copy git-deploy-sshfs, is it already installed?"

cp "git-deploy-sshpull.sh" "$install_directory_target/git-deploy-sshpull.sh" || exit_on_error "cannot copy git-deploy-sshpull.sh, is it already installed?"
ln "$install_directory_target/git-deploy-sshpull.sh" "$install_directory_target/git-deploy-sshpull" || exit_on_error "cannot copy git-deploy-sshpull, is it already installed?"

chmod u+x,g+x,o+x "$install_directory_target/git-deploy-push.sh"
chmod u+x,g+x,o+x "$install_directory_target/git-deploy-push"

chmod u+x,g+x,o+x "$install_directory_target/git-deploy-sshfs.sh"
chmod u+x,g+x,o+x "$install_directory_target/git-deploy-sshfs"

chmod u+x,g+x,o+x "$install_directory_target/git-deploy-sshpull.sh"
chmod u+x,g+x,o+x "$install_directory_target/git-deploy-sshpull"

