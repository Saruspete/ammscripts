#!/usr/bin/env bash


function die { echo >&2 "$@"; exit 1; }

[[ -z "$SITE_ROOT" ]] && die "Undefined variable 'SITE_ROOT'"
[[ -z "$SITE_FQDN" ]] && die "Undefined variable 'SITE_FQDN'"


cat <<-EOT
	#
	# root configuration
	#
	root            $SITE_ROOT/html/public;
	include         $SITE_ROOT/conf/nginx/*.conf;
	
	index           index.html index.htm index.php;
	
	# Store all elements in local path
	client_body_temp_path     $SITE_ROOT/temp/nginx/client_body 1 2;
	# For reading client request. In case of long cookies
	client_header_buffer_size 4k;
	# Timeout for client to send the whole request header (anti-slowloris)
	client_header_timeout 60s;
	
	# Special files
	location = /favicon.ico {
		log_not_found   off;
		access_log      off;
	}
	
	location ~ /\.ht {
		deny all;
	}
	
	
	#
	# Configuration to be used in nginx/ include folder
	#
	
	# Uploading big files
	#location /upload {
	#    # Time between 2 successive read, not the whole body
	#    client_body_timeout 60s;
	#    # Max size of client request body. Def: 1m, Disable: 0
	#    client_max_body_size 0;
	#
	#    # FastCGI Configuration
	#    fastcgi_buffering    off;
	#    fastcgi_buffers      96 32k;
	#    fastcgi_buffer_size  32k;
	#    fastcgi_max_temp_file_size 0;
	#    fastcgi_keep_conn    on;
	#}
	
	# Streaming data
	# location /video/ {
	#    # Async I/O. Can be "threads" = does not consume a worker
	#    aio            on;
	#    # Async I/O when aio=threads and for temp files
	#    aio_write      on;
	#    # Direct I/O (no cache) when files are grater than specified size.
	#    # (multiple of 512 for most FS, of 4K for XFS). Disables sendfile.
	#    directio       512;
	#    output_buffers 1 128k;
	#    # When aio+sendfile, aio for files >= directio, sendfile for smaller
	#    sendfile on;
	#}
	EOT

