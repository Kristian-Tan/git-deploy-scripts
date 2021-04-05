#! /bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.

# default argument value
server_ssh_destination=""
directory_in_deployment_server=""
target_repository=`pwd`
remote_repository=""
force_flag=0
name_of_remote_git="origin"
branch_target="master"
configure_receive_denycurrentbranch_updateinstead=0
#x_resethead_after=""
wait_seconds=5
verbose=0

# read arguments from getopts https://wiki.bash-hackers.org/howto/getopts_tutorial https://stackoverflow.com/a/14203146/3706717
while getopts "hs:d:t:r:fn:b:cw:v" opt; do
    case "$opt" in
    h)
        cat << EOF
requirement: 
  local computer: installed ssh-client, git (minimum version v2.4.0+),
  local computer: must be able to reach remote git (ex: github/bitbucket/gitlab) from network,
  deployment server: installed ssh-server, ssh-client, git (minimum version v2.4.0+),
usage: -s server_ssh_destination -d directory_in_deployment_server [-t target_repository] [-r remote_repository] [-f] [-n name_of_remote_git] [-b branch_target] [-c] [-w wait_seconds] [-v]
  -s server_ssh_destination = qualified ssh destination (ex: 'produser@production.server.com')
  -d directory_in_deployment_server = path/name of directory in deployment server (ex: '/var/www/html')
  -t target_repository = path to repository in local computer, default to current directory
  -r remote_repository = remote git repository that is clone-able, if target_repository doesn't exist then script will try to clone from this source, default is empty
  -f = force_flag, will add '--force' to 'git push' option
  -n name_of_remote_git = name of 'git remote' URL from where we should clone, default to 'origin'
  -b branch_target = name of target branch, default to 'master'
  -c = configure_receive_denycurrentbranch_updateinstead flag, please set it for first time (no harm to set it in subsequent deploys), see https://stackoverflow.com/a/34698361/3706717 or http://databio.org/posts/push_to_deploy.html or https://www.gloomycorner.com/pushing-to-a-non-bare-git-repository/"
  -w wait_seconds = waiting for ... seconds before executing (default to 5), if you're sure about the operation then just set it to 0
  -v = verbose
example 1: -s produser@production.server.com -d /home/vhost/myapp -t ~/repo/myapp -b production -c -w 0 -v
  (-b) connect to ssh server 'produser@production.server.com',
  (-d) path to repository in remote ssh server is '/home/vhost/myapp',
  (-t) git repository location in local computer is '~/repo/myapp',
  (-b) use branch 'production' instead of 'master'
  (-c) configure production git repository to allow it to receive 'git push', need git 2.4.0 (2014) or newer
  (-w) wait for 0 seconds (do it immediately)
  (-v) verbose output on
example 2: -s produser@production.server.com -d /home/vhost/myapp -t /tmp/myapp-git -r git@github.com:Kristian-Tan/myapp.git -b production -c -w 0 -v
  (-b) connect to ssh server 'produser@production.server.com',
  (-d) path to repository in remote ssh server is '/home/vhost/myapp',
  (-t) git repository location in local computer is '/tmp/myapp-git' (empty directory),
  (-r) because target_repository points to a directory that doesn't exist, the script will clone it from git@github.com:Kristian-Tan/myapp.git
  (-b) use branch 'production' instead of 'master'
  (-c) configure production git repository to allow it to receive 'git push', need git 2.4.0 (2014) or newer
  (-w) wait for 0 seconds (do it immediately)
  (-v) verbose output on
EOF
        exit 0
        ;;
    s)  server_ssh_destination=$OPTARG
        ;;
    d)  directory_in_deployment_server=$OPTARG
        ;;
    r)  remote_repository=$OPTARG
        ;;
    t)  target_repository=$OPTARG
        ;;
    f)  force_flag=1
        ;;
    n)  name_of_remote_git=$OPTARG
        ;;
    b)  branch_target=$OPTARG
        ;;
    c)  configure_receive_denycurrentbranch_updateinstead=1
        ;;
    #x)  x_resethead_after=" git reset --hard HEAD ; "
    #    ;;
    w)  wait_seconds=$OPTARG
        ;;
    v)  verbose=1
        ;;
    esac
done



# declare verbose output function

# @param string $1
#   Input string that should be printed if verbose is on
verbose_output()
{
    if test $verbose -eq 1; then
        { printf '>>> %s ' "$@"; echo; } 1>&2
    fi
}

# fill argument with default value
if test "$server_ssh_destination" = ""; then
  echo ">>> please set server_ssh_destination!"
  exit 1
fi
if test "$directory_in_deployment_server" = ""; then
  echo ">>> please set directory_in_deployment_server!"
  exit 2
fi
if test ! -d "$target_repository"; then
  echo ">>> please set target_repository to an existing directory!"
  echo ">>> try running command below to create empty directory:"
  echo ">>> mkdir '$target_repository'"
  exit 3
fi

# show to user
verbose_output "server_ssh_destination: '$server_ssh_destination'"
verbose_output "directory_in_deployment_server: '$directory_in_deployment_server'"
verbose_output "target_repository: '$target_repository'"
verbose_output "force_flag: '$force_flag'"
verbose_output "name_of_remote_git: '$name_of_remote_git'"
verbose_output "branch_target: '$branch_target'"
verbose_output "configure_receive_denycurrentbranch_updateinstead: '$configure_receive_denycurrentbranch_updateinstead'"
verbose_output "wait_seconds: '$wait_seconds'"

echo ">>> executing in $wait_seconds seconds... (press ctrl+c to abort)"
sleep $wait_seconds
echo ">>> executing..."

verbose_output "change directory to repository"
verbose_output "  \$ cd \"$target_repository\""
cd "$target_repository"

verbose_output "checking if current directory is a git repository"
if git rev-parse --git-dir > /dev/null 2>&1; then
  verbose_output "  result: current directory is a git repository"
  verbose_output "  continuing execution..."
else
  verbose_output "  result: current directory is not a git repository"

  if test "$remote_repository" = ""; then
    verbose_output "  error: no remote_repository set!"
    exit 4
  fi

  verbose_output "  cloning from remote_repository to current directory..."
  verbose_output "  \$ git clone $remote_repository ."

  git clone $remote_repository .
fi

verbose_output "checkout to branch_target"
verbose_output "  \$ git checkout $branch_target"
git checkout $branch_target

verbose_output "pull latest commit from remote"
verbose_output "  \$ git pull $name_of_remote_git $branch_target"
git pull $name_of_remote_git $branch_target

if test $configure_receive_denycurrentbranch_updateinstead -eq 1; then
  verbose_output "configuring production git repository to allow it to receive 'git push'"
  verbose_output "  \$ ssh $server_ssh_destination -t \"cd $directory_in_deployment_server ; git config receive.denyCurrentBranch updateInstead ; cat .git/config | grep denyCurrentBranch\""
  ssh $server_ssh_destination -t "cd $directory_in_deployment_server ; git config receive.denyCurrentBranch updateInstead ; cat .git/config | grep denyCurrentBranch"
fi

if test $force_flag -eq 0; then
  verbose_output "pushing to deployment server"
  verbose_output "  \$ git push $server_ssh_destination:$directory_in_deployment_server $branch_target"
  git push $server_ssh_destination:$directory_in_deployment_server $branch_target
else
  verbose_output "pushing to deployment server"
  verbose_output "  \$ git push --force $server_ssh_destination:$directory_in_deployment_server $branch_target"
  git push --force $server_ssh_destination:$directory_in_deployment_server $branch_target
fi
