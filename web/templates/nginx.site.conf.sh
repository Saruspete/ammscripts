#!/usr/bin/env bash

function die { echo >&2 "$@"; exit 1; }


# Required env-vars
for var in SITE_ROOT SITE_FQDN HTTP_ALLOWED HTTPS_ENABLED; do
	eval "[[ -z "\$$var" ]] && die \"Undefined environment variable '$var'\""
done


typeset opt_listen=""
typeset cfg_server_name=""
if [[ "$SITE_FQDN" == "default" ]]; then
	opt_listen=" default_server"
else
	cfg_server_name="server_name         $SITE_FQDN;"
fi

#
# HTTP Block
#

cat <<EOT
server {
	listen              0.0.0.0:80${opt_listen};
	$cfg_server_name

	#
	# Log management
	#
	access_log          $SITE_ROOT/logs/nginx/access.http.log main;
	error_log           $SITE_ROOT/logs/nginx/error.http.log;

	#
	# Common configuration
	#

	# Allow .well-known/acme-challenge for LetsEncrypt renewal (to avoid proxy)
	location /.well-known/acme-challenge/ {
		root                $SITE_ROOT/html/public;
	}

EOT

if [[ "$HTTP_ALLOWED" == "true" ]]; then
	cat <<EOT
	include             $SITE_ROOT/conf/nginx.common.conf;
EOT

else
	cat <<'EOT'
	# All other URL, redirect on https
	location / {
		return              301 https://$host$request_uri;
	}
EOT
fi

echo "}"
echo

#
# HTTPS Block
#

if [[ "$HTTPS_ENABLED" == "true" ]]; then

cat <<EOT
server {
	listen              0.0.0.0:443 ssl$listen_opts;
	$cfg_server_name

	#
	# SSL Configuration
	#
	ssl_certificate     $SITE_ROOT/priv/fullchain.pem;
	ssl_certificate_key $SITE_ROOT/priv/privkey.pem;

	#
	# Log management
	#
	access_log          $SITE_ROOT/logs/nginx/access.https.log main;
	error_log           $SITE_ROOT/logs/nginx/error.https.log;

	#
	# Common configuration
	#
	include             $SITE_ROOT/conf/nginx.common.conf;
}

EOT
fi
