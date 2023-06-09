// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Creator {

    event Source(address indexed creator, address indexed source);
    event Created(address indexed creator, address indexed source, address indexed destination);

    function create(address creator, bytes memory sourceAddressOrBytecode) external returns(address destination, address source) {
        if(sourceAddressOrBytecode.length == 32) {
            source = abi.decode(sourceAddressOrBytecode, (address));
        } else if(sourceAddressOrBytecode.length == 20) {
            assembly {
                source := div(mload(add(sourceAddressOrBytecode, 32)), 0x1000000000000000000000000)
            }
        } else {
            assembly {
                source := create(0, add(sourceAddressOrBytecode, 32), mload(sourceAddressOrBytecode))
            }
            emit Source(creator, source);
        }
        require(source != address(0), "source");
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(source)
        }
        require(codeSize > 0, "source");
        destination = address(new GeneralPurposeProxy{value : msg.value}(source));
        emit Created(creator, source, destination);
    }
}

contract GeneralPurposeProxy {

    address immutable private _model;

    constructor(address model) payable {
        _model = model;
    }

    fallback() external payable {
        address model = _model;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas(), model, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
                case 0 {revert(0, returndatasize())}
                default { return(0, returndatasize())}
        }
    }
}