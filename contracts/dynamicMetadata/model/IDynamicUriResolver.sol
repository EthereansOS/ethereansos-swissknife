//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDynamicUriResolver {
    function resolve(address subject, string calldata plainUri, bytes calldata inputData, address caller) external view returns(string memory);
}