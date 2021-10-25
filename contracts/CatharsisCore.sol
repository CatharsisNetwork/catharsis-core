pragma solidity ^0.8.4;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { FractionalToken } from "./FractionalToken.sol";
import { Fractionalizable } from "./management/Fractionalizable.sol";
import { FractionAssembler } from "./fractalization/FractionAssembler.sol";
import { FractionatorERC721 } from "./fractalization/FractionatorERC721.sol";
import { FractionatorERC1155 } from "./fractalization/FractionatorERC1155.sol";
import { IFractionalToken } from "./interfaces/IFractionalToken.sol";

// @dev Core contract
contract CatharsisCore is Context {

    uint256 public MAX_SHARES_PER_TOKEN = 1_000_000_000;

    address public fraction;
    address public fractionalizable;
    address public unwrapper;
    address public fractionsInterface721;
    address public fractionsInterface1155;

    address public governance;

    event GovernanceChanged(address account);

    constructor(address _gov) {
        governance = _gov;

        fraction = address(new FractionalToken("https://api.catarsis.network/token/{id}.json"));
        fractionalizable = address(new Fractionalizable());
        unwrapper = address(new FractionAssembler(IFractionalToken(fraction)));
        fractionsInterface721 = address(new FractionatorERC721(IFractionalToken(fraction)));
        fractionsInterface1155 = address(new FractionatorERC1155(IFractionalToken(fraction)));

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