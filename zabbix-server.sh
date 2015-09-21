#! /bin/sh
### BEGIN INIT INFO
# Provides:          zabbix-server
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:	     0 1 6
# Should-Start:      mysql
# Should-Stop:       mysql
# Short-Description: Start zabbix-server daemon
### END INIT INFO

set -e

NAME=zabbix_server
DAEMON=/usr/sbin/$NAME
DESC="Zabbix server"

test -x $DAEMON || exit 0

DIR=/var/run/zabbix
PID=$DIR/$NAME.pid
RETRY=15

if test ! -d "$DIR"; then
  mkdir "$DIR"
  chown -R zabbix:zabbix "$DIR"
fi

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin"

# define LSB log_* functions.
. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "Starting $DESC" "$NAME"
	start-stop-daemon --oknodo --start --pidfile $PID \
	  --exec $DAEMON >/dev/null 2>&1
    case "$?" in
        0) log_end_msg 0 ;;
        *) log_end_msg 1; exit 1 ;;
    esac
	;;
  stop)
    log_daemon_msg "Stopping $DESC" "$NAME"
	start-stop-daemon --oknodo --stop --pidfile $PID --retry $RETRY
    case "$?" in
        0) log_end_msg 0 ;;
        *) log_end_msg 1; exit 1 ;;
    esac
	;;
  status)
    status_of_proc -p "$PID" "$DAEMON" "$NAME" && exit 0 || exit $?
    ;;
  restart|force-reload)
	$0 stop
	$0 start
	;;
  *)
    echo "Usage: /etc/init.d/$NAME {start|stop|restart|force-reload}" >&2
	exit 1
	;;
esac

exit 0
