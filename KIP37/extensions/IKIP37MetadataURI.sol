// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IKIP37.sol";

interface IKIP37MetadataURI is IKIP37 {

    function uri(uint256 id) external view returns (string memory);
}
