// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface INFTWorldExchange {
    /**
     * @dev Emitted when `amount` is transferred from `from` to the *exchange contract by the contract admin.
     */
    event MetaverseCoinDeposit(address indexed from, uint256 indexed amount);
    /**
     * @dev Emitted when `amount` is transferred from the exchange *contract to `to` by the contract admin.
     */
    event MetaverseCoinWithdraw(address indexed to, uint256 indexed amount);

    /**
     * @dev Emitted when `tokenIds` are transferred from `from` to the *exchange contract by the contract admin.
     */
    event WearableDeposit(address indexed from, string indexed collectionName, uint256[] indexed tokenIds);

    /**
     * @dev Emitted when `tokenIds` are transferred from the exchange *contract to `to` by the contract admin.
     */
    event WearableWithdraw(address indexed to, string indexed collectionName, uint256[] indexed tokenIds);

    /**
     * @dev Emitted when `tokenId` of collection `collectionName` is *transferred from the exchange contract to `to` by a user and *`amount` is transferred from `to` to the exchange contract.
     */
    event WearableExchanged(address indexed to, string collectionName, uint256 indexed tokenId, uint256 indexed amount);

    /**
     * @dev Emitted when `tokenId` of collection `collectionName` is *transferred from `from` to the exchange contract by a user and *`amount` is transferred from the exchange contract to `from`.
     */
    event WearableReturned(address indexed from, string collectionName, uint256 indexed tokenId, uint256 indexed amount);

    /**
     * @dev Emitted when `collectionName` is mapped to `address` by the contract admin.
     */
    event CollectionSupportAdded(string collectionName, address _address);

    
    function depositMetaverseCoin (uint256 _amount) external;

    function withdrawMetaverseCoin (uint256 _amount) external;

    function depositWearables(string memory _collectionName, uint256[] memory _tokenIds) external;

    function withdrawWearables(string memory _collectionName, uint256[] memory _tokenIds) external;

    function getAvailableTokens(string memory _collectionName) external view returns (uint256[] memory);

    function getWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) external;

    function returnWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) external;

    function addCollectionSupport(address _address) external;

}