// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILazyInitCapableElement {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function lazyInit(bytes calldata lazyInitData) external returns(bytes memory initResponse);
    function initializer() external view returns(address);

    event Host(address indexed from, address indexed to);

    function host() external view returns(address);
    function setHost(address newValue) external returns(address oldValue);

    function subjectIsAuthorizedFor(address subject, address location, bytes4 selector, bytes calldata payload, uint256 value) external view returns(bool);
}