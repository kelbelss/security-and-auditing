// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Deploy this contract first
contract B {
    // ensure storage layout is the same as contract A
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract A {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(address _contract, uint256 _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
    }
}
