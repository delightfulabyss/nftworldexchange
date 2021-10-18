// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IERC721BaseCollectionV2 {
    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _tokenIds, bytes memory _data) external;
}