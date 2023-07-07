// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./PauserRole.sol";

abstract contract Pausable is PauserRole {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() public onlyPauser whenNotPaused {
        _paused = true;

        emit Paused(msg.sender);
    }

    function unpause() public onlyPauser whenPaused {
        _paused = false;

        emit Unpaused(msg.sender);
    }
}
