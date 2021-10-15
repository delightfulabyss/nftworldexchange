// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface INFTWorldExchange {

    function depositMetaverseCoin (uint256 _amount) external returns (boolean);

    function withdrawMetaverseCoin (uint256 _amount) external returns (boolean);

    function depositWearables(string _collectionName, uint256[] _tokenIds) external returns (boolean);

    function withdrawWearables(string _collectionName, uint256[] _tokenIds) external returns (boolean);

    function getWearable(string _collectionName, uint256 _tokenId);

    function returnWearable(string _collectionName, uint256 _tokenId);

    function setWearableAddress(string _collectionName, address _address) external;

    event MetaverseCoinDeposit(address indexed from, uint256 indexed value);
    event MetaverseCoinWithdraw(address indexed to, uint256 indexed value);
    event WearableDeposit(address indexed from, string indexed collectionName, uint256[] indexed tokenIds);
    event WearableWithdraw(address indexed to, string indexed collectionName, uint256[] indexed tokenIds);
    event WearableExchanged(address indexed to, string indexed collectionName, uint256 indexed tokenId, uint256 indexed amount);
    event WearableReturned(address indexed from, string indexed collectionName, uint256 indexed tokenId, uint256 indexed amount);
    event WearableAddressSet(string collectionName, address _address);
}