// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import '../AbstractCallback.sol';

contract BridgeDestination is AbstractCallback {
    event CallbackReceived(
        address indexed origin,
        address indexed sender,
        address indexed reactive_sender,
        uint256 bridged_amount
    );

    address public owner;

    constructor() AbstractCallback(address(0)) payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    receive() external payable {}

    function callback(address sender, uint256 bridgedAmount) external {
        emit CallbackReceived(
            tx.origin,
            msg.sender,
            sender,
            bridgedAmount
        );
        payable(sender).transfer(bridgedAmount);
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}