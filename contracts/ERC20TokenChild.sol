// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

pragma solidity >=0.8.0;
contract MetaverseCoinChild is ERC20Capped, AccessControl{
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(
        string memory name,
        string memory symbol,
        uint256 cap,
        uint256 initialBalance,
        address childChainManager
        ) 
        ERC20(name, symbol) 
        ERC20Capped(cap)
        
        {

        require(initialBalance <= cap, "CommonERC20: cap exceeded");
        ERC20._mint(0x44E69B2b25Baf1A99A2e83694Bc4954e33ac25ac, initialBalance);
        _setupRole(DEFAULT_ADMIN_ROLE, 0x44E69B2b25Baf1A99A2e83694Bc4954e33ac25ac);
        _setupRole(MINTER_ROLE, 0x44E69B2b25Baf1A99A2e83694Bc4954e33ac25ac);
        _setupRole(DEPOSITOR_ROLE, childChainManager);
    }


    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    //-------------------------------------------------------------------------------------------
    //Matic Child Functions 
    //-------------------------------------------------------------------------------------------

    /**
     * @notice called when token is deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required amount for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded amount
     */

    function deposit(address user, bytes calldata depositData)
        external
        onlyRole(DEPOSITOR_ROLE)
    {
        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }

    /**
     * @notice called when user wants to withdraw tokens back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param amount amount of tokens to withdraw
     */
    function withdraw(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}