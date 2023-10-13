

export MSYS_NO_PATHCONV=1
export VERBOSE=false
ORDERER_CA=/opt/src/github.com/hyperledger/ehr-fabric/network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker-compose -f docker-compose.yaml  up -d 2>&1
docker-compose -f docker-compose.yaml up -d
docker ps -a

ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=${ROOTDIR}/../bin:${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}

# remove previous crypto material and config transactions
rm -Rf channel-artifacts/*
rm -Rf organizations/*

echo "######################################################################################################################################################"
echo ""################################################## Generate certificates using cryptogen tool "##################################################"
echo "######################################################################################################################################################"
# ../bin/cryptogen generate --config=crypto-config.yaml --output="crypto-config" 
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

./ccp-generate.sh

generateChannel() {
  ordererProfileName="$1"
  systemChannelName="$2"
  channelName="$3"
  channelProfileName="$4"

  echo "######################################################################################################################################################"
  echo "################################################## Generating Genesis block ##################################################"
  echo "######################################################################################################################################################"
  configtxgen -profile $ordererProfileName -channelID $systemChannelName -outputBlock ./$channelName/genesis.block
  sleep 2
  echo "######################################################################################################################################################"
  echo "################################################## Generating channel configuration transaction ##################################################"
  echo "######################################################################################################################################################"
  configtxgen -profile $channelProfileName -outputCreateChannelTx ./$channelName/channel.tx -channelID $channelName
  sleep 2
}

generateAnchorPeers() {
  channelName="$1"
  orgMSP="$2"
  profileName="$3"
  echo "######################################################################################################################################################"
  echo "################################################## Generating anchor peer update for $orgMSP in channel $channelName ##################################################"
  echo "######################################################################################################################################################"
  sleep 2
  set -x
  configtxgen -profile $profileName -outputAnchorPeersUpdate "./$channelName/$orgMSP-anchors.tx" -channelID "$channelName" -asOrg "$orgMSP"
  if [ "$?" -ne 0 ]; then
FIRST_CHANNEL_NAME=CommonChannel
    echo "Failed to generate anchor peer update for $orgMSP in channel $channelName..."
    exit 1
  fi
  echo "Anchor peer update for $orgMSP generated successfully in channel $channelName."
}


echo "######################################################################################################################################################"
echo "################################################## CHANNEL ONE - COMMON CHANNEL ##################################################"
echo "######################################################################################################################################################"
sleep 5
generateChannel FourOrgsOrdererGenesis firstSystemChannel CommonChannel FourOrgsChannel  
orgMSPArray=("Org1MSP" "Org2MSP" "Org3MSP" "Org4MSP")
# Generate anchor peer updates for each org
for orgMSP in "${orgMSPArray[@]}"; do
  generateAnchorPeers CommonChannel "$orgMSP" FourOrgsChannel
done


echo "######################################################################################################################################################"
echo "################################################## CHANNEL SECOND B/W HOSPITAL AND DOCTOR ##################################################"
echo "######################################################################################################################################################"
sleep 5
generateChannel TwoOrgsOrdererGenesis secondSystemChannel Org1AndOrg2Channel TwoOrgsChannel  
orgMSPArray=("Org1MSP" "Org2MSP")
# Generate anchor peer updates for each org
for orgMSP in "${orgMSPArray[@]}"; do
  generateAnchorPeers Org1AndOrg2Channel "$orgMSP" TwoOrgsChannel
done


echo "######################################################################################################################################################"
echo "################################################## CHANNEL THIRD B/W DOCTOR AND PATIENT ##################################################"
echo "######################################################################################################################################################"
sleep 5
generateChannel TwoOrgOrdererGenesis thirdSystemChannel Org2AndOrg4Channel TwoOrgChannel  
orgMSPArray=("Org2MSP" "Org4MSP")
# Generate anchor peer updates for each org
for orgMSP in "${orgMSPArray[@]}"; do
  generateAnchorPeers Org2AndOrg4Channel "$orgMSP" TwoOrgChannel
done

