

# TODO: Fix this per distribution
typeset fpmCfgDst="/etc/php-fpm.conf"


cat >| "$fpmCfgDst" <<-EOT

;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

; All relative paths in this configuration file are relative to PHP's install
; prefix (/usr/lib64/php7.4). This prefix can be dynamically changed by using the
; '-p' argument from the command line.


;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
;pid = run/php-fpm.pid
;error_log = log/php-fpm.log
;syslog.facility = daemon
;syslog.ident = php-fpm

;log_level = notice
;log_limit = 4096
log_buffering = no

; If this number of child processes exit with SIGSEGV or SIGBUS within the time
; interval set by emergency_restart_interval then FPM will restart.
;emergency_restart_threshold = 10

; Interval of time used by emergency_restart_interval to determine when
; a graceful restart will be initiated.  This can be useful to work around
; accidental corruptions in an accelerator's shared memory.
;emergency_restart_interval = 10

; Time limit for child processes to wait for a reaction on signals from master.
;process_control_timeout = 0

; The maximum number of processes FPM will fork. This has been designed to control
; the global number of processes when using dynamic PM within a lot of pools.
; process.max = 128

; Specify the nice(2) priority to apply to the master process (only if set)
; process.priority = -19

;daemonize = yes
;rlimit_files = 1024
;rlimit_core = 0
;events.mechanism = epoll
;systemd_interval = 10

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

include = $SITES_ROOT/*/conf/phpfpm.conf

EOT
