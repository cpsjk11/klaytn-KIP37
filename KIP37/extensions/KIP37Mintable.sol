// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../KIP37.sol";
import "./KIP37URIStorage.sol";
import "./IKIP37Mintable.sol";
import "../MinterRole.sol";

abstract contract KIP37Mintable is KIP37, KIP37URIStorage, IKIP37Mintable, MinterRole {
    // bytes32 public constant MINTER_ROLE = keccak256("KIP37_MINTER_ROLE");

    mapping(uint256 => address) public creators;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(KIP37)
        returns (bool)
    {
        return
            interfaceId == type(IKIP37Mintable).interfaceId ||
            KIP37.supportsInterface(interfaceId);
    }

    function uri(uint256 tokenId) public view virtual override(KIP37, KIP37URIStorage) returns (string memory) {
        return KIP37URIStorage.uri(tokenId);
    }

    function create(
        uint256 id,
        uint256 initialSupply,
        string memory uri_
    ) public virtual override onlyMinter returns (bool) {
        require(!_exists(id), "KIP37: token already created");

        creators[id] = _msgSender();

        _mint(_msgSender(), id, initialSupply, "");

        if (bytes(uri_).length > 0) {
            _tokenURIs[id] = uri_;
            emit URI(uri_, id);
        }
        return true;
    }

    function mint(
        uint256 id,
        address to,
        uint256 amount
    ) public virtual override onlyMinter {
        // require(!_exists(id), "KIP37: token already created");
        KIP37._mint(to, id, amount, "");
    }

    function mint(
        uint256 id,
        address[] memory toList,
        uint256[] memory amounts
    ) public virtual override onlyMinter {
        // require(!_exists(id), "KIP37: token already created");
        require(toList.length == amounts.length, "KIP37: toList and amounts length mismatch");
        for (uint256 i = 0; i < toList.length; ++i) {
            address to = toList[i];
            uint256 amount = amounts[i];
            KIP37._mint(to, id, amount, "");
        }
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public virtual override onlyMinter {
        for (uint256 i = 0; i < ids.length; ++i) {
            // require(!_exists(ids[i]), "KIP37: token already created");
        }
        KIP37._mintBatch(to, ids, amounts, "");
    }

    function _exists(uint256 id) internal view returns (bool) {
        address creator = creators[id];
        return creator != address(0);
    }

    function _setURI(uint256 tokenId, string memory tokenURI) internal virtual override(KIP37URIStorage) onlyMinter {
        KIP37URIStorage._setURI(tokenId, tokenURI);
    }

    function _setBaseURI(string memory baseURI) internal virtual override(KIP37URIStorage) onlyMinter {
        KIP37URIStorage._setBaseURI(baseURI);
    }

    function _processLockTokens(uint256[] calldata tokenIds) internal override(KIP37) virtual onlyMinter {
        KIP37._processLockTokens(tokenIds);
    }

    function _processUnLockTokens(uint256[] calldata tokenIds) internal override(KIP37) virtual onlyMinter {
        KIP37._processUnLockTokens(tokenIds);
    }

}
