// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../KIP17/introspection/KIP13.sol";
import "../IKIP37Receiver.sol";

abstract contract KIP37Receiver is KIP13, IKIP37Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(KIP13, IKIP13) returns (bool) {
        return interfaceId == type(IKIP37Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}
