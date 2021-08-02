//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "../model/IDynamicUriResolver.sol";
import "../model/IDynamicUriRenderer.sol";

import { StringUtilities } from "../../lib/GeneralUtilities.sol";

contract DynamicUriResolver is IDynamicUriResolver {
    using StringUtilities for string;

    function resolve(address subject, string calldata plainUri, bytes calldata inputData, address caller) override external view returns(string memory) {
        if(msg.sender != address(this)) {
            try this.resolve(subject, plainUri, inputData, caller) returns (string memory renderedUri) {
                return renderedUri;
            } catch {
                return plainUri;
            }
        }
        (address renderer, bytes memory rendererData) = abi.decode(plainUri.asBytes(), (address, bytes));
        if(renderer == address(0)) {
            return plainUri;
        }
        try IDynamicUriRenderer(renderer).render(subject, plainUri, inputData, caller, rendererData) returns (string memory renderedUri) {
            return renderedUri;
        } catch {
            return plainUri;
        }
    }
}