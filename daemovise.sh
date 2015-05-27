#!/bin/bash

[ -e "env.sh" ] && source env.sh

command=$1
shift

logdir='logs'
rundir='run'

logfile() {
   local name=$(basename "$1")
   echo "$logdir/$name.log"
}

pidfile() {
   local name=$(basename "$1")
   echo "$rundir/$name.pid"
}

start() {
   mkdir -p "$logdir" "$rundir"
   local name=$1
   shift
   local logfile=$(logfile "$name")
   local pidfile=$(pidfile "$name")
   DAEMOVISE_PIDFILE="$pidfile" ${DAEMOVISE:-daemovise} \
      --append \
      --exit-code 100 \
      --outputs "$logfile" \
      --pidfile "$pidfile" \
      --throttle 1 \
      --timeout 30 \
      -- "$@"
}

_kill() {
   local signal=$1
   local pidfile=$(pidfile "$2")
   if [ ! -e "$pidfile" ] ; then
      echo "pid file not found" >&2
      return 0
   fi
   local pid=$(<"$pidfile")
   if [ -n "$pid" ] ; then
      kill "$signal" "$pid"
      return $?
   else
      echo "pid file is empty" >&2
      return 1
   fi
}

stop() {
   _kill -TERM "$1"
}

hup() {
   _kill -HUP "$1"
}

status() {
   local pidfile=$(pidfile "$1")
   if [ ! -e "$pidfile" ] ; then
      echo "process not running"
      return 0
   fi
   local pid=$(<"$pidfile")
   if [ -n "$pid" ] ; then
      ps -p "$pid" >/dev/null 2>&1
      local dv=$(
         perl -nle 'print for split /\x{00}/g' /proc/$pid/environ \
         | sed -ne 's/DAEMOVISE_PIDFILE=//p'
      )
      if [ "$pidfile" == "$dv" ] ; then
         echo "supervisor process is running"
      else
         echo "supervisor process is not running, pidfile is stale"
      fi
   else
      echo "pid file is empty" >&2
      return 1
   fi
}

case "$command" in
   (start)
      start "$1" "$@"
      ;;
   (start=*)
      name=${command#*=}
      start "$name" "$@"
      ;;
   (stop)
      stop "$1"
      ;;
   (hup)
      hup "$1"
      ;;
   (status)
      status "$1"
      ;;
   (*)
      echo "$0 start/stop/hup/status command args..." >&2
      exit 1
      ;;
esac
