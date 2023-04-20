//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDynamicUriRenderer {
    function render(address subject, string calldata plainUri, bytes calldata inputData, address caller, bytes calldata rendererData) external view returns (string memory);
}