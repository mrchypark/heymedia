docker kill hm
docker rm hm
docker build -t mrchypark/heymedia .
docker run -p 3000:3000 --name hm mrchypark/heymedia