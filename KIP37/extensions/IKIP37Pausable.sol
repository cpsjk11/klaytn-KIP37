// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IKIP37Pausable {

    function paused() external view returns (bool);

    function pause() external;

    function unpause() external;

    function paused(uint256 id) external view returns (bool);

    function pause(uint256 id) external;

    function unpause(uint256 id) external;
}
