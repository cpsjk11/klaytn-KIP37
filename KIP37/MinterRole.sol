// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Roles.sol";

contract MinterRole {
    using Roles for Roles.Role;

    Roles.Role private _minters;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    constructor (address owner) {
        _addMinter(owner);
    }

    function isMinter(address account) public view returns (bool) {
        return _isMinter(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    /* internal functions */
    
    function _isMinter(address account) internal view returns (bool) {
        return _minters.has(account);
    }

    function _addMinter(address account) internal {
        _minters.add(account);

        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);

        emit MinterRemoved(account);
    }
}
