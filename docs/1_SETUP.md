# 🏗 Setting up the environment

## Installing foundry

### 📱 MacOS

Install the latest release by running:

```bash
curl -L https://foundry.paradigm.xyz | bash
```

This will download **foundryup**. Then install Foundry by running:

```bash
foundryup
```

> :warning: *Tip**

> To update **foundryup** after installation, simply run **foundryup** again, and it will update to the latest Foundry release. You can also revert to a specific version of Foundry with **foundryup -v $VERSION**.

## 🏗 Quick Guide & Tutorial to Use Template

Make sure [Foundry](https://book.getfoundry.sh/) is installed.

1. Clone the repository:

```bash
git clone <link>
```

2. Install the submodule dependencies defined in `.gitmodules` :

```bash
forge install
```

3.  Add `.env` file

We also create the following `.env` at the root directory :

```env
ETHERSCAN_KEY=
ALCHEMY_API_KEY=
FORK_BLOCK_NUMBER=
SENDER_ADDRESS=
LOCAL_CHAIN_ID=1337
MAINNET_RPC_URL=
LOCAL_RPC_URL=http://127.0.0.1:8545
ARBITRUM_RPC_URL=
OPTIMISM_RPC_URL=
```

> :warning: **Warning**

>  The address from MNEMONIC `"test test test test test test test test test test test junk"` is already funded with ETH in `anvil` network.

> :warning: *Tip**

> We can go to [vanity-eth](https://vanity-eth.tk/) in order to generate such Private key

> We can go to [iancoleman.io](https://iancoleman.io/bip39/) in order to generate such Mneomic key

4. Compile `**.sol` files

```bash
forge b
```

5. Spin up a local anvil node in another terminal.

```bash
make anvil-node
```

or optionally fork data from nainnet to the local node

```bash
make fork-node
```

6. Deploy sets of smart contracts to local network

```bash
make void-deploy
```

or optionally deploy to the forked local node

```bash
make fork-deploy
```

7. Test against written test suites

```bash
make unit-test-...
```