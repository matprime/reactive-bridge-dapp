# Bridging funds using Reactive Network technology 

## Overview

The Reactive Bridge App allows users to bridge funds from an origin chain to a destination chain. This is accomplished using [Reactive Network technology](https://reactive.network). It is a system that operates between the origin chain (or any other layer), the Reactive Network and the destination chain (or any other layer). These requests are being handled by a corresponding contract on the Reactive Network. User deposits funds to the bridge origin contract, which then emits a request to the Reactive contract. The Reactive contract processes the request by emitting a callback to the destination contract, which sends funds to the corresponding destination contract and chain.

## Frontend
This is the demo version of the bridge application, showcasing how to trigger value bridging between two chains. The frontend is configured to work with already-deployed contracts, which are available for users to interact with. User can open the frontend/index.html in the browser to interact with the contracts.

**How it works**
Frontend demonstrates the process of bridging ETH from wallet on origin chain to wallet on destination chain. The current demo setup is configured to use Sepolia as both the origin and destination chain. The contracts from the repository have been deployed on Sepolia and Reactive Network (Kopli testnet), and users can simulate the entire bridge process by sending ETH from their browser-integrated wallet (such as MetaMask) to the origin contract and receive sent ETH in their wallet on the destination chain. To try the bridge with different chains, change the constant contractAddress in the frontend/index.html file. You will need to deploy contracts with new addresses on chains you want to bridge between.

**Key Features**
* Browser Wallet Integration: Users can interact with the dApp using a browser wallet, such as MetaMask, to send ETH and initiate the bridge process.
* Simulated Bridge Process: Although both contracts are deployed on the Sepolia testnet, the demo simulates the full cross-chain bridge experience.
* Deployed Contracts: Users can directly interact with the already-deployed origin, target and ETH contracts to see how the bridging flow works in real-time.

The frontend is designed to give users a hands-on demonstration of how a cross-chain value transfer might function using a decentralized bridge, while staying within the confines of the Sepolia testnet for simplicity.

## Smart contracts

The demo involves three contracts:

1. **Origin Chain Contract:** `BridgeOrigin` handles ETH payment requests and emits `BridgeDepositRequested` events containing the details of the transaction.

2. **Reactive Contract:** `ReactiveBridge` operates on the Reactive Network. It subscribes to events on the origin chain, processes callbacks and triggers destination chain contract to send ETH to the appropriate receivers based on external `BridgeRequest` events.

2. **Destination Chain Contract:** `BridgeDestination` operates on the destination chain. It receives callbacks from the Reactive contract and transfers ETH to the appropriate receivers.


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

If the origin chain and destination chain are Sepolia, you can use the recommended Sepolia RPC URL: `https://rpc2.sepolia.org`. You can find more about the React system contract  0x0000000000000000000000000000000000FFFFFF [here](https://dev.reactive.network/system-contract). 

Frontend is configured to work with already-deployed contracts on Sepolia and Kopli testnet:
BRIDGE_ORIGIN_ADDR=0xd9194b9A5eFb767411b15a49d79bda9aFe63eFE2
BRIDGE_DESTINATION_ADDR=0xe7Cc1f1Ec6CD96333f8cB6A40c4033081E114bB8
BRIDGE_REACTIVE_ADDR=0xE1328A2063319a4Cdb2F7177884EA05f1dBeCe8F

### Step 1
Deploy the `BridgeOrigin` to the origin chain and assign the `Deployed to` address from the response to `BRIDGE_ORIGIN_ADDR`. 

```bash
forge create --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY src/reactivebridge/BridgeOrigin.sol:BridgeOrigin
```

### Step 2
Deploy the `BridgeDestinaton` to the destination chain and assign `Deployed to` address from the response to `BRIDGE_DESTINATION_ADDR`.

```bash
forge create --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY src/reactivebridge/BridgeDestination.sol:BridgeDestination --value 0.02ETH
```

### Step 3

Deploy the `ReactiveBridge` (Reactive contract) to the Reactive Network, configuring it to listen to `BRIDGE_ORIGIN_ADDR` and to send callbacks to `BRIDGE_DESTINATION_ADDR`. Assign the `Deployed to` address from the response to `BRIDGE_REACTIVE_ADDR`. The emmited event on the origin contract has a topic 0 value of 0x9e6ee6730f1d96f824bc1179793ce184b2df3e543335d7e40bc5931cc5ddf454, which is monitored in the Reactive contract. `SYSTEM_CONTRACT_ADDR` is the address of the React system contract (callback proxy address on Kopli testnet 0x0000000000000000000000000000000000FFFFFF).

```bash
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/reactivebridge/ReactiveBridge.sol:ReactiveBridge --constructor-args $SYSTEM_CONTRACT_ADDR $BRIDGE_ORIGIN_ADDR 0x9e6ee6730f1d96f824bc1179793ce184b2df3e543335d7e40bc5931cc5ddf454 $BRIDGE_DESTINATION_ADDR
```

### Step 4

Test the bridge, send 0.0001 ETH to the bridge origin contract. ETH will be sent to the appropriate receivers on the destination chain.

```bash
cast send $BRIDGE_ORIGIN_ADDR --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY --value 0.0001ETH
```

### Additional steps

Send 0.0001 ETH to the bridge destination contract if it runs out of ETH. If the destination contract doesn't have any ETH, it will not be able to complete the bridging and send it to the receiver wallet on the destination chain.

```bash
cast send $BRIDGE_DESTINATION_ADDR --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY --value 0.0001ETH
```


## Bridging worfklow example

1. User sends 0.0001 ETH to the bridge origin contract on origin chain.
https://sepolia.ETHscan.io/tx/0x95abfa251f123516721f1c7f88bee9e3871565d06e01401a29633f351106bc52
2. Bridge origin contract emits `BridgeDepositRequested` event, which will be catched on the Reactive Network.
https://sepolia.ETHscan.io/tx/0x95abfa251f123516721f1c7f88bee9e3871565d06e01401a29633f351106bc52#eventlog
3. Reactive contract catches the event and sends a callback to the destination contract on the destination chain.
https://kopli.reactscan.net/rvm/0xb8c37c1600c465620774ff6fcf950e3de1774bfd/40
4. Destination contract receives the callback and sends 0.0001 ETH to the wallet of the original user on the destination chain.
https://sepolia.ETHscan.io/tx/0x910399e49398c18ba72de50301150dffd06d4508353a9c3d8579a553e7d7c96f
