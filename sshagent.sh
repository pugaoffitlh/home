#this script is meant to be sourced.

#only start ssh-agent if you're _not_ the root user (admin)
if [ ! 'root' = "${USER}" ]; then
  #check if it's already running, if not then start it
  if ! pgrep ssh-agent &> /dev/null && ! uname -rms | grep Darwin &> /dev/null; then
    eval "$(ssh-agent -t 3600)" > /dev/null
  fi
  #already running; environment vars not set; try to attach to existing session
  if [ -z "${SSH_AUTH_SOCK}" -o -z "${SSH_AGENT_PID}" ]; then
      SSH_AUTH_SOCK="$(ls -l /tmp/ssh-*/agent.* 2> /dev/null | grep "${USER}" | awk '{print $9}' | tail -n1)"
      SSH_AGENT_PID="$(echo ${SSH_AUTH_SOCK} | cut -d. -f2)"
  fi
  #could not find session files so try to detect them using lsof
  #see man lsof; it lists open file handles for a process
  if [ -z "${SSH_AUTH_SOCK}" -o -z "${SSH_AGENT_PID}" ]; then
    SSH_AUTH_SOCK="$(lsof -p "$(pgrep ssh-agent | tr '\n' ',')" | grep "${USER}" | grep -e "ssh-[^/]*/agent\.[0-9]\+$" | tr ' ' '\n' | tail -n1)"
    SSH_AGENT_PID="$(echo ${SSH_AUTH_SOCK} | cut -d. -f2)"
  fi
  #export vars for use in other programs
  [ -n "${SSH_AUTH_SOCK}" ] && export SSH_AUTH_SOCK
  [ -n "${SSH_AGENT_PID}" ] && export SSH_AGENT_PID
fi
