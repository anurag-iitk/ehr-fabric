

export MSYS_NO_PATHCONV=1
ORDERER_CA=/opt/src/github.com/hyperledger/ehr-fabric/network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker-compose -f docker-compose.yaml  up -d 2>&1
docker-compose -f docker-compose.yaml up -d
docker ps -a

export PATH=$GOPATH/src/github.com/hyperledger/ehr-fabric/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

FIRST_CHANNEL_NAME=commonChannel
SECOND_CHANNEL_NAME=Org1AndOrg2Channel
THIRD_CHANNEL_NAME=Org2AndOrg4Channel

SYS_FIRST_CHANNEL=first-system-channel
SYS_SECOND_CHANNEL=second-system-channel
SYS_THIRD_CHANNEL=third-system-channel
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

sleep 2


./ccp-generate.sh


echo "################################# CHANNEL ONE #######################################"
sleep 3
echo "=============== Generating Genesis block ==================="
sleep 2
generate genesis block for orderer
configtxgen -profile FourOrgsOrdererGenesis -channelID $SYS_FIRST_CHANNEL -outputBlock ./channel-artifacts/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

echo "=================== Generating channel configuration transaction ========================="
sleep 2
set -x
configtxgen -profile FourOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $FIRST_CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "======================== Generating anchor peer update for Org1MSP ================================="
sleep 2
set -x
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $FIRST_CHANNEL_NAME -asOrg Org1MSP

if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

echo "======================== Generating anchor peer update for Org2MSP ================================="
sleep 2
set -x
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $FIRST_CHANNEL_NAME -asOrg Org2MSP

if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi

echo "======================== Generating anchor peer update for Org3MSP ================================="
sleep 2
set -x
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $FIRST_CHANNEL_NAME -asOrg Org3MSP

if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org3MSP..."
  exit 1
fi

echo "======================== Generating anchor peer update for Org4MSP ================================="
sleep 2
set -x
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org4MSPanchors.tx -channelID $FIRST_CHANNEL_NAME -asOrg Org4MSP

if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org4MSP..."
  exit 1
fi

# sleep 5

# create a channel
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/src/github.com/hyperledger/ehr-fabric/network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" peer0.org1.example.com peer  channel create -o orderer.example.com:7050 -c mychannel -f /channel-artifacts/channel.tx --tls true --cafile /opt/src/github.com/hyperledger/ehr-fabric/network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
# peer0.org3
# docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/src/github.com/hyperledger/ehr-fabric/network/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel join -b mychannel.block



echo "################################# SECOND CHANNEL #######################################"
sleep 3


echo "=============== Generating Second channel Genesis block ==================="
sleep 2

generate genesis block for orderer
configtxgen -profile TwoOrgsOrdererGenesis -channelID $SYS_SECOND_CHANNEL -outputBlock ./channel-artifacts-2/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate second orderer genesis block..."
  exit 1
fi

echo "=================== Generating Second channel configuration transaction ========================="
sleep 2
set -x
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts-2/channel.tx -channelID $SECOND_CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate second channel configuration transaction..."
  exit 1
fi

echo "======================== Generating Second channel anchor peer update for Org1MSP ================================="
sleep 2
set -x
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts-2/Org1MSPanchors.tx -channelID $SECOND_CHANNEL_NAME -asOrg Org1MSP

if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update second channel for Org1MSP..."
  exit 1
fi

echo "======================== Generating Second channel anchor peer update for Org2MSP ================================="
sleep 2
set -x
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts-2/Org2MSPanchors.tx -channelID $SECOND_CHANNEL_NAME -asOrg Org2MSP

if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update second channel for Org2MSP..."
  exit 1
fi


echo "################################# CHANNEL THIRD #######################################"
sleep 5


echo "=============== Generating Third channel Genesis block ==================="
sleep 2

generate genesis block for orderer
configtxgen -profile TwoOrgOrdererGenesis -channelID $SYS_THIRD_CHANNEL -outputBlock ./channel-artifacts-3/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate third orderer genesis block..."
  exit 1
fi

echo "=================== Generating Third channel configuration transaction ========================="
sleep 2
set -x
configtxgen -profile TwoOrgChannel -outputCreateChannelTx ./channel-artifacts-3/channel.tx -channelID $THIRD_CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate third channel configuration transaction..."
  exit 1
fi

echo "======================== Generating Third channel anchor peer update for Org2MSP ================================="
sleep 2
set -x
configtxgen -profile TwoOrgChannel -outputAnchorPeersUpdate ./channel-artifacts-3/Org2MSPanchors.tx -channelID $THIRD_CHANNEL_NAME -asOrg Org2MSP

if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update third channel for Org2MSP..."
  exit 1
fi

echo "======================== Generating Third channel anchor peer update for Org4MSP ================================="
sleep 2
set -x
configtxgen -profile TwoOrgChannel -outputAnchorPeersUpdate ./channel-artifacts-3/Org4MSPanchors.tx -channelID $SECOND_CHANNEL_NAME -asOrg Org4MSP

if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update third channel for Org4MSP..."
  exit 1
fi