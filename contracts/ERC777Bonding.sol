// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./MyGodModeCoin.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

// QUESTION: Is there a way to avoid overriding every single function if you inherrit from 2 contracts which inherit
//           from the same contract as ERC77 & ERC20Capped => inherit both from ERC20,
//           also is there a way to avoid filling both the ERC777 and ERC20 constructor with the same variables?

/// @title A contract for a ERC777 coin which is capped at 100 million token and has a linear bonding curve
/// @author Patrick Zimmerer
/// @notice This contract is to demo a simple ERC777 token where you can buy and sell bond to a bonding curve
/// @dev When deploying you can choose a token name, symbol and a sellingFee in percent which gets set in the constructor
contract ERC777Bonding is Ownable, ERC777, MyGodModeCoin {
    uint256 public constant SELLING_FEE_IN_PERCENT;
    uint256 public constant BASE_PRICE = 0.0001 ether; // shorthand for 18 zeros
    uint256 public constant INCREASE_PRICE_PER_TOKEN = 0.01 gwei; // shorthand for 9 zeros => 10000000 wei or 0.00000000001 ether

    /**
     * @dev `defaultOperators` may be an empty array.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address[] memory _defaultOperators
    ) MyGodModeCoin(_name, _symbol) ERC777(_name, _symbol, _defaultOperators) {}

    function calculateBuyingPrice(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 startingPrice = BASE_PRICE +
            (totalSupply() * INCREASE_PRICE_PER_TOKEN);
        uint256 endingPrice = BASE_PRICE +
            ((totalSupply() + _amount) * INCREASE_PRICE_PER_TOKEN);
        uint256 buyingPrice = ((startingPrice + endingPrice) / 2) * _amount;
        return buyingPrice;
    }

    function calculateSellingPrice(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 startingPrice = BASE_PRICE +
            (totalSupply() * INCREASE_PRICE_PER_TOKEN);
        uint256 endingPrice = BASE_PRICE +
            ((totalSupply() - _amount) * INCREASE_PRICE_PER_TOKEN);
        uint256 sellingPrice = (((startingPrice + endingPrice) / 2) * _amount);
        sellingPrice =
            sellingPrice -
            (sellingPrice / 100) *
            SELLING_FEE_IN_PERCENT;
        return sellingPrice;
    }

    function buyTokens(uint256 _amount) external payable {
        require(
            msg.value == calculateBuyingPrice(_amount),
            "You did not send the right amount of ETH"
        );
        _mint(msg.sender, _amount);
    }

    /**
     * ------------- SELL FUNCTION -----------------
     * @dev Call to.tokensReceived() if the interface is registered. Reverts if the recipient is a contract but
     * tokensReceived() was not registered for the recipient
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(
            to,
            _TOKENS_RECIPIENT_INTERFACE_HASH
        );
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(
                operator,
                from,
                to,
                amount,
                userData,
                operatorData
            );
        } else if (requireReceptionAck) {
            require(
                !to.isContract(),
                "ERC777: token recipient contract has no implementer for ERC777TokensRecipient"
            );
        }
    }

    // Functions that had to be overwritten since 2 contracts inherit the contract
    // ------------------------------------------------------------

    function _approve(
        address holder,
        address spender,
        uint256 value
    ) internal override(ERC20, ERC777) {
        super._approve(holder, spender, value);
    }

    function approve(
        address spender,
        uint256 value
    ) public override(ERC20, ERC777) returns (bool) {
        return super.approve(spender, value);
    }

    function allowance(
        address holder,
        address spender
    ) public view override(ERC20, ERC777) returns (uint256 test) {
        return super.allowance(holder, spender);
    }

    function balanceOf(
        address tokenHolder
    ) public view virtual override(ERC20, ERC777) returns (uint256) {
        return super.balanceOf(tokenHolder);
    }

    function decimals() public pure override(ERC20, ERC777) returns (uint8) {
        super.decimals;
    }

    function name()
        public
        view
        virtual
        override(ERC20, ERC777)
        returns (string memory)
    {
        super.name;
    }

    function symbol()
        public
        view
        virtual
        override(ERC20, ERC777)
        returns (string memory)
    {
        super.symbol;
    }

    function totalSupply()
        public
        view
        virtual
        override(ERC20, ERC777)
        returns (uint256)
    {
        super.totalSupply;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override(ERC20, ERC777) returns (bool) {
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual override(ERC20, ERC777) returns (bool) {
        return super.transferFrom(holder, recipient, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal override(ERC20, ERC777) {
        super._spendAllowance(owner, spender, amount);
    }
}
