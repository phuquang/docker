openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ../localhost.key -out ../localhost.crt -config localhost.conf
# cp localhost.crt /etc/ssl/certs/localhost.crt
# cp localhost.key /etc/ssl/private/localhost.key
