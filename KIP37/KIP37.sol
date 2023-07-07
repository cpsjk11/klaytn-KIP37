// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IKIP37.sol";
import "./IKIP37Receiver.sol";
import "./utils/IERC1155Receiver.sol";
import "./extensions/IKIP37MetadataURI.sol";
import "./utils/Address.sol";
import "./utils/Context.sol";
import "./SafeMath.sol";
import "KIP17/introspection/KIP13.sol";

contract KIP37 is Context, KIP13, IKIP37, IKIP37MetadataURI {
    using Address for address;
    using SafeMath for uint256;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(uint256 => uint256) private _totalSupply;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(address => mapping(uint256 => uint256)) private _lockedTokens;

    mapping(address => mapping(uint256 => uint256)) private _processLock;

    string private _uri;

    constructor() {}    

    function supportsInterface(bytes4 interfaceId) public view virtual override(KIP13, IKIP13) returns (bool) {
        return
            interfaceId == type(IKIP37).interfaceId ||
            interfaceId == type(IKIP37MetadataURI).interfaceId ||
            KIP13.supportsInterface(interfaceId);
    }
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    function totalSupply(uint256 id) public view virtual override returns (uint256) {
        return _totalSupply[id];
    }

    function balanceOf(address owner, uint256 id) public view virtual override returns (uint256) {
        require(owner != address(0), "KIP37: address zero is not a valid owner");
        return _balances[id][owner];
    }

    function isTokenLocked(uint256 tokenId, address owner) public view returns (uint256) {
        return _lockedTokens[owner][tokenId];
    }

    function isProcessLocked(uint256 tokenId, address owner) public view returns (uint256) {
        return _processLock[owner][tokenId];
    }


    function balanceOfBatch(address[] memory owners, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(owners.length == ids.length, "KIP37: owners and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](owners.length);

        for (uint256 i = 0; i < owners.length; ++i) {
            batchBalances[i] = balanceOf(owners[i], ids[i]);
        }

        return batchBalances;
    }

    function getAllLockedTokensByAddress(address _addr, uint256[] memory tokenIds) public view virtual returns (uint256[] memory, uint256[] memory) {
        uint256[] memory indices;
        uint256[] memory values;

        for (uint256 i = 0; i < tokenIds.length - 1; i++) {
            uint256 value = _lockedTokens[_addr][tokenIds[i]];
            if (value > 0) {
                indices = appendUint256ToArray(indices, tokenIds[i]);
                values = appendUint256ToArray(values, value);
            }
        }

        return (indices, values);
    }

    function getAllProcerssLockedByAddress(address _addr, uint256[] memory tokenIds) public view virtual returns (uint256[] memory, uint256[] memory) {
        uint256[] memory indices;
        uint256[] memory values;

        for (uint256 i = 0; i < tokenIds.length - 1; i++) {
            uint256 value = _processLock[_addr][tokenIds[i]];
            if (value > 0) {
                indices = appendUint256ToArray(indices, tokenIds[i]);
                values = appendUint256ToArray(values, value);
            }
        }

        return (indices, values);
    }

    function appendUint256ToArray(uint256[] memory array, uint256 element) internal pure returns (uint256[] memory) {
        uint256[] memory newArray = new uint256[](array.length + 1);
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        newArray[array.length] = element;
        return newArray;
    }

    function _processLockTokens(address owner, uint256[] calldata tokenIds, uint256[] calldata amounts) internal virtual {
        require(tokenIds.length == amounts.length, "Invalid input lengths");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] != 0, "Invalid token ID");
            require(_balances[tokenIds[i]][owner] > 0, "Token already locked");
            uint256 balance = _balances[tokenIds[i]][owner];
            uint256 lockToken = _processLock[owner][tokenIds[i]] + amounts[i] + _lockedTokens[owner][tokenIds[i]];
            require(balance >= lockToken, "The maximum number has been exceeded.");
            uint256 lockTokenAdd = _processLock[owner][tokenIds[i]] + amounts[i];

            _processLock[owner][tokenIds[i]] = lockTokenAdd;
        }
    }

    function _processUnLockTokens(address owner, uint256[] calldata tokenIds, uint256[] calldata amounts) internal virtual {
        require(tokenIds.length == amounts.length, "Invalid input lengths");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] != 0, "Invalid token ID");
            require(_processLock[owner][tokenIds[i]] != 0, "Token already locked");
            uint256 unLockToken = _processLock[owner][tokenIds[i]] - amounts[i];
            require(unLockToken >= 0, "Invalid unlock amount");

            _processLock[owner][tokenIds[i]] = unLockToken;
        }
    }

    function _lockTokens(address owner, uint256[] calldata tokenIds, uint256[] calldata amounts) internal virtual {
        require(tokenIds.length == amounts.length, "Invalid input lengths");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] != 0, "Invalid token ID");
            require(_balances[tokenIds[i]][owner] > 0, "Token already locked");
            uint256 balance = _balances[tokenIds[i]][owner];
            uint256 lockToken = _lockedTokens[owner][tokenIds[i]] + amounts[i] + _processLock[owner][tokenIds[i]];
            require(balance >= lockToken, "The maximum number has been exceeded.");
            uint256 lockTokenAdd = _lockedTokens[owner][tokenIds[i]] + amounts[i];

            _lockedTokens[owner][tokenIds[i]] = lockTokenAdd;
        }
    }

    function _unLockTokens(address owner, uint256[] calldata tokenIds, uint256[] calldata amounts) internal virtual {
        require(tokenIds.length == amounts.length, "Invalid input lengths");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] != 0, "Invalid token ID");
            require(_lockedTokens[owner][tokenIds[i]] != 0, "Token already locked");
            uint256 unLockToken = _lockedTokens[owner][tokenIds[i]] - amounts[i];
            require(unLockToken >= 0, "Invalid unlock amount");

            _lockedTokens[owner][tokenIds[i]] = unLockToken;
        }
    }


    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }


    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "KIP37: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "KIP37: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "KIP37: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "KIP37: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "KIP37: ids and amounts length mismatch");
        require(to != address(0), "KIP37: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "KIP37: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "KIP37: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "KIP37: mint to the zero address");
        require(ids.length == amounts.length, "KIP37: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "KIP37: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "KIP37: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "KIP37: burn from the zero address");
        require(ids.length == amounts.length, "KIP37: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "KIP37: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }


    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "KIP37: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address, /** operator */
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory /** data */
    ) internal virtual {
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 balance = _balances[ids[i]][from] - (_lockedTokens[from][ids[i]] + _processLock[from][ids[i]]);

            if (from != address(0) && balance < amounts[i] ) {
                revert("Token is locked");
            }
        }

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "KIP37: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        require(
            _checkOnKIP37Received(operator, from, to, id, amount, data) ||
                _checkOnERC1155Received(operator, from, to, id, amount, data),
            "KIP37: transfer to non IKIP37Receiver/IERC1155Receiver implementer"
        );
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        require(
            _checkOnKIP37BatchReceived(operator, from, to, ids, amounts, data) ||
                _checkOnERC1155BatchReceived(operator, from, to, ids, amounts, data),
            "KIP37: transfer to non IKIP37Receiver/IERC1155Receiver implementer"
        );
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    function _checkOnKIP37Received(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IKIP37Receiver(to).onKIP37Received(operator, from, id, amount, data) returns (bytes4 retval) {
                return retval == IKIP37Receiver.onKIP37Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    return false;
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _checkOnKIP37BatchReceived(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IKIP37Receiver(to).onKIP37BatchReceived(operator, from, ids, amounts, data) returns (bytes4 retval) {
                return retval == IKIP37Receiver.onKIP37BatchReceived.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    return false;
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _checkOnERC1155Received(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 retval) {
                return retval == IERC1155Receiver.onERC1155Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    return false;
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _checkOnERC1155BatchReceived(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 retval
            ) {
                return retval == IERC1155Receiver.onERC1155BatchReceived.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    return false;
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
