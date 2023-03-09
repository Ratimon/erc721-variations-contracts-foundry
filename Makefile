-include .env

# delete-deployment path1=test path2=1337
delete-deployment:
	DEPLOYMENT_DIRECTORY_NAME=$(call deployment_directory,$(path1),$(path2)) bash ./utils/clean-deployment.sh

# spin node
anvil-node:
	anvil --chain-id 1337

fork-node: 
	ETH_RPC_URL=$(call network,mainnet) FORK_BLOCK_NUMBER=$(call block_number) LOCAL_CHAIN_ID=$(call local_chain_id)  bash ./utils/node.sh

generate-merkle-root:
	yarn hardhat getRootHash

# Test
unit-test-FixedPricePreSale:
	forge test --match-path test/FixedPricePreSale.t.sol -vvv

unit-test-ERC721Game:
	forge test --match-path test/ERC721Game.t.sol -vvv
	
unit-test-NFTStaking:
	forge test --match-path test/NFTStaking.t.sol -vvv

unit-test-IsIdPrime:
	forge test --match-path test/IsIdPrime.t.sol -vvv

snapshot-NFTStaking:
	forge snapshot --match-path test/NFTStaking.t.sol --no-match-test "test(Fork)?(Fuzz)?_RevertWhen_\w{1,}?"

# Audit
coverage:
	forge coverage --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage

slither-findings-ERC20Game:
	slither src/ERC20Game.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"

slither-storage-ERC20Game:
	slither-read-storage src/ERC20Game.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"

slither-invariant-ERC20Game:
	slither-prop src/ERC20Game.sol --contract ERC20Game --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"

slither-validate-ERC20Game:
	slither-check-erc src/ERC20Game.sol ERC20Game --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"



slither-findings-ERC721Game:
	slither src/ERC721Game.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"
	
slither-storage-ERC721Game:
	slither-read-storage src/ERC721Game.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"

slither-invariant-ERC721Game:
	slither-prop src/ERC721Game.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"



slither-findings-NFTStaking:
	slither src/NFTStaking.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"
	
slither-storage-NFTStaking:
	slither-read-storage src/NFTStaking.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"

slither-invariant-NFTStaking:
	slither-prop src/NFTStaking.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"

slither-findings-ERC721Presale:
	slither src/ERC721Presale.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"

slither-findings-FixedPricePreSale:
	slither src/FixedPricePreSale.sol --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @main/=src/"


check-api-key:
ifndef ALCHEMY_API_KEY
	$(error ALCHEMY_API_KEY is undefined)
endif

define deployment_directory
deployments/$1/$2
endef

# Returns the URL to deploy to a hosted node.
# Requires the ALCHEMY_API_KEY env var to be set.
# The first argument determines the network (mainnet / rinkeby / ropsten / kovan / goerli)
define network
https://eth-$1.g.alchemy.com/v2/${ALCHEMY_API_KEY}
endef

define local_network
http://127.0.0.1:$1
endef

define block_number
${FORK_BLOCK_NUMBER}
endef

define sender_address
${SENDER_ADDRESS}
endef

define local_chain_id
${LOCAL_CHAIN_ID}
endef
