// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKIP37Burnable {
    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) external;

    function burnBatch(
        address account,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;
}
