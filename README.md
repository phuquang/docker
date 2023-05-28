# Docker

## Thiết lập ban đầu
- Tạo .env từ .env.example
```
cp .env.example .env
```
- Thay tên networks trong docker-compose.yml
- Tìm UID và GID
```
echo $UID
echo $GID
```
hoặc
```
id -u
id -g
```
- Thay biến .env ví dụ user đang hoạt động là pauli có uid là 1000 và gid là 1000
```
DOCKER_USER=pauli
DOCKER_UID=1000
DOCKER_GID=1000
```
- Thay domain trong config
```
___default.conf
__proxy_port.map
__proxy.map
_apache.map
```

## Tạo CERTIFICATE và PRIVATE KEY
```bash
cd library/ssl/rsa/
sh install.sh
```
→ bạn sẽ thấy 2 file localhost.key và localhost.crt ở thư mục library/ssl

## Thiết lập dự án mới
1. Source code
```bash
make sh s=php
laravel new blog
exit
```
2. Tạo config cho web service
```
cd config
cp sample.conf.example blog.conf
```
thay đổi nội dung blog.conf, ví dụ thay thành domain blog.abc.vm
```
server_name blog.abc.vm;#origin
root        /projects/blog/public;
access_log  /var/log/nginx/blog.abc.vm.access.log;
error_log   /var/log/nginx/blog.abc.vm.error.log;
```
3. Load config
```
make reload s=config
```

## Thiết lập dự án mới symfony
```
symfony new --webapp blog
```

# Cấu trúc thư mục
```bash
.
├──📁backups
│  ├──📁mysql
│  └──...
├──📁config
│  ├──📝___default.conf
│  ├──📝__proxy_port.map
│  ├──📝__proxy.map
│  ├──📝_apache.map
│  ├──📝default.conf
│  └──...
├──📁config_apache
│  └──...
├──📁config_supervisor
│  └──...
├──📁library
│  ├──📁apache
│  │  ├──📝bashrc
│  │  └──...
│  ├──📁bash
│  │  ├──📝backup_database.bash
│  │  ├──📝restore_database.bash
│  │  ├──📝bash_aliases
│  │  └──...
│  ├──📁mysql
│  │  ├──📝bashrc
│  │  ├──📝credentials.cnf
│  │  └──...
│  ├──📁php
│  │  ├──📝bashrc
│  │  ├──📝bootstrap.sh
│  │  ├──📝custom.ini
│  │  ├──📝opcache.ini
│  │  ├──📝sendmail.ini
│  │  └──...
│  ├──📁phpmyadmin
│  │  ├──📝config.user.inc.php
│  │  └──...
│  ├──📁proxy
│  │  ├──📝bashrc
│  │  └──...
│  ├──📁ssh
│  │  ├──📝_permission.sh
│  │  ├──📝config
│  │  └──...
│  ├──📁ssl
│  │  ├──📝ssl.conf
│  │  ├──📝localhost.crt
│  │  ├──📝localhost.key
│  │  └──...
│  ├──📁supervisor
│  │  └──...
│  ├──📁ungit
│  │  ├──📝bashrc
│  │  └──...
├──📁logs
│  └──...
├──📁projects
│  └──...
├──📝.env
├──📝docker-compose.yml
├──📝makefile
└──...
```
