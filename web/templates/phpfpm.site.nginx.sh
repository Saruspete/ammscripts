#!/usr/bin/env bash

function die { echo >&2 "$@"; exit 1; }


# Required env-vars
for var in SITE_{ROOT,FQDN} RUN_{USER,GROUP} HTTP_ALLOWED HTTPS_ENABLED; do
	eval "[[ -z "\$$var" ]] && die \"Undefined environment variable '$var'\""
done


#
# HTTP Block
#
cat <<EOT
location ~ \.php$ {
    fastcgi_pass   unix:${SITE_ROOT}/priv/phpfpm.sock;
    try_files      \$uri =404;
    fastcgi_index  index.php;
    include        fastcgi.conf;
}

EOT

