FROM resin/rpi-node:6.5-slim-20170331 

MAINTAINER mrchypark <mrchypark@gmail.com>
# 앱 디렉토리 생성
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# 앱 의존성 설치
COPY app/ /usr/src/app
RUN npm install
EXPOSE 8000
CMD [ "npm", "start" ]
