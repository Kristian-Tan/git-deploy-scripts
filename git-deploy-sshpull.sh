#! /bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.

# default argument value
server_ssh_destination=""
directory_in_deployment_server=""
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
options_for_ssh=() # array, see https://stackoverflow.com/a/20761893/3706717
wait_seconds=5
verbose=0

# read arguments from getopts https://wiki.bash-hackers.org/howto/getopts_tutorial https://stackoverflow.com/a/14203146/3706717
while getopts "hs:d:n:b:1:2:3:4:5:6:7:8:9:xo:w:v" opt; do
    case "$opt" in
    h)
        cat << EOF
requirement: 
  local computer: installed ssh-client,
  deployment server: installed ssh-server, ssh-client, git,
  deployment server: must be able to reach remote git (ex: github/bitbucket/gitlab) from network,
usage: -s server_ssh_destination -d directory_in_deployment_server [-n name_of_remote_git] [-b branch_target] [-x] [-o options_for_ssh] [-w wait_seconds] [-v]
  -s server_ssh_destination = qualified ssh destination (ex: 'produser@production.server.com')
  -d directory_in_deployment_server = path/name of directory in deployment server (ex: '/var/www/html')
  -n name_of_remote_git = name of 'git remote' URL from where we should clone, default to 'origin'
  -b branch_target = name of target branch, default to 'master'
  -x = run 'git reset --hard HEAD' after deployment in order to rollback if there's any conflict
  -o options_for_ssh = (array) additional options for ssh (ex: '-o Port=2222 -o StrictHostKeyChecking=no')
  -w wait_seconds = waiting for ... seconds before executing (default to 5), if you're sure about the operation then just set it to 0
  -v = verbose
additional command:
  -1 'command here' -2 'command here' ... -9 'command here' 
  commands from -1 to -5 will be executed before the pull, while commands from -6 to -9 will be executed after the pull 
  those commands will be executed in remote deployment server (for example: to define http_proxy before pulling, to apply permission with chmod after pulling)
EOF
        exit 0
        ;;
    s)  server_ssh_destination=$OPTARG
        ;;
    d)  directory_in_deployment_server=$OPTARG
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
    o)  options_for_ssh+=("$OPTARG")
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

# fill argument with default value
if test "$server_ssh_destination" = ""; then
  echo ">>> please set server_ssh_destination!"
  exit 1
fi
if test "$directory_in_deployment_server" = ""; then
  echo ">>> please set directory_in_deployment_server!"
  exit 2
fi
if test "$pre_command_1" != ""; then
  pre_command_1=" $pre_command_1 ; "
fi
if test "$pre_command_2" != ""; then
  pre_command_2=" $pre_command_2 ; "
fi
if test "$pre_command_3" != ""; then
  pre_command_3=" $pre_command_3 ; "
fi
if test "$pre_command_4" != ""; then
  pre_command_4=" $pre_command_4 ; "
fi
if test "$pre_command_5" != ""; then
  pre_command_5=" $pre_command_5 ; "
fi
if test "$post_command_6" != ""; then
  post_command_6=" $post_command_6 ; "
fi
if test "$post_command_7" != ""; then
  post_command_7=" $post_command_7 ; "
fi
if test "$post_command_8" != ""; then
  post_command_8=" $post_command_8 ; "
fi
if test "$post_command_9" != ""; then
  post_command_9=" $post_command_9 ; "
fi

verbose_output "parsing ssh options"
options_for_ssh_string=""
for val in "${options_for_ssh[@]}"; do
    options_for_ssh_string="$options_for_ssh_string -o $val"
done
verbose_output "ssh options: \"$options_for_ssh_string\""

# show to user
verbose_output "server_ssh_destination: '$server_ssh_destination'"
verbose_output "directory_in_deployment_server: '$directory_in_deployment_server'"
verbose_output "name_of_remote_git: '$name_of_remote_git'"
verbose_output "branch_target: '$branch_target'"
verbose_output "wait_seconds: '$wait_seconds'"

echo ">>> executing in $wait_seconds seconds... (press ctrl+c to abort)"
sleep $wait_seconds
echo ">>> executing..."

verbose_output "executing ssh command"
verbose_output "  \$ ssh $options_for_ssh_string $server_ssh_destination -t \"$pre_command_1$pre_command_2$pre_command_3$pre_command_4$pre_command_5 cd $directory_in_deployment_server ; git pull $name_of_remote_git $branch_target ; $post_command_6$post_command_7$post_command_8$post_command_9$x_resethead_after\""
ssh $options_for_ssh_string $server_ssh_destination -t "$pre_command_1$pre_command_2$pre_command_3$pre_command_4$pre_command_5 cd $directory_in_deployment_server ; git pull $name_of_remote_git $branch_target ; $post_command_6$post_command_7$post_command_8$post_command_9$x_resethead_after"
