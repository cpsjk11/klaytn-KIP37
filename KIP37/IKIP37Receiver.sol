// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../KIP17/introspection/IKIP13.sol";

interface IKIP37Receiver is IKIP13 {

    function onKIP37Received(
        address operator,
        address from,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);

    function onKIP37BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external returns (bytes4);
}
