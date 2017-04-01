docker kill hm
docker rm hm
docker build -t mrchypark/heymedia .
docker run -p 9000:8000 --name hm mrchypark/heymedia