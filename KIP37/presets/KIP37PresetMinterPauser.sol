// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../extensions/KIP37Mintable.sol";
import "../extensions/KIP37Burnable.sol";
import "../extensions/KIP37Pausable.sol";
import "../access/AccessControlEnumerable.sol";

contract KIP37PresetMinterPauser is Context, KIP37, AccessControlEnumerable, KIP37Burnable, KIP37Pausable {
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string  private _name;
    string  private _symbol;

    constructor(string memory symbol_, string memory name_) {
        _name   = name_;
        _symbol = symbol_;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(KIP37, KIP37Burnable,  KIP37Pausable, AccessControlEnumerable)
        returns (bool)
    {
        return
            KIP37Burnable.supportsInterface(interfaceId) ||
            KIP37Pausable.supportsInterface(interfaceId) ||
            interfaceId == type(AccessControlEnumerable).interfaceId ||
            KIP37.supportsInterface(interfaceId);
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function uri(uint256 tokenId) public view virtual override(KIP37) returns (string memory) {
        return KIP37.uri(tokenId);
    }

    function pause() public virtual override {
        require(hasRole(PAUSER_ROLE, _msgSender()), "KIP37PresetMinterPauser: must have pauser role to pause");
        super.pause();
    }

    function pause(uint256 id) public virtual override {
        require(hasRole(PAUSER_ROLE, _msgSender()), "KIP37PresetMinterPauser: must have pauser role to pause");
        super.pause(id);
    }

    function unpause() public virtual override {
        require(hasRole(PAUSER_ROLE, _msgSender()), "KIP37PresetMinterPauser: must have pauser role to unpause");
        super.unpause();
    }

    function unpause(uint256 id) public virtual override {
        require(hasRole(PAUSER_ROLE, _msgSender()), "KIP37PresetMinterPauser: must have pauser role to unpause");
        super.unpause(id);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(KIP37, KIP37Pausable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
