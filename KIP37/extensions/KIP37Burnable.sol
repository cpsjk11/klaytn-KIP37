// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../KIP37.sol";
import "./IKIP37Burnable.sol";

abstract contract KIP37Burnable is KIP37, IKIP37Burnable {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IKIP37Burnable).interfaceId || super.supportsInterface(interfaceId);
    }

    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public virtual override {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "KIP37: caller is not owner nor approved"
        );

        _burn(account, id, amount);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public virtual override {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "KIP37: caller is not owner nor approved"
        );

        _burnBatch(account, ids, amounts);
    }
}