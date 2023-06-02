-include .env

.PHONY: all test clean deploy-anvil

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remappings
remap :; forge remappings > remappings.txt

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install smartcontractkit/chainlink-brownie-contracts && forge install rari-capital/solmate && forge install foundry-rs/forge-std

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test

snapshot :; forge snapshot

slither :; slither ./src

format :; prettier --write src/**/*.sol && prettier --write src/*.sol

# solhint should be installed globally
lint :; solhint src/**/*.sol && solhint src/*.sol

anvil :; anvil -m 'test test test test test test test test test test test junk'

fund :; cast send ${account} --value 1ether -f 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

# use the "@" to hide the command from your shell
deploy-goerli :; @forge script script/${contract}.s.sol:${contract} --rpc-url ${GOERLI_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vvvv

deploy-base :;
	@forge build
	@forge script script/${contract}.s.sol:${contract} --rpc-url ${BASE_RPC_URL} --private-key ${BASE_PRIVATE_KEY} --verifier-url https://api-goerli.basescan.org/api --etherscan-api-key ${BLOCKSCOUT_API_KEY} --broadcast --verify -vvvv

# This is the private key of account from the mnemonic from the "make anvil" command
deploy-anvil :; @forge script script/${contract}.s.sol:${contract} --rpc-url http://localhost:8545  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
