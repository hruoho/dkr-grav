#!/usr/bin/bash
chown nginx:www-data .
chown -R nginx:www-data *
find . -type f | xargs chmod 664
find . -type d | xargs chmod 775
find . -type d | xargs chmod +s
umask 0002
