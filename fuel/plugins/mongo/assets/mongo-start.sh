set -e

sudo mkdir -p <%= mongoDbDir %>
sudo docker pull mongo:$MONGO_VERSION

set +e

sudo docker update --restart=no mongodb
sudo docker exec mongodb mongod --shutdown
sleep 2
sudo docker rm -f mongodb

set -e

sudo docker run \
  -d \
  --restart=always \
  --publish=127.0.0.1:27017:27017 \
  --volume=<%= mongoDbDir %>:/data/db \
  --volume=/opt/mongodb/mongodb.conf:/mongodb.conf \
  --name=mongodb \
  mongo:$MONGO_VERSION mongod -f /mongodb.conf

limit=20
elaspsed=0

while [[ true ]]; do
  sleep 1
  elaspsed=$((elaspsed+1))
  sudo docker exec mongodb mongo --eval \
    'rs.initiate({_id: "meteor", members: [{_id: 0, host: "127.0.0.1:27017"}]});' \
    && exit 0
done