# Bridging funds using Reactive Network technology 

## Overview

The Reactive Bridge App allows users to bridge funds from a origin chain to destination chain. This is acomplished using [Reactive Network technology](https://reactive.network). It is a system that operates between origin chain (or any other layer), the Reactive Network and destination chain (or any other layer). These requests are being handled by a corresponding contract on the Reactive Network. User deposits funds to the bridge origin contract, which then emits a request to the reactive contract. The reactive contract processes the request by emitting callback to destination contract, which is sending funds to the corresponding destination contract and chain.

## Frontend
This is the demo version of the bridge application, showcasing how to trigger value bridging between two chains. The frontend is configured to work with already deployed contracts, which are available for users to interact with. User can open the frontend/index.html in browser to interact with the contracts.

**How it works**
Frontend demonstrates the process of bridging Ether from wallet on origin chain to wallet on destination chain. The current demo setup is configured for using Sepolia as both the origin and destination chain. The contracts from repository have been deployed on Sepolia and Reactive Network (Kopli testnet), and users can simulate the entire bridge process by sending Ether from their browser-integrated wallet (such as MetaMask) to the origin contract and receiving sent ether in their wallet on destination chain. To try the bridge with different chains, change constant contractAddress in the frontend/index.html file. You will need to deploy contracts with new addresses on chains you want to bridge between.

**Key Features**
* Browser Wallet Integration: Users can interact with the dApp using a browser wallet, such as MetaMask, to send Ether and initiate the bridge process.
* Simulated Bridge Process: Although both contracts are deployed on the Sepolia testnet, the demo simulates the full cross-chain bridge experience.
* Deployed Contracts: Users can directly interact with the already deployed origin, target and reactive contracts to see how the bridging flow works in real-time.

The frontend is designed to give users a hands-on demonstration of how a cross-chain value transfer might function using a decentralized bridge, while staying within the confines of the Sepolia testnet for simplicity.

## Smart contracts

The demo involves three contracts:

1. **Origin Chain Contract:** `BridgeOrigin` handles Ether payment requests and emits `BridgeDepositRequested` events containing details of the transaction.

2. **Reactive Contract:** `ReactiveBridge` operates on the Reactive Network. It subscribes to events on the origin chain, processes callbacks and triggers destination chain contract to send Ether to the appropriate receivers based on external `BridgeRequest` events.

2. **Destination Chain Contract:** `BridgeDestination` operates on the destination chain. It receives callbacks from reactive contract and transfers Ether to the appropriate receivers.


## Deployment & Testing

This script guides you through deploying and testing the Reactive Bridge app demo on the Sepolia Testnet as origin and destination chains. Ensure the following environment variables are configured appropriately before proceeding with this script:

* `ORIGIN_RPC`
* `ORIGIN_PRIVATE_KEY`
* `BRIDGE_ORIGIN_ADDR`
* `DESTINATION_RPC`
* `DESTINATION_PRIVATE_KEY`
* `BRIDGE_DESTINATION_ADDR`
* `REACTIVE_RPC`
* `BRIDGE_REACTIVE_ADDR`
* `REACTIVE_PRIVATE_KEY`
* `SYSTEM_CONTRACT_ADDR`

If origin chain and destination chains are Sepolia you can use the recommended Sepolia RPC URL: `https://rpc2.sepolia.org`. Youn can find more about React system contract  0x0000000000000000000000000000000000FFFFFF [here](https://dev.reactive.network/system-contract). 

Frontend is configured to work with already deployed contracts on Sepolia and Kopli testnet:
BRIDGE_ORIGIN_ADDR=0x65DA6c43A59551f87cE6D46a90062c5e66E6aAf0
BRIDGE_DESTINATION_ADDR=0xEb77CAd405c62d7e9A2B4F1cDa35Cf3C4c1300a9
BRIDGE_REACTIVE_ADDR=0x68E33049B621D9F3482f522f9Ff446Fa2e72592f

### Step 1
Deploy the `BridgeOrigin` to origin chain and assign the `Deployed to` address from the response to `BRIDGE_ORIGIN_ADDR`. 

```bash
forge create --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY src/reactivebridge/BridgeOrigin.sol:BridgeOrigin
```

### Step 2
Deploy the `BridgeDestinaton` to destination chain and assign `Deployed to` address from the response to `BRIDGE_DESTINATION_ADDR`.

```bash
forge create --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY src/reactivebridge/BridgeDestination.sol:BridgeDestination --value 0.02ether
```

### Step 3

Deploy the `ReactiveBridge` (reactive contract) to the Reactive Network, configuring it to listen to `BRIDGE_ORIGIN_ADDR` and to send callbacks to `BRIDGE_DESTINATION_ADDR`. Assign the `Deployed to` address from the response to `BRIDGE_REACTIVE_ADDR`. The emmited event on the origin contract has a topic 0 value of 0x9e6ee6730f1d96f824bc1179793ce184b2df3e543335d7e40bc5931cc5ddf454, which is monitored in reactive contract. `SYSTEM_CONTRACT_ADDR` is the address of the React system contract (callback proxy address on Kopli testnet 0x0000000000000000000000000000000000FFFFFF).

```bash
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/reactivebridge/ReactiveBridge.sol:ReactiveBridge --constructor-args $SYSTEM_CONTRACT_ADDR $BRIDGE_ORIGIN_ADDR 0x9e6ee6730f1d96f824bc1179793ce184b2df3e543335d7e40bc5931cc5ddf454 $BRIDGE_DESTINATION_ADDR
```

### Step 4

Test the bridge, send 0.01 ether to the bridge origin contract. Ether will be sent to the appropriate receivers on the destination chain.

```bash
cast send $BRIDGE_ORIGIN_ADDR --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY --value 0.01ether
```

### Additional steps

Send 0.01 ether to the bridge destination contract, if it runs out of ether. If destination contract doesn't have any ether, it will not be able to complete the bridging and send it to wallet of receiver on destination chain.

```bash
cast send $BRIDGE_DESTINATION_ADDR --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY --value 0.01ether
```


## Bridging worfklow example

1. User sends 0.01 ether to the bridge origin contract on origin chain.
https://sepolia.etherscan.io/tx/0x3d094637601ce7eed7dd6efad525471696a8cb8bfd59d0dc1f63528bb704496e
2. Bridge origin contract emits `BridgeRequest` event, which will be catched on the Reactive Network.
https://sepolia.etherscan.io/tx/0x3d094637601ce7eed7dd6efad525471696a8cb8bfd59d0dc1f63528bb704496e#eventlog
3. Reactive contract catches the event and sends callback to the destination contract on destination chain.
https://kopli.reactscan.net/rvm/0xb8c37c1600c465620774ff6fcf950e3de1774bfd/25
4. Destination contract receives the callback and sends 0.01 ether to the wallet of user on destination chain.
https://sepolia.etherscan.io/tx/0xe2ac1a30ce7183229368ec2281eff3aaaf2ffb46bb1aabdf6cf645dd8d195df2
