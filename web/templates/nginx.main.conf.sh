#!/usr/bin/env bash


cat <<EOT

user              $RUN_USER $RUN_GROUP;
worker_processes  auto;

error_log         /var/log/nginx/error.log;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include           /usr/share/nginx/modules/*.conf;

events {
	worker_connections  1024;
	use                 epoll;
}

http {
	include          /etc/nginx/mime.types;
	default_type     application/octet-stream;
	log_format main
	  '\$remote_addr - \$remote_user [\$time_local] '
	  '"\$request" \$status \$bytes_sent '
	  '"\$http_referer" "\$http_user_agent" '
	  '"\$http_x_forwarded_for" "\$gzip_ratio"';

	client_header_timeout       10m;
	client_body_timeout         10m;
	send_timeout                10m;
	keepalive_timeout           75 20;

	connection_pool_size        256;
	request_pool_size           4k;
	client_header_buffer_size   1k;
	large_client_header_buffers 4 2k;
	output_buffers              1 32k;
	postpone_output             1460;

	gzip                        on;
	gzip_disable                "msie6";
	sendfile                    on;
	tcp_nopush                  on;
	tcp_nodelay                 on;

	ignore_invalid_headers      on;
	server_tokens               off;

	#


	# Secure protocols
	ssl_protocols               TLSv1 TLSv1.1 TLSv1.2;
	ssl_prefer_server_ciphers   on;
	ssl_dhparam                 /etc/nginx/dhparam.pem; # openssl dhparam -dsaparam -out /etc/nginx/dhparam.pem 4096
	ssl_ciphers                 ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA;
	ssl_ecdh_curve              secp384r1;
	ssl_session_timeout         10m;
	ssl_session_cache           shared:SSL:10m;
	ssl_session_tickets         off;
	ssl_stapling                on;
	ssl_stapling_verify         on;
#    resolver                    \$DNS-IP-1 \$DNS-IP-2 valid=300s;
#    resolver_timeout            5s;
#    add_header                  Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
	# https://developer.mozilla.org/en-US/docs/HTTP/X-Frame-Options
	add_header                  X-Frame-Options DENY;
	# https://www.owasp.org/index.php/List_of_useful_HTTP_headers
	add_header                  X-Content-Type-Options nosniff;
	add_header                  X-XSS-Protection "1; mode=block";
	add_header                  X-Robots-Tag none;

	index                       index.html;
	include                     $SITES_ROOT/*/conf/nginx.conf;

}

EOT
