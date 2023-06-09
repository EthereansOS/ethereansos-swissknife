// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../model/ILazyInitCapableElement.sol";
import { ReflectionUtilities } from "../../lib/GeneralUtilities.sol";

abstract contract LazyInitCapableElement is ILazyInitCapableElement {
    using ReflectionUtilities for address;

    /// @notice the address that initializes the contract via lazyInit; modifier: initializerOnly
    address public override initializer;
    /// @notice the address owns the contract; modifier: onlyOwner
    address public override owner;

    constructor(bytes memory lazyInitData) {
        if(lazyInitData.length > 0) {
            _privateLazyInit(lazyInitData);
        }
    }

    /// @notice initializes the contract, only if the initializer is not address(0), i.e., hasn't been set
    /// @param lazyInitData encoded data to initialize. the first 32 bytes of this parameter must contain the encoded owner address. The initializer address will automatically be set as the msg.sender
    /// @return lazyInitResponse the returned value of the customizable _lazyInit function
    function lazyInit(bytes calldata lazyInitData) override external returns (bytes memory lazyInitResponse) {
        return _privateLazyInit(lazyInitData);
    }

    /// @notice ERC165
    function supportsInterface(bytes4 interfaceId) override external view returns(bool) {
        return
            interfaceId == this.supportsInterface.selector ||
            interfaceId == type(ILazyInitCapableElement).interfaceId ||
            interfaceId == this.lazyInit.selector ||
            interfaceId == this.initializer.selector ||
            interfaceId == this.subjectIsAuthorizedFor.selector ||
            interfaceId == this.owner.selector ||
            interfaceId == this.transferOwnership.selector ||
            interfaceId == this.renounceOwnership.selector ||
            _supportsInterface(interfaceId);
    }

    /// @notice allows the owner to change the owner address
    /// @param newOwner the new owner address
    function transferOwnership(address newOwner) external override virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /// @notice sets the owner address to address(0)
    function renounceOwnership() external override virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /** @notice called internally by the authorizedOnly modifier; 
                First, attempts to return the result of the _subjectIsAuthorizedFor function.
                If _subjectIsAuthorizedFor returns empty bytes, this function will grant access to the owner address if it is an EOY
                Otherwise if the owner is a contract, it will return the result of calling subjectIsAuthorizedFor on that contract. 
        When called by the authorizedOnly modifier, the parameters will be passed as follows. 
        @param subject msg.sender calling the authorizedOnly function
        @param location address(this), the contract's own address
        @param selector msg.sig, the function's selector
        @param payload msg.data, the calldata of the message
        @param value msg.value, the amount of ETH (in wei) sent with the message
        @return bool True if access is granted
      */
    function subjectIsAuthorizedFor(address subject, address location, bytes4 selector, bytes calldata payload, uint256 value) public override virtual view returns(bool) {
        (bytes memory childElementValidationEncodedValue) = _subjectIsAuthorizedFor(subject, location, selector, payload, value);
        if(childElementValidationEncodedValue.length != 0) {
            return childElementValidationEncodedValue.length == 1 ? uint8(childElementValidationEncodedValue[0]) == 1 : abi.decode(childElementValidationEncodedValue, (bool));
        }
        if(subject == owner) {
            return true;
        }
        if(!owner.isContract()) {
            return false;
        }
        (bool result, bytes memory resultData) = owner.staticcall(abi.encodeWithSelector(ILazyInitCapableElement(owner).subjectIsAuthorizedFor.selector, subject, location, selector, payload, value));
        return result && abi.decode(resultData, (bool));
    }

    function _privateLazyInit(bytes memory lazyInitData) private returns (bytes memory lazyInitResponse) {
        require(initializer == address(0), "init");
        initializer = msg.sender;
        (owner, lazyInitResponse) = abi.decode(lazyInitData, (address, bytes));
        emit OwnershipTransferred(address(0), owner);
        lazyInitResponse = _lazyInit(lazyInitResponse);
    }

    function _lazyInit(bytes memory) internal virtual returns (bytes memory) {
        return "";
    }

    function _supportsInterface(bytes4 selector) internal virtual view returns (bool);

    function _subjectIsAuthorizedFor(address, address, bytes4, bytes calldata, uint256) internal virtual view returns(bytes memory) {
    }

    /** @notice returns the result of subjectIsAuthorizedFor(msg.sender, address(this), msg.sig, msg.data, msg.value). 
        Only the msg.sender will be considered unless using a custom implementation of _subjectIsAuthorizedFor
      */
    modifier authorizedOnly {
        require(_authorizedOnly(), "unauthorized");
        _;
    }

    /// @notice grants access only to the initializer address
    modifier initializerOnly {
        require(msg.sender == initializer, "unauthorized");
        _;
    }

    /// @notice grants access only to the owner address
    modifier onlyOwner {
        require(msg.sender == owner, "unauthorized");
        _;
    }

    function _authorizedOnly() internal returns(bool) {
        return subjectIsAuthorizedFor(msg.sender, address(this), msg.sig, msg.data, msg.value);
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}