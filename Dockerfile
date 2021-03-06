#FROM resin/raspberrypi3-node:6.10.3-slim
FROM node:6.11.1-slim

MAINTAINER mrchypark <mrchypark@gmail.com>
# 앱 디렉토리 생성
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# 앱 의존성 설치
COPY app/package.json /usr/src/app/package.json
RUN npm install

COPY app/ /usr/src/app/
EXPOSE 3000
CMD [ "npm", "start" ]
