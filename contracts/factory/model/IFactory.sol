// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../dynamicMetadata/model/IDynamicMetadataCapableElement.sol";

interface IFactory is IDynamicMetadataCapableElement {

    function modelAddress() external view returns(address);
    function setModelAddress(address newValue) external returns(address oldValue);

    function deployer(address deployedAddress) external view returns(address);

    function deploy(bytes calldata deployData) external payable returns(address deployedAddress, bytes memory deployedLazyInitResponse);
}