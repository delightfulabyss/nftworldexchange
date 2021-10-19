// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./INFTWorldExchange.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTWorldExchangeImplmentationV1 is INFTWorldExchange, IERC721Receiver, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public metaverseCoinAddress;
    mapping (string => uint256) public exchangeRate;
    struct Wearable {
        address contractAddress;
        uint256 availableTokens;
        string rarity;
    }
    mapping (string  => Wearable) public wearables;
    uint256 public base_fee;

    function initialize (address _metaverseCoin, address _admin) external initializer() {

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
    }

    function depositMetaverseCoin (uint256 _amount) virtual override external onlyRole(ADMIN_ROLE) {
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(MetaverseCoin.balanceOf(msg.sender) >= _amount, "NFTWorldExchange#depositMetaverseCoin: Deposit amount exceeds Metaverse Coin balance");
        MetaverseCoin.approve(address(this), _amount);
        MetaverseCoin.transferFrom(msg.sender, address(this), _amount);
        emit MetaverseCoinDeposit(msg.sender, _amount);
    }

    function withdrawMetaverseCoin (uint256 _amount) virtual override external onlyRole(ADMIN_ROLE) {
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(MetaverseCoin.balanceOf(address(this)) >= _amount, "NFTWorldExchange#withdrawMetaverseCoin: Withdraw amount exceeds Metaverse Coin balance");
        //Possibly need token approval here
        MetaverseCoin.transferFrom(msg.sender, address(this), _amount);
        emit MetaverseCoinWithdraw(msg.sender, _amount);
    }

    function depositWearables(string memory _collectionName, uint256[] memory _tokenIds, bytes calldata _data) virtual override external onlyRole(ADMIN_ROLE) {
        IERC721 WearablesCollection = IERC721(wearables[_collectionName].contractAddress);
        wearables[_collectionName].availableTokens += _tokenIds.length;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            WearablesCollection.safeTransferFrom(msg.sender, address(this), _tokenIds[i], _data);
        }
        emit WearableDeposit(msg.sender, _collectionName, _tokenIds);
    }

    function withdrawWearables(string memory _collectionName, uint256[] memory _tokenIds, bytes calldata _data) virtual override external onlyRole(ADMIN_ROLE) {
        IERC721 WearablesCollection = IERC721(wearables[_collectionName].contractAddress);
        //Possibly need token approval here
        require(wearables[_collectionName].availableTokens >= _tokenIds.length, "NFTWorldExchange#withdrawWearables: Available tokens does not match number provided");
        wearables[_collectionName].availableTokens -= _tokenIds.length;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            WearablesCollection.safeTransferFrom(address(this), msg.sender, _tokenIds[i], _data);
        }
        emit WearableWithdraw(msg.sender, _collectionName, _tokenIds);
    }

    function setWearableAddress(string memory _collectionName, address _address) virtual override external onlyRole(ADMIN_ROLE){
        wearables[_collectionName].contractAddress = _address;
        emit WearableAddressSet(_collectionName, _address);
    }

    function getWearable(string memory _collectionName, uint256 _tokenId) virtual override external {
        IERC721 WearablesCollection = IERC721(wearables[_collectionName].contractAddress);
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        uint256 amount = exchangeRate[wearables[_collectionName].rarity];
        //Check if token is owned by exchange contract
        require(WearablesCollection.ownerOf(_tokenId) == address(this), "NFTWorldExchange#getWearable: Token is not available");
        //Calculate the amount owed and make sure the user has that balance
        require(MetaverseCoin.balanceOf(msg.sender) >= amount, "NFTWorldExchange#getWearable: Exchange rate exceeds Metaverse Coin balance");
        wearables[_collectionName].availableTokens--;
        //Transfer metaverse coin to exchange contract
        MetaverseCoin.approve(address(this), amount);
        MetaverseCoin.transferFrom(msg.sender, address(this), amount);
        //Transfer token to user
        WearablesCollection.safeTranferFrom(address(this), msg.sender, _tokenId, "");
        emit WearableExchanged(msg.sender, _collectionName, _tokenId, amount);
    }

    function returnWearable(string memory _collectionName, uint256 _tokenId) virtual override external {
        IERC721 WearablesCollection = IERC721(wearables[_collectionName].contractAddress);
        IERC20 MetaverseCoin = IERC20(metaverseCoinAddress);
        require(wearables[_collectionName] != 0, "NFTWorldExchange#returnWearable: Not valid collection name");
        wearables[_collectionName].availableTokens++;
        WearablesCollection.safeTranferFrom(msg.sender, address(this), _tokenId, "");
        uint256 adjustedAmount = exchangeRate[wearables[_collectionName].rarity] / base_fee;
        MetaverseCoin.transferFrom(address(this), msg.sender, adjustedAmount);
        emit WearableReturned(msg.sender, _collectionName, _tokenId, adjustedAmount);
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