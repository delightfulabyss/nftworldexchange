// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./INFTWorldExchange.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "wearables-contracts/contracts/interfaces/IERC721CollectionV2.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTWorldExchangeImplmentationV1 is INFTWorldExchange, IERC721Receiver, AccessControlUpgradeable {
    using SafeMath for uint256;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public metaverseCoinAddress;
    mapping (string => uint256) public exchangeRates;
    mapping (address => string) public tokenRarities;
    mapping (string  => address) public wearableContracts;
    mapping (string => uint256) public numberTokenAvailable
    uint256 public base_fee;

    function initialize (address _metaverseCoin, address _admin, address[] memory _collections) external initializer() {

        //Parent initializer chain
        __AccessControl_init();
        _setupRole(ADMIN_ROLE, _admin);
        metaverseCoinAddress = _metaverseCoin;
        base_fee = 250000000000000000;
        exchangeRate["Common"] = 0;
        exchangeRate["Rare"] = 1000000000000000000;
        exchangeRate["Epic"] = 2000000000000000000;
        exchangeRate["Legendary"] = 3000000000000000000;
        exchangeRate["Mythic"] = 4000000000000000000;
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
        address collectionAddress = wearables[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        numberTokensAvailable[_collectionName] += _tokenIds.length;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            BaseERC721.safeTransferFrom(_msgSender(), address(this), _tokenIds[i]);
        }
        emit WearableDeposit(_msgSender(), _collectionName, _tokenIds);
    }

    function withdrawWearables(string memory _collectionName, uint256[] memory _tokenIds) virtual override external onlyRole(ADMIN_ROLE) {
        address collectionAddress = wearables[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        //Possibly need token approval here
        require(numberTokensAvailable[_collectionName] >= _tokenIds.length, "NFTWorldExchange#withdrawWearables: Available tokens does not match number provided");
        numberTokensAvailable[_collectionName] =  numberTokensAvailable[_collectionName].add(_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            BaseERC721.safeTransferFrom(address(this), _msgSender(), _tokenIds[i]);
        }
        emit WearableWithdraw(_msgSender(), _collectionName, _tokenIds);
    }

    function addCollectionSupport(address _address) virtual override external onlyRole(ADMIN_ROLE){
        _addCollectionSupport(_address);
    }

    function _addCollectionSupport(address _address) internal {
        IERC721 BaseERC721 = IERC721(_address);
        string memory collectionName = BaseERC721.name();
        wearables[collectionName] = _address;

        emit CollectionSupportAdded(collectionName, _address);
    }

    function getWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) virtual override external {
        address collectionAddress = wearables[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        IERC721CollectionV2 WearablesCollection = IERC721CollectionV2(collectionAddress);
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        string memory rarity = WearablesCollection.items(_itemId).rarity;
        uint256 amount = exchangeRate[rarity];
        //Check if token is owned by exchange contract
        require(BaseERC721.ownerOf(_tokenId) == address(this), "NFTWorldExchange#getWearable: Token is not available");
        //Calculate the amount owed and make sure the user has that balance
        require(MetaverseCoin.balanceOf(_msgSender()) >= amount, "NFTWorldExchange#getWearable: Exchange rate exceeds Metaverse Coin balance");
        numberTokensAvailable[_collectionName] = numberTokensAvailable[_collectionName].sub(1);
        //Transfer metaverse coin to exchange contract
        MetaverseCoin.approve(address(this), amount);
        MetaverseCoin.transferFrom(_msgSender(), address(this), amount);
        //Transfer token to user
        BaseERC721.safeTranferFrom(address(this), _msgSender(), _tokenId);
        emit WearableExchanged(_msgSender(), _collectionName, _tokenId, amount);
    }

    function returnWearable(string memory _collectionName, uint256 _tokenId) virtual override external {
        address collectionAddress = wearables[_collectionName];
        IERC721 BaseERC721 = IERC721(collectionAddress);
        IERC721CollectionV2 WearablesCollection = IERC721CollectionV2(collectionAddress);
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(wearables[_collectionName] != 0, "NFTWorldExchange#returnWearable: Not valid collection name");
        numberTokensAvailable[_collectionName]++;
        BaseERC721.safeTransferFrom(_msgSender(), address(this), _tokenId);
        string memory rarity = WearablesCollection.items(_itemId).rarity;
        uint256 adjustedAmount = exchangeRate[rarity].sub(exchangeRate[rarity].div(base_fee));
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