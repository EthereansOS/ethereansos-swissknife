// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Creator {

    /// @notice emitted if bytecode is passed to create, thus a new model contract is deployed prior to the creation of the proxy
    /// @param sender the sender of the create function
    /// @param source the address of the model contract
    event Source(address indexed creator, address indexed source);
    /// @notice emitted when the proxy contract is created
    /// @param sender the sender of the create function
    /// @param source the address of the model contract
    /// @param destination the address of the created proxy contract
    event Created(address indexed creator, address indexed source, address indexed destination);

    /** @notice creates a new generalPurposeProxy contract using the input as the source address if its 20 or 32 bytes.
                Otherwise, creates a source contract using the input as bytecode first, then creating the proxy
        @param sourceAddressOrBytecode the address, or bytecode used to create the source contract, to which the proxy will point
        @return destination the address of the newly created proxy contract
        @return source the address to which the proxy points
    */
    function create(address creator, bytes memory sourceAddressOrBytecode) external returns(address destination, address source) {
        /// @custom:logic the sourceAddressOrBytecode is an address encoded with the abi.encode function
        if(sourceAddressOrBytecode.length == 32) {
            source = abi.decode(sourceAddressOrBytecode, (address));
        /// @custom:logic the sourceAddressOrBytecode is an address encoded with the abi.encodePacked function
        } else if(sourceAddressOrBytecode.length == 20) {
            assembly {
                source := div(mload(add(sourceAddressOrBytecode, 32)), 0x1000000000000000000000000)
            }
        /// @custom:logic the sourceAddressOrBytecode is bytecode
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

/** @notice the proxy contract created by the create function, pointing to the model contract
  */
contract GeneralPurposeProxy {

    /// @notice the model contract address to which the proxy points
    address immutable private _model;

    /// @notice sets the model address
    constructor(address model) payable {
        _model = model;
    }

    /// @notice points all function calls to the model address's logic
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