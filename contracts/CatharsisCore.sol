pragma solidity ^0.8.4;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";

import { FractionatorERC721 } from "./fractalization/FractionatorERC721.sol";
import { FractionatorERC1155 } from "./fractalization/FractionatorERC1155.sol";
import { FractionatorCollection } from "./fractalization/FractionatorCollection.sol";
import { FractionAssembler } from "./fractalization/FractionAssembler.sol";
import { FractionalToken } from "./fractalization/FractionalToken.sol";

import { IFractionalToken } from "./interfaces/IFractionalToken.sol";

// @dev Core contract
contract CatharsisCore is Context {

    uint256 public MAX_SHARES_PER_TOKEN = 1_000_000_000;

    address public fractionToken;
    address public fractionalizable;

    address public fractionatorErc721;
    address public fractionatorErc1155;
    address public fractionatorCollection;
    address public fractionAssembler;

    address public governance;

    event GovernanceChanged(address account);

    constructor(address _gov, address _fractionalizable) {
        governance = _gov;
        fractionalizable = _fractionalizable;

        fractionToken = address(new FractionalToken("https://api.catarsis.network/token/{id}.json"));
        fractionatorErc721 = address(new FractionatorERC721(IFractionalToken(fractionToken)));
        fractionatorErc721 = address(new FractionatorERC1155(IFractionalToken(fractionToken)));
        fractionatorCollection = address(new FractionatorCollection(IFractionalToken(fractionToken)));
        fractionAssembler = address(new FractionAssembler(IFractionalToken(fractionToken)));

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