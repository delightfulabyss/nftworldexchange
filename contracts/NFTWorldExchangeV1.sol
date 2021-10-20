// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./INFTWorldExchange.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "./IERC721CollectionV2.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTWorldExchangeImplmentationV1 is INFTWorldExchange, IERC721Receiver, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public metaverseCoinAddress;
    mapping (string => uint256) public exchangeRates;
    mapping (string  => address) public wearableContracts;
    mapping (string => uint256) public numberTokensAvailable;
    uint256 public base_fee;

    function initialize (address _metaverseCoin, address _admin, address[] memory _collections) external initializer() {

        //Parent initializer chain
        __AccessControl_init();
        _setupRole(ADMIN_ROLE, _admin);
        metaverseCoinAddress = _metaverseCoin;
        base_fee = 250000000000000000;
        exchangeRates["Common"] = 0;
        exchangeRates["Rare"] = 1000000000000000000;
        exchangeRates["Epic"] = 2000000000000000000;
        exchangeRates["Legendary"] = 3000000000000000000;
        exchangeRates["Mythic"] = 4000000000000000000;
        for (uint256 i = 0; i < _collections.length; i++) {
            _addCollectionSupport(_collections[i]);
        }
    }

    function depositMetaverseCoin (uint256 _amount) virtual override external onlyRole(ADMIN_ROLE) {
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(MetaverseCoin.balanceOf(_msgSender()) >= _amount, "NFTWorldExchange#depositMetaverseCoin: Deposit amount exceeds Metaverse Coin balance");
        MetaverseCoin.approve(address(this), _amount);
        MetaverseCoin.transferFrom(_msgSender(), address(this), _amount);
        emit MetaverseCoinDeposit(_msgSender(), _amount);
    }

    function withdrawMetaverseCoin (uint256 _amount) virtual override external onlyRole(ADMIN_ROLE) {
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(MetaverseCoin.balanceOf(address(this)) >= _amount, "NFTWorldExchange#withdrawMetaverseCoin: Withdraw amount exceeds Metaverse Coin balance");
        //Possibly need token approval here
        MetaverseCoin.transferFrom(_msgSender(), address(this), _amount);
        emit MetaverseCoinWithdraw(_msgSender(), _amount);
    }

    function depositWearables(string memory _collectionName, uint256[] memory _tokenIds) virtual override external onlyRole(ADMIN_ROLE) {
        address collectionAddress = wearableContracts[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        numberTokensAvailable[_collectionName] += _tokenIds.length;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            BaseERC721.safeTransferFrom(_msgSender(), address(this), _tokenIds[i]);
        }
        emit WearableDeposit(_msgSender(), _collectionName, _tokenIds);
    }

    function withdrawWearables(string memory _collectionName, uint256[] memory _tokenIds) virtual override external onlyRole(ADMIN_ROLE) {
        address collectionAddress = wearableContracts[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        //Possibly need token approval here
        require(numberTokensAvailable[_collectionName] >= _tokenIds.length, "NFTWorldExchange#withdrawWearables: Available tokens does not match number provided");
        numberTokensAvailable[_collectionName] -= _tokenIds.length;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
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
        require(MetaverseCoin.balanceOf(_msgSender()) >= amount, "NFTWorldExchange#getWearable: Exchange rate exceeds Metaverse Coin balance");
        numberTokensAvailable[_collectionName] --;
        //Transfer metaverse coin to exchange contract
        MetaverseCoin.approve(address(this), amount);
        MetaverseCoin.transferFrom(_msgSender(), address(this), amount);
        //Transfer token to user
        BaseERC721.safeTransferFrom(address(this), _msgSender(), _tokenId);
        emit WearableExchanged(_msgSender(), _collectionName, _tokenId, amount);
    }

    function returnWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) virtual override external {
        address collectionAddress = wearableContracts[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        IERC721CollectionV2 WearablesCollection = IERC721CollectionV2(collectionAddress);
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(wearableContracts[_collectionName] != address(0x0), "NFTWorldExchange#returnWearable: Not valid collection name");
        numberTokensAvailable[_collectionName]++;
        BaseERC721.safeTransferFrom(_msgSender(), address(this), _tokenId);
        (string memory rarity, , , , , , ) = WearablesCollection.items(_itemId);
        uint256 adjustedAmount = exchangeRates[rarity] - (exchangeRates[rarity] / base_fee );
        MetaverseCoin.transferFrom(address(this), _msgSender(), adjustedAmount);
        emit WearableReturned(_msgSender(), _collectionName, _tokenId, adjustedAmount);
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