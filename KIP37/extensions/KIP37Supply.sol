// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../KIP37.sol";
abstract contract KIP37Supply is KIP37 {
    function exists(uint256 id) public view virtual returns (bool) {
        return KIP37.totalSupply(id) > 0;
    }
}
