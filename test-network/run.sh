

export MSYS_NO_PATHCONV=1
ORDERER_CA=/opt/src/github.com/anurag-iitk/ehr-fabric/ehr_fabric/test-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker-compose -f docker-compose.yaml  up -d 2>&1
docker-compose -f docker-compose.yaml up -d
docker ps -a

export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

CHANNEL_NAME=commonChannel

SYS_CHANNEL=first-system-channel
# remove previous crypto material and config transactions
rm -Rf channel-artifacts/*
rm -Rf organizations/*

echo "Generate certificates using cryptogen tool"

# ../bin/cryptogen generate --config=crypto-config.yaml --output="crypto-config" 

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi


./ccp-generate.sh


# echo "=============== Generating Genesis block ==================="

# generate genesis block for orderer
# configtxgen -profile FourOrgsOrdererGenesis -channelID $SYS_CHANNEL -outputBlock ./channel-artifacts/genesis.block
# if [ "$?" -ne 0 ]; then
#   echo "Failed to generate orderer genesis block..."
#   exit 1
# fi

# echo "=================== Generating channel configuration transaction ========================="
# set -x
# configtxgen -profile FourOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
# if [ "$?" -ne 0 ]; then
#   echo "Failed to generate channel configuration transaction..."
#   exit 1
# fi

# echo "======================== Generating anchor peer update for Org1MSP ================================="
# set -x
# configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

# if [ "$?" -ne 0 ]; then
#   echo "Failed to generate anchor peer update for Org1MSP..."
#   exit 1
# fi

# echo "======================== Generating anchor peer update for Org2MSP ================================="
# set -x
# configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

# if [ "$?" -ne 0 ]; then
#   echo "Failed to generate anchor peer update for Org2MSP..."
#   exit 1
# fi

# echo "======================== Generating anchor peer update for Org3MSP ================================="
# set -x
# configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP

# if [ "$?" -ne 0 ]; then
#   echo "Failed to generate anchor peer update for Org3MSP..."
#   exit 1
# fi

# echo "======================== Generating anchor peer update for Org4MSP ================================="
# set -x
# configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org4MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org4MSP

# if [ "$?" -ne 0 ]; then
#   echo "Failed to generate anchor peer update for Org4MSP..."
#   exit 1
# fi

sleep 5

# create a channel
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/src/github.com/anurag-iitk/ehr-fabric/ehr_fabric/test-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" peer0.org1.example.com peer  channel create -o orderer.example.com:7050 -c mychannel -f /channel-artifacts/channel.tx --tls true --cafile /opt/src/github.com/anurag-iitk/ehr-fabric/ehr_fabric/test-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
