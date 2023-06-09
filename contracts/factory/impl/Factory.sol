// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../model/IFactory.sol";
import "../../dynamicMetadata/impl/DynamicMetadataCapableElement.sol";
import "../../lib/Initializer.sol";

contract Factory is IFactory, DynamicMetadataCapableElement {

    address public override modelAddress;
    mapping(address => address) public override deployer;

    constructor(bytes memory lazyInitData) DynamicMetadataCapableElement(lazyInitData) {
    }

    function _dynamicMetadataElementLazyInit(bytes memory lazyInitData) internal override returns (bytes memory lazyInitResponse) {
        require(modelAddress == address(0), "init");
        (modelAddress, lazyInitResponse) = abi.decode(lazyInitData, (address, bytes));
        lazyInitResponse = _factoryLazyInit(lazyInitResponse);
    }

    function _dynamicMetadataElementSupportsInterface(bytes4 interfaceId) override internal view returns(bool) {
        return
            interfaceId == type(IFactory).interfaceId ||
            interfaceId == this.modelAddress.selector ||
            interfaceId == this.setModelAddress.selector ||
            interfaceId == this.deployer.selector ||
            interfaceId == this.deploy.selector ||
            _factorySupportsInterface(interfaceId);
    }

    function setModelAddress(address newValue) external override authorizedOnly returns(address oldValue) {
        oldValue = modelAddress;
        modelAddress = newValue;
    }

    function deploy(bytes calldata deployData) public payable override virtual returns(address deployedAddress, bytes memory deployedLazyInitResponse) {
        (deployedAddress, deployedLazyInitResponse,) = Initializer.createAndInitialize(msg.sender, abi.encode(modelAddress), _buildLazyInitData(deployData));
        deployer[deployedAddress] = msg.sender;
    }

    function _buildLazyInitData(bytes memory deployData) internal virtual returns(bytes memory lazyInitData) {
        return deployData;
    }

    function _factoryLazyInit(bytes memory) internal virtual returns (bytes memory) {
        return "";
    }

    function _factorySupportsInterface(bytes4 interfaceId) internal virtual view returns(bool) {
    }
}