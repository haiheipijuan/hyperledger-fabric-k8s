#!/bin/bash

ARCH=x86_64
BASEIMAGE_RELEASE=0.3.1
BASE_VERSION=1.0.0
PROJECT_VERSION=1.0.0-rc1

# For testing v1.0.0-rc1 images
IMG_VERSION=v1.0.0-rc1

echo_b "Downloading images from DockerHub... need a while"

# TODO: we may need some checking on pulling result?
docker pull yeasy/hyperledger-fabric-base:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-peer:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-orderer:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-ca:$IMG_VERSION \
  && docker pull hyperledger/fabric-couchdb:$ARCH-1.0.0-beta

# Only useful for debugging
# docker pull yeasy/hyperledger-fabric

echo_b "Rename images with official tags..."
docker tag yeasy/hyperledger-fabric-peer:$IMG_VERSION hyperledger/fabric-peer \
  && docker tag yeasy/hyperledger-fabric-peer:$IMG_VERSION hyperledger/fabric-tools \
  && docker tag yeasy/hyperledger-fabric-orderer:$IMG_VERSION hyperledger/fabric-orderer \
  && docker tag yeasy/hyperledger-fabric-ca:$IMG_VERSION hyperledger/fabric-ca \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-ccenv:$ARCH-$PROJECT_VERSION \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-baseos:$ARCH-$BASEIMAGE_RELEASE \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-baseimage:$ARCH-$BASEIMAGE_RELEASE

#uncomment this if you didn't setup driving-files mannually
# bash driving-files/prepare-files.sh

echo "Deploying orderer"
kubectl create -f local/orderer.yaml
sleep 10

echo "Deploying Peer0"
kubectl create -f local/peer0.yaml
sleep 10

echo "Deploying rest of the Peers"
kubectl create -f local/peer1.yaml -f local/peer2.yaml -f local/peer3.yaml

sleep 5

echo "Deploying Cli"
kubectl create -f local/cli.yaml

echo "**********Deployment done successfully**********"
