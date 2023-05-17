// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../model/ILazyInitCapableElement.sol";
import { ReflectionUtilities } from "../../lib/GeneralUtilities.sol";

abstract contract LazyInitCapableElement is ILazyInitCapableElement {
    using ReflectionUtilities for address;

    address public override initializer;
    address public override owner;

    constructor(bytes memory lazyInitData) {
        if(lazyInitData.length > 0) {
            _privateLazyInit(lazyInitData);
        }
    }

    function lazyInit(bytes calldata lazyInitData) override external returns (bytes memory lazyInitResponse) {
        return _privateLazyInit(lazyInitData);
    }

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

    function transferOwnership(address newOwner) external override virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function renounceOwnership() external override virtual onlyOwner {
        _transferOwnership(address(0));
    }

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

    modifier authorizedOnly {
        require(_authorizedOnly(), "unauthorized");
        _;
    }

    modifier initializerOnly {
        require(msg.sender == initializer, "unauthorized");
        _;
    }

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