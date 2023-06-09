//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../model/IDynamicMetadataCapableElement.sol";
import "../model/IDynamicUriResolver.sol";
import "../../generic/impl/LazyInitCapableElement.sol";

abstract contract DynamicMetadataCapableElement is IDynamicMetadataCapableElement, LazyInitCapableElement {

    /** @notice This string may contain a hyperlink, such as a common IPFS or arweave link, 
        or it can be an ABI encoded string containing the address of a custom renderer contract 
        and the necessary rendering data, used for custom on-chain rendering. 
     */ 
    string public override plainUri;
    /** @notice The address of a contract that is called when anyone attempts to retrieve the uri 
        of a dynamicMetadataCapableElement using the uri() function. If a resolver is specified, 
        it will attempt to use the renderer contained in the plainUri. If the renderer fails, 
        the resolver will simply return the plainUri string.
     */
    address public override dynamicUriResolver;

    constructor(bytes memory lazyInitData) LazyInitCapableElement(lazyInitData) {
    }

    function _lazyInit(bytes memory lazyInitData) internal override returns (bytes memory lazyInitResponse) {
        (plainUri, dynamicUriResolver, lazyInitResponse) = abi.decode(lazyInitData, (string, address, bytes));
        lazyInitResponse = _dynamicMetadataElementLazyInit(lazyInitResponse);
    }

    function _supportsInterface(bytes4 interfaceId) internal override view returns(bool) {
        return
            interfaceId == type(IDynamicMetadataCapableElement).interfaceId ||
            interfaceId == this.plainUri.selector ||
            interfaceId == this.uri.selector ||
            interfaceId == this.dynamicUriResolver.selector ||
            interfaceId == this.setUri.selector ||
            interfaceId == this.setDynamicUriResolver.selector ||
            _dynamicMetadataElementSupportsInterface(interfaceId);
    }

    /// @notice return the plainUri if dynamicUriResolver is the zero address, otherwise it will return the result of the resolver’s resolve function. 
    function uri() public virtual override view returns(string memory) {
        return _uri(plainUri, "");
    }

    /// @notice set a new plainUri
    function setUri(string calldata newValue) external override authorizedOnly returns (string memory oldValue) {
        oldValue = plainUri;
        plainUri = newValue;
    }

    /// @notice set a new dynamicUriResolver address
    function setDynamicUriResolver(address newValue) external override authorizedOnly returns(address oldValue) {
        oldValue = dynamicUriResolver;
        dynamicUriResolver = newValue;
    }

    function _uri(string memory _plainUri, bytes memory additionalData) internal view returns(string memory) {
        if(dynamicUriResolver == address(0)) {
            return _plainUri;
        }
        return IDynamicUriResolver(dynamicUriResolver).resolve(address(this), _plainUri, additionalData, msg.sender);
    }

    function _dynamicMetadataElementLazyInit(bytes memory lazyInitData) internal virtual returns(bytes memory);

    function _dynamicMetadataElementSupportsInterface(bytes4 interfaceId) internal virtual view returns(bool);
}