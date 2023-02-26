// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

// QUESTION: Is there a way to avoid overriding every single function if you inherrit from 2 contracts which inherit
//           from the same contract as ERC777 & ERC20Capped => inherit both from ERC20,
//           also is there a way to avoid filling both the ERC777 and ERC20 constructor with the same variables?
// ANSWER:  Just inherit from ERC777 and implement the Capped function by copy pasting the function from ERC20Capped

import "./MyGodModeCoin.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";

/// @title A contract for a ERC777 coin which is capped at 100 million token and has a linear bonding curve
/// @author Patrick Zimmerer
/// @notice This contract is to demo a simple ERC777 token where you can buy and sell bond to a bonding curve
/// @dev When deploying you can choose a token name, symbol and a sellingFee in percent which gets set in the constructor
contract ERC777Bonding is MyGodModeCoin, IERC777Recipient {
    uint256 public constant SELLING_FEE_IN_PERCENT = 5;
    uint256 public constant BASE_PRICE = 0.0001 ether; // shorthand for 18 zeros
    uint256 public constant INCREASE_PRICE_PER_TOKEN = 0.01 gwei; // shorthand for 9 zeros => 10000000 wei or 0.00000000001 ether

    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH =
        keccak256("ERC777TokensRecipient");

    /**
     * @dev `defaultOperators` may be an empty array.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address[] memory _defaultOperators
    ) MyGodModeCoin(_name, _symbol, _defaultOperators) {}

    /**
     * @notice let's a user buy tokens when he sent the right amount of ETH
     */
    function buyTokens(uint256 _amount) external payable {
        require(
            msg.value == calculateBuyingPrice(_amount),
            "You did not send the right amount of ETH"
        );
        _buyTokens(msg.sender, _amount);
    }

    /**
     * ------------- SELL FUNCTION -----------------
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {}

    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {}

    /**
     * @notice calculates the price _amount tokens would cost to buy
     * @notice as information for the user to know how much eth to send
     * @notice also a helper to reduce complexity in buyTokens function
     */
    function calculateBuyingPrice(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 startingPrice = BASE_PRICE +
            (totalSupply() * INCREASE_PRICE_PER_TOKEN);
        uint256 endingPrice = BASE_PRICE +
            ((totalSupply() + _amount) * INCREASE_PRICE_PER_TOKEN);
        uint256 buyingPrice = ((startingPrice + endingPrice) * _amount) / 2;
        return buyingPrice;
    }

    /**
     * @notice calculates the price _amount tokens would get you when you'd sell them
     * @notice as information for the user to know how much eth they will get for _amount tokens
     * @notice also a helper to reduce complexity in _callTokensReceived() / sell function
     */
    function calculateSellingPrice(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 startingPrice = BASE_PRICE +
            (totalSupply() * INCREASE_PRICE_PER_TOKEN);
        uint256 endingPrice = BASE_PRICE +
            ((totalSupply() - _amount) * INCREASE_PRICE_PER_TOKEN);
        uint256 sellingPrice = (((startingPrice + endingPrice) * _amount) / 2);
        sellingPrice =
            sellingPrice -
            (sellingPrice * SELLING_FEE_IN_PERCENT) /
            100;
        return sellingPrice;
    }
}
