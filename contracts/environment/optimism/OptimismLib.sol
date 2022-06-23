// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface iOVM_L1BlockNumber {
    function getL1BlockNumber() external view returns (uint256);
}

library OptimismLib {
    function _blockNumber() internal view returns(uint256) {
        return iOVM_L1BlockNumber(0x4200000000000000000000000000000000000013).getL1BlockNumber();
    }
}