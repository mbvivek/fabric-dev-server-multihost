# Run this script before starting fabric

# exit on 1st error
set -ev

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}
cd ..
export PATH="$(pwd)/bin:$PATH"
echo "PATH is set to - ${PATH}"
cd ${DIR}

# Remove any previous material
rm -rf crypto-config

# Generate new crypto material with configurations mentioned in crypto-config.yaml
cryptogen generate --config=./crypto-config.yaml

# Set public IP addresses host machines
HOST1="127.0.0.1"
HOST2="192.168.1.250"

# Copy the templates and replace the place holders with actual IP address

cp "${DIR}"/configtx-template.yaml "${DIR}"/configtx.yaml
sed -i -e "s/{IP-HOST-1}/$HOST1/g" "${DIR}"/configtx.yaml

cp ../startFabric-slave-template.sh ../startFabric-host2.sh
sed -i -e "s/{DOCKER-COMPOSE-FILE-NAME}/startFabric-host2/g" ../startFabric-host2.sh
sed -i -e "s/{IP-HOST-1}/$HOST1/g" ../startFabric-host2.sh

# Generate connection profiles
rm -f ../connection-profiles/*

# Connection profile for ORG1 only
cat << EOF > ../connection-profiles/org1-only.json
{
    "name": "org1-only",
    "x-type": "hlfv1",
    "x-commitTimeout": 300,
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "composerchannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org1.example.com": {}
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.example.com"
            ],
            "certificateAuthorities": [
                "ca.org1.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpc://localhost:7050"
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpc://localhost:7051"
        }
    },
    "certificateAuthorities": {
        "ca.org1.example.com": {
            "url": "http://localhost:7054",
            "caName": "ca.org1.example.com"
        }
    }
}
EOF

# Connection profile for ORG1
cat << EOF > ../connection-profiles/org1.json
{
    "name": "org1",
    "x-type": "hlfv1",
    "x-commitTimeout": 300,
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "composerchannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org1.example.com": {},
                "peer0.org2.example.com": {},
                "peer1.org2.example.com": {}
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.example.com"
            ],
            "certificateAuthorities": [
                "ca.org1.example.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.example.com"
            ],
            "certificateAuthorities": [
                "ca.org2.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpc://localhost:7050"
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpc://localhost:7051"
        },
        "peer0.org2.example.com": {
            "url": "grpc://${HOST2}:7051"
        },
        "peer1.org2.example.com": {
            "url": "grpc://${HOST2}:8051"
        }
    },
    "certificateAuthorities": {
        "ca.org1.example.com": {
            "url": "http://localhost:7054",
            "caName": "ca.org1.example.com"
        }
    }
}
EOF

# Connection profile for ORG2 only
cat << EOF > ../connection-profiles/org2-only.json
{
    "name": "org2-only",
    "x-type": "hlfv1",
    "x-commitTimeout": 300,
    "version": "1.0.0",
    "client": {
        "organization": "Org2",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "composerchannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org2.example.com": {},
                "peer1.org2.example.com": {}
            }
        }
    },
    "organizations": {
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.example.com",
                "peer1.org2.example.com"
            ],
            "certificateAuthorities": [
                "ca.org2.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpc://localhost:7050"
        }
    },
    "peers": {
        "peer0.org2.example.com": {
            "url": "grpc://${HOST2}:7051"
        },
        "peer1.org2.example.com": {
            "url": "grpc://${HOST2}:7051"
        }
    },
    "certificateAuthorities": {
        "ca.org2.example.com": {
            "url": "http://${HOST2}:7054",
            "caName": "ca.org2.example.com"
        }
    }
}
EOF

# Connection profile for ORG2 
cat << EOF > ../connection-profiles/org2.json
{
    "name": "org2",
    "x-type": "hlfv1",
    "x-commitTimeout": 300,
    "version": "1.0.0",
    "client": {
        "organization": "Org2",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "composerchannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org1.example.com": {},
                "peer0.org2.example.com": {},
                "peer1.org2.example.com": {}
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.example.com"
            ],
            "certificateAuthorities": [
                "ca.org1.example.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.example.com"
            ],
            "certificateAuthorities": [
                "ca.org2.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpc://localhost:7050"
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpc://localhost:7051"
        },
        "peer0.org2.example.com": {
            "url": "grpc://${HOST2}:7051"
        },
        "peer1.org2.example.com": {
            "url": "grpc://${HOST2}:8051"
        }
    },
    "certificateAuthorities": {
        "ca.org2.example.com": {
            "url": "http://${HOST2}:7054",
            "caName": "ca.org2.example.com"
        }
    }
}
EOF


export FABRIC_CFG_PATH=$PWD
configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block
configtxgen -profile ComposerChannel -outputCreateChannelTx ./composer-channel.tx -channelID composerchannel

ORG1KEY="$(ls crypto-config/peerOrganizations/org1.example.com/ca/ | grep 'sk$')"
ORG2KEY="$(ls crypto-config/peerOrganizations/org2.example.com/ca/ | grep 'sk$')"

echo "ORG1KEY = ${ORG1KEY}"
echo "ORG2KEY = ${ORG2KEY}"

cp docker-compose-master-template.yml docker-compose-host1.yml
sed -i -e "s/{ORG1-CA-KEY}/$ORG1KEY/g" "$(pwd)"/docker-compose-host1.yml

cp docker-compose-slave-template.yml docker-compose-host2.yml
sed -i -e "s/{ORG2-CA-KEY}/$ORG2KEY/g" "$(pwd)"/docker-compose-host2.yml

rm -f *-e
rm -f ../*-e