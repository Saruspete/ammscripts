#!/usr/bin/env bash

function die { echo >&2 "$@"; exit 1; }


# Required env-vars
for var in SITE_{ROOT,FQDN,NAME} RUN_{USER,GROUP}; do
	eval "[[ -z "\$$var" ]] && die \"Undefined environment variable '$var'\""
done

typeset senderEmail="${SITE_EMAIL:-noreply@$SITE_FQDN}"

#
# HTTP Block
#
cat <<EOT
; vim: ft=cfg

[$SITE_NAME]

listen = $SITE_ROOT/priv/phpfpm.sock

listen.allowed_clients = 127.0.0.1
listen.owner = $RUN_USER
listen.group = $RUN_GROUP
listen.mode = 0600

; Unix user/group of processes
user = $RUN_USER
group = $RUN_GROUP

; Process Manager
;pm = dynamic
pm = ondemand

pm.max_children = 50
pm.start_servers = 1
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
pm.process_idle_timeout = 10s

pm.status_path = /phpfpm-status
ping.path = /phpfpm-ping
;ping.response = pong

;request_terminate_timeout = 0
request_slowlog_timeout = 15s
slowlog = $SITE_ROOT/logs/phpfpm/slow.log
access.log = $SITE_ROOT/logs/phpfpm/access.log


; Flags & limits
php_flag[display_errors] = off
php_admin_flag[expose_php] = off
php_admin_flag[log_errors] = on
php_admin_value[error_log] = $SITE_ROOT/logs/phpfpm/error.log
;php_admin_value[memory_limit] = 128M
;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f $senderEmail

; Session
php_value[session.save_handler] = files
php_value[session.save_path] = $SITE_ROOT/temp/session


; Paths
env[TMP] =    $SITE_ROOT/temp/temp
env[TEMP] =   $SITE_ROOT/temp/temp
env[TMPDIR] = $SITE_ROOT/temp/temp


include = $SITE_ROOT/conf/phpfpm/*.conf

EOT

