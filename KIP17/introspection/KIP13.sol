// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interface/IKIP13.sol";

abstract contract KIP13 is IKIP13 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IKIP13).interfaceId;
    }
}
