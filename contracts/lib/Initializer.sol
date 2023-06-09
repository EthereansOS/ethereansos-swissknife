// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Creator.sol";
import "../generic/model/ILazyInitCapableElement.sol";

library Initializer {

    /// @notice emitted when the proxy is created and initialized
    /// @param destination the proxy contract address
    /// @param lazyInitResponse returned by the LazyInitCapableElement's lazyInit function
    event Initialized(address indexed destination, bytes lazyInitData, bytes lazyInitResponse);

    function createAndInitialize(address creator, bytes memory sourceAddressOrBytecode, bytes memory lazyInitData) external returns(address destination, bytes memory lazyInitResponse, address source) {
        (destination, source) = Creator.create(creator, sourceAddressOrBytecode);
        lazyInitResponse = initialize(destination, lazyInitData);
    }

    /// @notice create and initialize a GeneralPurposeProxy with a LazyInitCapableElement model and initialize it
    /// @param sourceAddressOrBytecode address of the model or bytecode to create the model with
    /// @param lazyInitResponse returned by the LazyInitCapableElement's lazyInit function
    function initialize(address destination, bytes memory lazyInitData) public returns(bytes memory lazyInitResponse) {
        lazyInitResponse = ILazyInitCapableElement(destination).lazyInit(lazyInitData);
        require(ILazyInitCapableElement(destination).initializer() == address(this));
        emit Initialized(destination, lazyInitData, lazyInitResponse);
    }
}