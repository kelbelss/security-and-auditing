// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Encoding {
    // ABI - application binary interface

    function combineStrings() public pure returns (string memory) {
        return string(abi.encodePacked("Hi Mom! ", "Miss you"));
        // abi.encode returns a bytes object - and we are type casting by wrapping to make it a string
        // Solidity cheatsheet - Global Variables
        // in 0.8.12+ you can do string.concat(stringA, stringB);

        // Understand more about what happens when we send a transaction
        // when code is compiled - we get .abi and .bin (binary - "object")
        // when we send contract to blockchain we are sending binary
        // data attached to deploying a contract is the contracts initialisation code and bytecode

        // in order for the blockchain to understand the bytecode - you need a special reader
        // evm opcodes

        // abi.encodePack can encode anything to be in binary format
    }

    function encodeNumber() public pure returns (bytes memory) {
        // have function return bytes opject - return what number will be in binary
        bytes memory number = abi.encode(1);
        return number;
        // encode number down to its abi/binary format
        // will return hex
    }

    function encodeString() public pure returns (bytes memory) {
        bytes memory stringByteCode = abi.encode("hello");
        return stringByteCode;
        // returns hex: bytes: 0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000568656c6c6f000000000000000000000000000000000000000000000000000000
        // lots of zeros which take up space - thats where abi.encodePacked comes in
    }

    function encodePackedString() public pure returns (bytes memory) {
        bytes memory stringByteCode = abi.encodePacked("hello");
        return stringByteCode;
        // returns hex: bytes: 0x68656c6c6f
        // much smaller bytes option
    }

    // packed is similar to type casting

    function encodeStringBytes() public pure returns (bytes memory) {
        bytes memory typeCast = bytes("hello");
        return typeCast;
        // returns hex: bytes: 0x68656c6c6f
    }

    // what do they ACTUALLY do
    // not only can you encode, you can decode

    function decodeString() public pure returns (string memory) {
        string memory decoded = abi.decode(encodeString(), (string));
        return decoded;
    }

    // we can multi encode and multi decode

    function multiEncode() public pure returns (bytes memory) {
        bytes memory someString = abi.encode("some string ", "it is bigger!");
        return someString;
        // returns bytes: 0x00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000b736f6d6520737472696e67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d6974206973206269676765722100000000000000000000000000000000000000
    }

    function multiDecode() public pure returns (string memory, string memory) {
        (string memory someString, string memory anotherString) = abi.decode(multiEncode(), (string, string));
        return (someString, anotherString);
        // returns 0: string: some string 1: string: it is bigger!
    }

    // multiEncode can be done with abi.encodePacked but cannot be decoded

    function multiEncodePacked() public pure returns (bytes memory) {
        bytes memory someString = abi.encodePacked("some string ", "it is bigger!");
        return someString;
        // returns bytes: 0x736f6d6520737472696e67206974206973206269676765722
    }

    // can do this instead of decoding

    function multiStringCastPacked() public pure returns (string memory) {
        string memory someString = string(multiEncodePacked());
        return someString;
        // returns string: some string it is bigger!
    }

    // ENCODING FUNCTION CALLS DIRECTLY

    // since we know the contracts will be compiled down to binary - we can populate the data value of transaction ourselves with the binary the code will use
    // data of function call is what to send to the To address

    // How do we send transactions that vall functions with just the data field populated?
    // How do we populate the data field?

    // Solidity has low-level keywords, "staticcall" and "call"
    // call: how we call functions to change the state of the blockchain
    // staticcall: this is how (at a low level) we do our "view" or "pure" function calls, and potentially do not change blockchain state

    function withdraw(address winner) public {
        (bool success,) = winner.call{value: address(this).balance}("");
        require(success, "Transfer Failed");
        // inside {} we updated the value directly of transaction in Solidity, in "" is where we will put the data
        // in the "" is where we can put stuff to call functions
    }
}
