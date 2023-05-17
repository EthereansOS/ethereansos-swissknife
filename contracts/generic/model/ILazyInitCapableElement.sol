// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILazyInitCapableElement {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function lazyInit(bytes calldata lazyInitData) external returns(bytes memory initResponse);
    function initializer() external view returns(address);

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    function owner() external view returns(address);
    function transferOwnership(address newValue) external;
    function renounceOwnership() external;

    function subjectIsAuthorizedFor(address subject, address location, bytes4 selector, bytes calldata payload, uint256 value) external view returns(bool);
}