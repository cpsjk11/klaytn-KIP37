// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../KIP37.sol";
import "./Pausable.sol";
import "../access/AccessControlEnumerable.sol";
import "./IKIP37Pausable.sol";

abstract contract KIP37Pausable is KIP37, AccessControlEnumerable, Pausable, IKIP37Pausable {
    bytes32 public constant PAUSER_ROLE = keccak256("KIP37_PAUSER_ROLE");

    event TokenPaused(address account, uint256 id);

    event TokenUnpaused(address account, uint256 id);

    mapping(uint256 => bool) private _tokenPaused;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(KIP37, AccessControlEnumerable)
        returns (bool)
    {
        return
            interfaceId == type(IKIP37Pausable).interfaceId ||
            KIP37.supportsInterface(interfaceId) ||
            AccessControlEnumerable.supportsInterface(interfaceId);
    }

    function pause() public virtual override onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public virtual override onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function paused() public view override(IKIP37Pausable, Pausable) returns (bool) {
        return Pausable.paused();
    }

    function paused(uint256 id) public view override returns (bool) {
        return _tokenPaused[id];
    }

    function pause(uint256 id) public virtual override onlyRole(PAUSER_ROLE) {
        require(_tokenPaused[id] == false, "KIP37Pausable: token already paused");
        _tokenPaused[id] = true;
        emit TokenPaused(_msgSender(), id);
    }

    function unpause(uint256 id) public virtual override onlyRole(PAUSER_ROLE) {
        require(_tokenPaused[id] == true, "KIP37Pausable: token already unpaused");
        _tokenPaused[id] = false;
        emit TokenUnpaused(_msgSender(), id);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            require(!paused(id), "KIP37Pausable: token transfer while paused");
        }
        require(!paused(), "KIP37Pausable: token transfer while paused");
    }
}
