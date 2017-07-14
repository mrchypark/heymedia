docker kill hm
docker rm hm
docker build -t mrchypark/heymedia .
docker run -it -p 3000:3000 --name hm mrchypark/heymedia