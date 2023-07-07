// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../KIP37.sol";
import "../utils/Strings.sol";

abstract contract KIP37URIStorage is KIP37 {
    using Strings for uint256;

    string internal _baseURI = "";

    mapping(uint256 => string) internal _tokenURIs;

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory tokenURI = _tokenURIs[tokenId];

        return bytes(tokenURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenURI)) : super.uri(tokenId);
    }

    function _setURI(uint256 tokenId, string memory tokenURI) internal virtual {
        _tokenURIs[tokenId] = tokenURI;
        emit URI(uri(tokenId), tokenId);
    }

    function _setBaseURI(string memory baseURI) internal virtual {
        _baseURI = baseURI;
    }
}
