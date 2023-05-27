wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.2/EasyRSA-3.1.2.tgz
tar zxf EasyRSA-3.1.2.tgz
rm -f EasyRSA-3.1.2.tgz
mv EasyRSA-3.1.2 src
cp vars src/
cp run src/
echo "Please: cd src && sh run.sh"
