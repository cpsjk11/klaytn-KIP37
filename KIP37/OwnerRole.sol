// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./MinterRole.sol";
import "./PauserRole.sol";

contract OwnerRole is MinterRole, PauserRole {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "OwnerRole: caller is not owner");
        _;
    }

    constructor (address payable owner_) MinterRole(owner_) 
                                         PauserRole(owner_) {
        _owner = owner_;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return (account == _owner);
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(payable(address(0)));
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "OwnerRole: new owner is the zero address");
        require(newOwner != _owner, "OwnerRole: already is the owner");

        _transferOwnership(newOwner);
    }

    /* internal functions */

    function _transferOwnership(address payable newOwner) public onlyOwner {
        if (!_isMinter(newOwner)) {
            _addMinter(newOwner);
        }

        if (_isMinter(_owner)) {
            _removeMinter(_owner);
        }

        if (!_isPauser(newOwner)) {
            _addPauser(newOwner);
        }

        if (_isPauser(_owner)) {
            _removePauser(_owner);
        }

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}
