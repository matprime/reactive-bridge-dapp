# Bridging funds using Reactive Network technology 

## Overview

The Reactive Bridge App allows users to bridge funds from a origin chain to destination chain. This is acomplished using [Reactive Network technology](https://reactive.network). It is a system that operates between origin chain (or any other layer), the Reactive Network and destination chain (or any other layer). These requests are being handled by a corresponding contract on the Reactive Network. User deposits funds to the bridge origin contract, which then emits a request to the reactive contract. The reactive contract processes the request by emitting callback to destination contract, which is sending funds to the corresponding destination contract and chain.

## Contracts

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
