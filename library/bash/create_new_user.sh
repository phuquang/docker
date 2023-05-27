sudo useradd -m -d /home/ubuntu2 -s /bin/bash ubuntu2
sudo passwd ubuntu2
sudo usermod -a -G sudo ubuntu2
su ubuntu2
sudo usermod -a -G docker ubuntu2
newgrp docker
