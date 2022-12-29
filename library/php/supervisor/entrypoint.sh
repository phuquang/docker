#!/bin/sh
set -e
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
