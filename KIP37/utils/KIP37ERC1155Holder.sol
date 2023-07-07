// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./KIP37Receiver.sol";
import "./ERC1155Receiver.sol";

contract KIP37ERC1155Holder is KIP37Receiver, ERC1155Receiver {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(KIP37Receiver, ERC1155Receiver)
        returns (bool)
    {
        return KIP37Receiver.supportsInterface(interfaceId) || ERC1155Receiver.supportsInterface(interfaceId);
    }

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

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
