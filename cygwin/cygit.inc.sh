##################################
#
# Use SSH Git repository cloning in Cygwin on Windows 10+
#
# Requires git and openssh are installed on Cygwin
#
# Usage:
#     cygit-start <private-key>
#            Start Cygwin ssh-agent and adds <private-key> to agent
#
#     cygit-stop
#            Stops all running ssh-agent processes
#
#     cygit-clone <repo-ssh>
#            Clones Git repository provided the <repo-ssh> clone url
#
##################################

cygit-start() {
    if [ -z "$1" ]; then
        echo "usage: cygit-start <private-key>"
    else
        eval $(/usr/bin/ssh-agent -s)
        /usr/bin/ssh-add $1
    fi
}

cygit-stop() {
    PIDS="$(ps -ef | grep ssh-agent | awk '{ print $2 }')"

    if [ -z "$PIDS" ]; then
        echo "No ssh-agent processes running"
    else
        while read PID; do
            echo -n "Stopping ssh-agent ($PID)..."
            kill -9 $PID
            echo "done"
        done <<< "$PIDS"
    fi
}

cygit-clone() {
    if [ -z "$1" ]; then
        echo "usage: cygit-clone <repo-ssh>"
    else
        GIT_SSH="/usr/bin/ssh" git clone $@
    fi
}
