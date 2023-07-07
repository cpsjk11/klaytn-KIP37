// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Roles.sol";

contract PauserRole {
    using Roles for Roles.Role;

    Roles.Role private _pausers;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    constructor (address owner) {
        _addPauser(owner);
    }

    function isPauser(address account) public view returns (bool) {
        return _isPauser(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    /* internal functions */
    
    function _isPauser(address account) internal view returns (bool) {
        return _pausers.has(account);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);

        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);

        emit PauserRemoved(account);
    }
}
