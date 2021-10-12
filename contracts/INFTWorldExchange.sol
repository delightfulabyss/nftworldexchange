// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface INFTWorldExchange {

    function depositMetaverseCoin (uint256 _amount) external returns (boolean);

    function withdrawMetaverseCoin (uint256 _amount) external returns (boolean)

    function depositWearables(uint256[] _tokenIds) external returns (boolean)

    function withdrawWearables(uint256[] _tokenIds) external returns (boolean)

    event MetaverseCoinDeposit(address indexed from, uint256 indexed value);
    event MetaverseCoinWithdraw(address indexed to, uint256 indexed value);
    event WearableDeposit(address indexed from, uint256[] indexed tokenIds);
    event WearableWithdraw(address indexed to, uint256[] indexed tokenIds);
}