// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface INFTWorldExchange {

    function depositMetaverseCoin (uint256 _amount) external;

    function withdrawMetaverseCoin (uint256 _amount) external;

    function depositWearables(string memory _collectionName, uint256[] memory _tokenIds) external;

    function withdrawWearables(string memory _collectionName, uint256[] memory _tokenIds) external;

    function getAvailableTokens(string memory _collectionName) external view returns (uint256[] memory);

    function getWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) external;

    function returnWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) external;

    function addCollectionSupport(address _address) external;

    event MetaverseCoinDeposit(address indexed from, uint256 indexed value);
    event MetaverseCoinWithdraw(address indexed to, uint256 indexed value);
    event WearableDeposit(address indexed from, string indexed collectionName, uint256[] indexed tokenIds);
    event WearableWithdraw(address indexed to, string indexed collectionName, uint256[] indexed tokenIds);
    event WearableExchanged(address indexed to, string collectionName, uint256 indexed tokenId, uint256 indexed amount);
    event WearableReturned(address indexed from, string collectionName, uint256 indexed tokenId, uint256 indexed amount);
    event CollectionSupportAdded(string collectionName, address _address);
}