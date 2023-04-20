// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract BlockRetriever {

    function _blockNumber() internal view virtual returns(uint256) {
        return block.number;
    }
}