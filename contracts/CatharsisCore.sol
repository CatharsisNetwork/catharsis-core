pragma solidity ^0.8.4;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";

// @dev Core contract
contract CatharsisCore is Context {

    uint256 public MAX_SHARES_PER_TOKEN = 1_000_000_000;

    address public governance;

    event GovernanceChanged(address account);

    constructor(address _gov) {
        governance = _gov;

        emit GovernanceChanged(_gov);
    }

    function setMaxSharesPerToken(uint256 _shares) external {
        require(_msgSender() == governance, "No access");
        require(_shares > 0, "low value");

        MAX_SHARES_PER_TOKEN = _shares;
    }

    function setGovernance(address _gov) external {
        require(_msgSender() == governance, "No access");
        require(_msgSender() != address(0), "Zero address");

        governance = _gov;
        emit GovernanceChanged(_gov);
    }
}