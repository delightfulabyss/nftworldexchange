// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface INFTWorldExchange {

    function depositMetaverseCoin (uint256 _amount) external;

    function withdrawMetaverseCoin (uint256 _amount) external;

    function depositWearables(string memory _collectionName, uint256[] memory _tokenIds, bytes calldata _data) external;

    function withdrawWearables(string memory _collectionName, uint256[] memory _tokenIds, bytes calldata _data) external;

    function getWearable(string memory _collectionName, uint256 _tokenId, bytes calldata _data) external;

    function returnWearable(string memory _collectionName, uint256 _tokenId, bytes calldata _data) external;

    function setWearableAddress(string memory _collectionName, address _address) external;

    event MetaverseCoinDeposit(address indexed from, uint256 indexed value);
    event MetaverseCoinWithdraw(address indexed to, uint256 indexed value);
    event WearableDeposit(address indexed from, string indexed collectionName, uint256[] indexed tokenIds);
    event WearableWithdraw(address indexed to, string indexed collectionName, uint256[] indexed tokenIds);
    event WearableExchanged(address indexed to,  uint256 indexed tokenId, uint256 indexed amount, string collectionName);
    event WearableReturned(address indexed from, uint256 indexed tokenId, uint256 indexed amount, string collectionName);
    event WearableAddressSet(string collectionName, address _address);
}