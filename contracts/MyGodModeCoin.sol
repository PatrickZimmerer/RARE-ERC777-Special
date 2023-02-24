// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A contract for a basic ERC20 coin which is capped at 100 million token
/// @author Patrick Zimmerer
/// @notice This contract is to demo a sample ERC20 capped contract
/// @dev When deploying you can choose a token name & symbol => deployer == owner
abstract contract MyGodModeCoin is ERC777, Ownable {
    uint256 private constant MAX_SUPPLY = 100_000_000 * 1e18;

    mapping(address => uint256) bannedUsers; // using uint instead of bool to reduce gas cost

    constructor(
        string memory _name,
        string memory _symbol,
        address[] memory _operators
    ) ERC777(_name, _symbol, _operators) {}

    /**
     * @notice Admin function to transfer tokens between addresses at will
     * @param _from Address to transfer tokens from
     * @param _to Address to transfer tokens to
     * @param _amount Amount of tokens to transfer
     */
    function onlyAdminTransfer(
        address _from,
        address _to,
        uint256 _amount,
        bytes memory _data,
        bytes memory _operatorData
    ) external onlyOwner {
        _send(_from, _to, _amount, _data, _operatorData, true);
    }

    /**
     * @notice Admin function to withdraw ETH from the contract
     */
    function adminWithdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @notice Only admin can ban/unban users from using the contract
     * @dev If you want to ban a User pass in the number 1 if you want to unban the user
     * @dev it is recommended to pass in a number > 1 like 2 since setting
     * @dev a non-zero to a non-zero value costs only 5000 gas instead of 20_000gas
     */
    function banOrUnbanUser(
        address _userAddress,
        uint256 _banStatus
    ) external onlyOwner {
        bannedUsers[_userAddress] = _banStatus;
    }

    function _buyTokens(address account, uint256 amount) internal {
        require(totalSupply() + amount <= MAX_SUPPLY, "ERC20: cap exceeded");
        _mint(account, amount, "", "");
    }

    /**
     * @notice Checks if one of the addresses is banned by the admin
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(
            bannedUsers[from] != 1 && bannedUsers[operator] != 1,
            "The address you are trying to send from is banned"
        );
        require(
            bannedUsers[to] != 1 && bannedUsers[operator] != 1,
            "The address you are trying to send to is banned"
        );
        super._beforeTokenTransfer(operator, from, to, amount);
    }

    /**
     * @notice Only admin can ban/unban users from using the contract
     * @dev If you want to ban a User pass in the number 1 if you want to unban the user
     * @dev it is recommended to pass in a number > 1 like 2 since setting
     * @dev a non-zero to a non-zero value costs only 5000 gas instead of 20_000gas
     */
    function showBannedStatus(
        address _address
    ) external view returns (uint256) {
        return bannedUsers[_address];
    }
}
