# Pegasys-Stable-AMM

### About Stable-AMM
Pegasys-Stable-AMM is a decentralized automated market maker (AMM) on the Syscoin blockchain, optimized for trading pegged value crypto assets with minimal slippage. Stable-AMM enables cheap, efficient, swift, and low-slippage swaps for traders and high-yield pools for LPs. We believe in collaboration, in building Pegasys as a DeFi lego block, in helping DeFi teams bring AMMs to any blockchain.

## Usage

### Build

```bash
$ forge build
```

### Test

```bash
$ forge test
```

### Deploying contracts to Anvil localhost 

```bash
$ anvil --fork-url https://rpc.syscoin.org
```
Make sure to set your environmental variables as shown in .env.example

```bash
$ source .env
```
Deploy the swap deployer first:

```bash
$ forge script script/deploySwapDeployer.s.sol ---rpc-url http://localhost:8545 \
 --private-key $PRIVATE_KEY --broadcast
```
Router:
```bash
$ forge script script/deployRouter.s.sol --rpc-url http://localhost:8545 \
 --private-key $PRIVATE_KEY --broadcast
```

Then get the address for the swapDeployer and set it to the SWAP_DEPLOYER_ADDRESS key inside your .env file
```bash
$ forge script script/deploySwap.s.sol --rpc-url http://localhost:8545 \
 --private-key $PRIVATE_KEY --broadcast
```
deploySwap and deploySwapFlashloan shown here are generic scripts that are to be adapted as needed for new base and meta pairs.

The flag --rpc-url can be set to point to a live network as needed.
