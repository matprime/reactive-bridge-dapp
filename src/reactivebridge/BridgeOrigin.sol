// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

contract BridgeOrigin {
    event BridgeRequest(
        address indexed origin,
        address indexed sender,
        uint256 indexed value
    );

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        emit BridgeRequest(
            tx.origin,
            msg.sender,
            msg.value
        );
    }
}