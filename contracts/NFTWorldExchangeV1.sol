// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol;";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract NFTWorldExchangeImplmentationV1 {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public metaverseCoin;
    mapping public (string  => address) wearables;

    function initialize external initializer(address _metaverseCoin, address address _admin) {

        //Parent initializer chain
        __AccessControl_init();

        _setupRole(ADMIN_ROLE, _admin);
    }

    function depositMetaverseCoin (uint256 _amount) external onlyRole(ADMIN_ROLE) returns (boolean) {
        require(IERC20(metaverseCoin).balanceOf(msg.sender) >= _amount, "NFTWorldExchange#depositMetaverseCoin: Deposit amount exceeds Metaverse Coin balance");
        IERC20(metaverseCoin).approve(address(this), _amount);
        IERC20(metaverseCoin).transferFrom(msg.sender, address(this), _amount);
        return true;
    }

    function withdrawMetaverseCoin (uint256 _amount) external onlyRole(ADMIN_ROLE) returns (boolean) {
        require(IERC20(metaverseCoin).balanceOf(address(this)) >= _amount, "NFTWorldExchange#withdrawMetaverseCoin: Withdraw amount exceeds Metaverse Coin balance");
        IERC20(metaverseCoin).transferFrom(msg.sender, address(this), _amount);
        return true;
    }
}