// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "src/RulesEngineGemTokenIntegration.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GEMToken is RulesEngineClientCustom, ERC20, Ownable {
    error ZeroAmount();

    constructor() ERC20("GEM Token", "GEMT") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external checkRulesBeforemint(to, amount) onlyOwner {
        if (amount == 0) revert ZeroAmount();
        _mint(to, amount);
    }

    // Burn tokens, callable by token holder
    function burn(uint256 amount) external {
        if (amount == 0) revert ZeroAmount();
        _burn(msg.sender, amount);
    }
}