FROM mysql:5.7.37
LABEL author="Phu"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

RUN apt-get update -y && apt-get install wget pv vim zip unzip -y

## Set Timezone Tokyo
RUN apt-get install -y tzdata
ENV TZ Asia/Tokyo
