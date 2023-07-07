// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKIP37Mintable {

    function create(
        uint256 id,
        uint256 initialSupply,
        string calldata uri_
    ) external returns (bool);

    function mint(
        uint256 id,
        address to,
        uint256 amount
    ) external;

    function mint(
        uint256 id,
        address[] calldata toList,
        uint256[] calldata amounts
    ) external;

    function mintBatch(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;
}
