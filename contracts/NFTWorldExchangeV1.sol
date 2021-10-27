// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./INFTWorldExchange.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./IERC721CollectionV2.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTWorldExchangeImplementationV1 is INFTWorldExchange, IERC721Receiver, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public metaverseCoinAddress;
    mapping (string => uint256) public exchangeRates;
    mapping (string  => address) public wearableContracts;
    uint256 public base_percentage;

    function initialize (address _metaverseCoin, address _admin, address[] memory _collections) external initializer() {

        //Parent initializer chain
        __AccessControl_init();
        _setupRole(ADMIN_ROLE, _admin);
        metaverseCoinAddress = _metaverseCoin;
        base_percentage = 25;
        exchangeRates["common"] = 0;
        exchangeRates["rare"] = 1000000000000000000;
        exchangeRates["epic"] = 2000000000000000000;
        exchangeRates["legendary"] = 3000000000000000000;
        exchangeRates["mythic"] = 4000000000000000000;
        for (uint256 i = 0; i < _collections.length; i++) {
            _addCollectionSupport(_collections[i]);
        }

    }

    function depositMetaverseCoin (uint256 _amount) virtual override external onlyRole(ADMIN_ROLE) {
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(MetaverseCoin.balanceOf(_msgSender()) >= _amount, "NFTWorldExchange#depositMetaverseCoin: Insufficient balance for deposit");
        MetaverseCoin.transferFrom(_msgSender(), address(this), _amount);
        emit MetaverseCoinDeposit(_msgSender(), _amount);
    }

    function withdrawMetaverseCoin (uint256 _amount) virtual override external onlyRole(ADMIN_ROLE) {
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(MetaverseCoin.balanceOf(address(this)) >= _amount, "NFTWorldExchange#withdrawMetaverseCoin: Insufficient balance for withdraw");
        MetaverseCoin.approve(_msgSender(), _amount);
        MetaverseCoin.transfer(_msgSender(), _amount);
        emit MetaverseCoinWithdraw(_msgSender(), _amount);
    }

    function depositWearables(string memory _collectionName, uint256[] memory _tokenIds) virtual override external onlyRole(ADMIN_ROLE) {
        address collectionAddress = wearableContracts[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            BaseERC721.safeTransferFrom(_msgSender(), address(this), _tokenIds[i]);
        }
        emit WearableDeposit(_msgSender(), _collectionName, _tokenIds);
    }

    function withdrawWearables(string memory _collectionName, uint256[] memory _tokenIds) virtual override external onlyRole(ADMIN_ROLE) {
        address collectionAddress = wearableContracts[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        require(getAvailableTokens(_collectionName).length >= _tokenIds.length, "NFTWorldExchange#withdrawWearables: Available tokens does not match number provided");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            BaseERC721.approve(_msgSender(), _tokenIds[i]);
            BaseERC721.safeTransferFrom(address(this), _msgSender(), _tokenIds[i]);
        }
        emit WearableWithdraw(_msgSender(), _collectionName, _tokenIds);
    }

    function addCollectionSupport(address _address) virtual override external onlyRole(ADMIN_ROLE){
        _addCollectionSupport(_address);
    }

    function _addCollectionSupport(address _address) internal {
        IERC721Metadata ERC721Metadata = IERC721Metadata(_address);
        string memory collectionName = ERC721Metadata.name();
        wearableContracts[collectionName] = _address;

        emit CollectionSupportAdded(collectionName, _address);
    }

    function getAvailableTokens(string memory _collectionName) public virtual override view returns (uint256[] memory) {
        require(wearableContracts[_collectionName] != address(0x0), "NFTWorldExchange#getAvailableTokens: Not valid collection name");
        address collectionAddress = wearableContracts[_collectionName];
        IERC721Enumerable ERC721Enumerable = IERC721Enumerable(collectionAddress);
        uint256 tokenNumber = ERC721Enumerable.balanceOf(address(this));
        uint256[] memory tokenIds = new uint256[](tokenNumber);
        uint256 i = tokenNumber;
        do{
            uint256 tokenId = ERC721Enumerable.tokenOfOwnerByIndex(address(this), tokenNumber - 1);
            tokenIds[i - 1] = tokenId;
            i--;
        }while(i != 0);
        return tokenIds;    
    }
    function getWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) virtual override external {
        address collectionAddress = wearableContracts[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        IERC721CollectionV2 WearablesCollection = IERC721CollectionV2(collectionAddress);
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        (string memory rarity, , , , , , ) = WearablesCollection.items(_itemId);
        uint256 amount = exchangeRates[rarity];
        //Check if token is owned by exchange contract
        require(BaseERC721.ownerOf(_tokenId) == address(this), "NFTWorldExchange#getWearable: Token is not available");
        //Calculate the amount owed and make sure the user has that balance
        require(MetaverseCoin.balanceOf(_msgSender()) >= amount, "NFTWorldExchange#getWearable: Insufficient token balance");
        if (amount != 0){
            //Transfer metaverse coin to exchange contract
            MetaverseCoin.transferFrom(_msgSender(), address(this), amount);
            //Transfer token to user
            BaseERC721.safeTransferFrom(address(this), _msgSender(), _tokenId);
            emit WearableExchanged(_msgSender(), _collectionName, _tokenId, amount);
        } else {
            BaseERC721.safeTransferFrom(address(this), _msgSender(), _tokenId);
            emit WearableExchanged(_msgSender(), _collectionName, _tokenId, 0);
        }

    }

    function returnWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) virtual override external {
        address collectionAddress = wearableContracts[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        IERC721CollectionV2 WearablesCollection = IERC721CollectionV2(collectionAddress);
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(wearableContracts[_collectionName] != address(0x0), "NFTWorldExchange#returnWearable: Not valid collection name");
        BaseERC721.safeTransferFrom(_msgSender(), address(this), _tokenId);
        (string memory rarity, , , , , , ) = WearablesCollection.items(_itemId);
        uint256 amount = exchangeRates[rarity];
        if (amount != 0){
            uint256 adjustedAmount =  amount  - (amount / (100 / base_percentage ));
            MetaverseCoin.transfer(_msgSender(), adjustedAmount);
            emit WearableReturned(_msgSender(), _collectionName, _tokenId, adjustedAmount);
        } else {
            emit WearableReturned(_msgSender(), _collectionName, _tokenId, 0);
        }

        
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
}