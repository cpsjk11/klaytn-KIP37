// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./KIP37Receiver.sol";

contract KIP37Holder is KIP37Receiver {
    function onKIP37Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onKIP37Received.selector;
    }

    function onKIP37BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onKIP37BatchReceived.selector;
    }
}
