// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./presets/KIP37PresetMinterPauser.sol";
import "./extensions/KIP37Burnable.sol";
import "./extensions/KIP37URIStorage.sol";
import "./extensions/KIP37Mintable.sol";
import "./extensions/KIP37Burnable.sol";
import "./OwnerRole.sol";
import "./Base64.sol"; 

contract BasicToken is KIP37Burnable, KIP37URIStorage, KIP37PresetMinterPauser, KIP37Mintable, OwnerRole { 
    string private _contractURI;

    constructor (address payable owner, string memory name, string memory symbol) KIP37PresetMinterPauser(symbol, name) 
                                                                                  OwnerRole(owner) {
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(KIP37, KIP37Burnable, KIP37PresetMinterPauser, KIP37Mintable)
        returns (bool)
    {
        return
            KIP37PresetMinterPauser.supportsInterface(interfaceId) ||
            KIP37Burnable.supportsInterface(interfaceId) ||
            KIP37Pausable.supportsInterface(interfaceId);
    }

    /* admin function */
    
    function setContractMetadata(string memory contractMetadata) public onlyOwner() {
        _contractURI = string(abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        contractMetadata
                    )
                )
            ));
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function setURI(uint256 tokenId, string memory tokenURI) public onlyOwner() {
        _setURI(tokenId, tokenURI);
    }

    function setBaseURI(string memory baseURI) public onlyOwner() {
         _setBaseURI(baseURI);
    }

    /* minter function */
    function processLock(uint256[] calldata tokenIds) public {
        _processLockTokens(tokenIds);
    }

    function unProcessLockTokens(uint256[] calldata tokenIds) public {
        _processUnLockTokens(tokenIds);
    }

    /* override functions */

    function _setURI(uint256 tokenId, string memory tokenURI) internal override(KIP37Mintable, KIP37URIStorage) {
        KIP37URIStorage._setURI(tokenId, tokenURI);
    }

    function _setBaseURI(string memory baseURI) internal override(KIP37Mintable, KIP37URIStorage){
        KIP37URIStorage._setBaseURI(baseURI); 
    }

    function uri(uint256 tokenId) public view override(KIP37, KIP37PresetMinterPauser, KIP37Mintable, KIP37URIStorage) returns (string memory) {
        return KIP37URIStorage.uri(tokenId);
    }

    function create(uint256 id, uint256 initialSupply, string memory uri_) public override(KIP37Mintable) returns (bool) {
        return KIP37Mintable.create(id, initialSupply, uri_);
    }
    
    function mintBatch(address to, uint256[] memory tokenIds, uint256[] memory amounts) public override(KIP37Mintable) {
        KIP37Mintable.mintBatch(to, tokenIds, amounts);
    }

    function burn(address to, uint256 tokenId, uint256 amount) public override(KIP37Burnable) {
        KIP37Burnable.burn(to, tokenId, amount);
    }

    function burnBatch(address to, uint256[] memory tokenIds, uint256[] memory amounts) public override(KIP37Burnable) {
        KIP37Burnable.burnBatch(to, tokenIds, amounts);
    }

    function pause(uint256 tokenId) public override(KIP37PresetMinterPauser) {
        KIP37PresetMinterPauser.pause(tokenId);
    }

    function unpause(uint256 tokenId) public override(KIP37PresetMinterPauser) {
        KIP37PresetMinterPauser.unpause(tokenId);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal override(KIP37, KIP37PresetMinterPauser) {
        KIP37PresetMinterPauser._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _processLockTokens(uint256[] calldata tokenIds) internal override(KIP37, KIP37Mintable) {
        KIP37Mintable._processLockTokens(tokenIds);
    }

    function _processUnLockTokens(uint256[] calldata tokenIds) internal override(KIP37, KIP37Mintable) {
        KIP37Mintable._processUnLockTokens(tokenIds);
    }

}
