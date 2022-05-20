// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Creator.sol";
import "../generic/model/ILazyInitCapableElement.sol";

library Initializer {

    event Created(address indexed destination, bytes lazyInitResponse);

    function create(bytes memory sourceAddressOrBytecode, bytes memory lazyInitData) external returns(address destination, bytes memory lazyInitResponse, address source) {
        (destination, source) = Creator.create(sourceAddressOrBytecode);
        lazyInitResponse = ILazyInitCapableElement(destination).lazyInit(lazyInitData);
        require(ILazyInitCapableElement(destination).initializer() == address(this));
        emit Created(destination, lazyInitResponse);
    }
}