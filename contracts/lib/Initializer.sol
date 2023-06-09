// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Creator.sol";
import "../generic/model/ILazyInitCapableElement.sol";

library Initializer {

    event Initialized(address indexed destination, bytes lazyInitData, bytes lazyInitResponse);

    function createAndInitialize(address creator, bytes memory sourceAddressOrBytecode, bytes memory lazyInitData) external returns(address destination, bytes memory lazyInitResponse, address source) {
        (destination, source) = Creator.create(creator, sourceAddressOrBytecode);
        lazyInitResponse = initialize(destination, lazyInitData);
    }

    function initialize(address destination, bytes memory lazyInitData) public returns(bytes memory lazyInitResponse) {
        lazyInitResponse = ILazyInitCapableElement(destination).lazyInit(lazyInitData);
        require(ILazyInitCapableElement(destination).initializer() == address(this));
        emit Initialized(destination, lazyInitData, lazyInitResponse);
    }
}