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

# default argument value
server_ssh_destination=""
directory_in_deployment_server=""
mountpoint_directory=""
name_of_remote_git="origin"
branch_target="master"
pre_command_1=""
pre_command_2=""
pre_command_3=""
pre_command_4=""
pre_command_5=""
post_command_6=""
post_command_7=""
post_command_8=""
post_command_9=""
x_resethead_after=""
options_for_sshfs=() # array, see https://stackoverflow.com/a/20761893/3706717
wait_seconds=5
verbose=0
mountpoint_directory_is_exist=1

# read arguments from getopts https://wiki.bash-hackers.org/howto/getopts_tutorial https://stackoverflow.com/a/14203146/3706717
while getopts "hs:d:m:n:b:1:2:3:4:5:6:7:8:9:xo:w:v" opt; do
    case "$opt" in
    h)
        cat << EOF
requirement: 
  local computer: installed sshfs, ssh-client, git (recommended to use linux or wsl rather than win-sshfs/winfsp),
  local computer: uncommented 'user_allow_other' in /etc/fuse.conf,
  local computer: must be able to reach remote git (ex: github/bitbucket/gitlab) from network,
  deployment server: installed ssh-server,
usage: -s server_ssh_destination -d directory_in_deployment_server -m mountpoint_directory [-n name_of_remote_git] [-b branch_target] [-x] [-o options_for_sshfs] [-w wait_seconds] [-v]
  -s server_ssh_destination = qualified ssh destination (ex: 'produser@production.server.com')
  -d directory_in_deployment_server = path/name of directory in deployment server (ex: '/var/www/html')
  -m mountpoint_directory = mountpoint directory, should be an empty and writable directory
  -n name_of_remote_git = name of 'git remote' URL from where we should clone, default to 'origin'
  -b branch_target = name of target branch, default to 'master'
  -x = run 'git reset --hard HEAD' after deployment in order to rollback if there's any conflict
  -o options_for_sshfs = (array) additional options for sshfs (default to just 'allow_other', ex: '-o port=2222 -o sshfs_debug')
  -w wait_seconds = waiting for ... seconds before executing (default to 5), if you're sure about the operation then just set it to 0
  -v = verbose
additional command:
  -1 'command here' -2 'command here' ... -9 'command here' 
  commands from -1 to -5 will be executed before the pull, while commands from -6 to -9 will be executed after the pull 
  those commands will be executed in local computer inside sshfs mounted workking directory (for example: to define http_proxy before pulling, to apply permission with chmod after pulling)
EOF
        exit 0
        ;;
    s)  server_ssh_destination=$OPTARG
        ;;
    d)  directory_in_deployment_server=$OPTARG
        ;;
    m)  mountpoint_directory=$OPTARG
        ;;
    n)  name_of_remote_git=$OPTARG
        ;;
    b)  branch_target=$OPTARG
        ;;
    1)  pre_command_1=$OPTARG
        ;;
    2)  pre_command_2=$OPTARG
        ;;
    3)  pre_command_3=$OPTARG
        ;;
    4)  pre_command_4=$OPTARG
        ;;
    5)  pre_command_5=$OPTARG
        ;;
    6)  post_command_6=$OPTARG
        ;;
    7)  post_command_7=$OPTARG
        ;;
    8)  post_command_8=$OPTARG
        ;;
    9)  post_command_9=$OPTARG
        ;;
    x)  x_resethead_after=" git reset --hard HEAD ; "
        ;;
    o)  options_for_sshfs+=("$OPTARG")
        ;;
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

function handle_exit() {
  verbose_output "cleaning up..."
  verbose_output "change working directory outside mountpoint directory"
  verbose_output "  \$ cd ~"
  cd ~

  verbose_output "unmounting sshfs"
  verbose_output "  \$ fusermount -u $mountpoint_directory || true"
  fusermount -u $mountpoint_directory || true

  if test $mountpoint_directory_is_exist -eq 0; then
    verbose_output "cleaning up mountpoint_directory"
    verbose_output "  \$ rmdir \"$mountpoint_directory\" || true"
    rmdir "$mountpoint_directory" || true
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
if test "$mountpoint_directory" = ""; then
  verbose_output "generating random mountpoint"
  mountpoint_directory="/tmp/sshfs-`shuf -zer -n20  {A..Z} {a..z} {0..9}`"
fi

if test ! -d "$mountpoint_directory"; then
  verbose_output "creating mountpoint directory at $mountpoint_directory"
  mountpoint_directory_is_exist=0
  mkdir -p "$mountpoint_directory"
fi

verbose_output "parsing sshfs options"
options_for_sshfs_string="-o allow_other"
for val in "${options_for_sshfs[@]}"; do
    options_for_sshfs_string="$options_for_sshfs_string,$val"
done
verbose_output "sshfs options: \"$options_for_sshfs_string\""

# show to user
verbose_output "server_ssh_destination: '$server_ssh_destination'"
verbose_output "directory_in_deployment_server: '$directory_in_deployment_server'"
verbose_output "mountpoint_directory: '$mountpoint_directory'"
verbose_output "name_of_remote_git: '$name_of_remote_git'"
verbose_output "branch_target: '$branch_target'"
verbose_output "wait_seconds: '$wait_seconds'"

echo ">>> executing in $wait_seconds seconds... (press ctrl+c to abort)"
sleep $wait_seconds
echo ">>> executing..."

trap handle_exit 0 SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM

verbose_output "mounting sshfs"
verbose_output "  \$ sshfs $options_for_sshfs_string $server_ssh_destination:$directory_in_deployment_server \"$mountpoint_directory\""
sshfs $options_for_sshfs_string $server_ssh_destination:$directory_in_deployment_server "$mountpoint_directory"

verbose_output "change directory to repository in mounted remote filesystem"
verbose_output "  \$ cd \"$mountpoint_directory\""
cd "$mountpoint_directory"

if test "$pre_command_1" != ""; then
  verbose_output "executing pre_command_1: $pre_command_1"
  $pre_command_1
fi
if test "$pre_command_2" != ""; then
  verbose_output "executing pre_command_2: $pre_command_2"
  $pre_command_2
fi
if test "$pre_command_3" != ""; then
  verbose_output "executing pre_command_3: $pre_command_3"
  $pre_command_3
fi
if test "$pre_command_4" != ""; then
  verbose_output "executing pre_command_4: $pre_command_4"
  $pre_command_4
fi
if test "$pre_command_5" != ""; then
  verbose_output "executing pre_command_5: $pre_command_5"
  $pre_command_5
fi

verbose_output "pull latest commit from remote"
verbose_output "  \$ git pull $name_of_remote_git $branch_target"
git pull $name_of_remote_git $branch_target

if test "$post_command_6" != ""; then
  verbose_output "executing post_command_6: $post_command_6"
  $post_command_6
fi
if test "$post_command_7" != ""; then
  verbose_output "executing post_command_7: $post_command_7"
  $post_command_7
fi
if test "$post_command_8" != ""; then
  verbose_output "executing post_command_8: $post_command_8"
  $post_command_8
fi
if test "$post_command_9" != ""; then
  verbose_output "executing post_command_9: $post_command_9"
  $post_command_9
fi

if test "$x_resethead_after" != ""; then
  verbose_output "hard reset to HEAD (to prevent deploying mid-conflict merge)"
  verbose_output "  \$ git reset --hard HEAD"
  git reset --hard HEAD
fi

