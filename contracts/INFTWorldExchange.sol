// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface INFTWorldExchange {
    /**
     * @dev Emitted when `amount` is transferred from `from` to the exchange contract by a user.
     */
    event MetaverseCoinDeposit(address indexed from, uint256 indexed amount);
    /**
     * @dev Emitted when `amount` is transferred from the exchange *contract to `to` by a user.
     */
    event MetaverseCoinWithdraw(address indexed to, uint256 indexed amount);

    /**
     * @dev Emitted when `tokenIds` are transferred from `from` to the exchange contract by a user.
     */
    event WearableDeposit(address indexed from, string indexed collectionName, uint256[] indexed tokenIds);

    /**
     * @dev Emitted when `tokenIds` are transferred from the exchange contract to `to` by a user.
     */
    event WearableWithdraw(address indexed to, string indexed collectionName, uint256[] indexed tokenIds);

    /**
     * @dev Emitted when `tokenId` of collection `collectionName` is transferred from the exchange contract to `to` by a user and `amount` is transferred from `to` to the exchange contract.
     */
    event WearableExchanged(address indexed to, string collectionName, uint256 indexed tokenId, uint256 indexed amount);

    /**
     * @dev Emitted when `tokenId` of collection `collectionName` is transferred from `from` to the exchange contract by a user and `amount` is transferred from the exchange contract to `from`.
     */
    event WearableReturned(address indexed from, string collectionName, uint256 indexed tokenId, uint256 indexed amount);

    /**
     * @dev Emitted when `tokenIds` from `collectionName` are queried from the exchange contract.
     */
    event AvailableTokensQuery(string collectionName, uint256[] tokenIds);
    /**
     * @dev Emitted when `collectionName` is mapped to `_address` by a user.
     */
    event CollectionSupportAdded(string collectionName, address _address);

    /**
    * @notice Sends Metaverse Coin to the exchange contract.
    * @dev The user must approve the exchange contract to spend the prerequisite Metaverse Coin before calling this function.
    * @param _amount The amount of Metaverse Coin to be deposited.
     */
    function depositMetaverseCoin (uint256 _amount) external;

    /**
    * @notice Withdraws Metaverse Coin from the exchange contract.
    * @param _amount The amount of Metaverse Coin to be withdrawn.
     */
    function withdrawMetaverseCoin (uint256 _amount) external;

    /**
    * @notice Sends NFTs to the exchange contract.
    * @dev The user must approve the exchange contract to transfer the NFTs before calling this function.
    * @param _collectionName The name of the collection.
    * @param _tokenIds The token ids of the NFTs to be deposited.
     */
    function depositWearables(string memory _collectionName, uint256[] memory _tokenIds) external;

    /**
    * @notice Withdraws NFTs from the exchange contract.
    * @param _collectionName The name of the collection.
    * @param _tokenIds The token ids of the NFTs to be withdrawn.
     */
    function withdrawWearables(string memory _collectionName, uint256[] memory _tokenIds) external;

    /**
    * @notice Returns all NFTs owned by the exchange contract.
    * @param _collectionName The name of the collection.
    * @return The token ids of the NFTs owned by the exchange contract.
     */
    function getAvailableTokens(string memory _collectionName) external view returns (uint256[] memory);

    /**
    * @notice Exchanges an NFT for the prequisite amount of Metaverse Coin.
    * @dev The user must approve the exchange contract to spend the prerequisite Metaverse Coin before calling this function.
    * @param _collectionName The name of the collection.
    * @param _itemId The item id of the NFT.
    * @param _tokenId The token id of the NFT.
     */
    function getWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) external;
    /**
    * @notice Sends an NFT in exchange for the original amount of Metaverse Coin minus a fee.
    * @dev The user must approve the exchange contract to transfer the NFT before calling this function.
    * @param _collectionName The name of the collection.
    * @param _itemId The item id of the NFT.
    * @param _tokenId The token id of the NFT.
     */
    function returnWearable(string memory _collectionName, uint256 _itemId, uint256 _tokenId) external;
    /**
    * @notice Adds the NFT contract name and address to the exchange contract.
    * @dev The user must call this function so that the exchange contract can know which NFT contract to call.
    * @param _address The address of the NFT contract.
    *
     */
    function addCollectionSupport(address _address) external;

}