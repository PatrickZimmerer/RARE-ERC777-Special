// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC777/ERC777.sol";

/// @title A contract for a basic ERC20 coin which is capped at 100 million token
/// @author Patrick Zimmerer
/// @notice This contract is to demo a sample ERC20 capped contract
/// @dev When deploying you can choose a token name & symbol => deployer == owner
abstract contract ERC777Bonding is ERC777, ERC20Capped {
    uint256 private constant MAX_SUPPLY = 100_000_000 * 1e18;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC20Capped(MAX_SUPPLY) {}

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
