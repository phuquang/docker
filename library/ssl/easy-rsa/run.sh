./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh
./easyrsa gen-req client nopass
./easyrsa sign-req client client


# /workspace/library/ssl/easy-rsa/src/pki/ca.crt
# key: /workspace/library/ssl/easy-rsa/src/pki/private/ca.key
# req: /workspace/library/ssl/easy-rsa/src/pki/reqs/server.req
# key: /workspace/library/ssl/easy-rsa/src/pki/private/server.key
# /workspace/library/ssl/easy-rsa/src/pki/issued/server.crt
# /workspace/library/ssl/easy-rsa/src/pki/dh.pem
# req: /workspace/library/ssl/easy-rsa/src/pki/reqs/client.req
# key: /workspace/library/ssl/easy-rsa/src/pki/private/client.key
# /workspace/library/ssl/easy-rsa/src/pki/issued/client.crt
