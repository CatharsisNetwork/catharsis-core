pragma solidity ^0.8.4;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { IFractionalToken } from "../interfaces/IFractionalToken.sol";

contract FractionAssembler is Context {

    IFractionalToken public fraction;

    address public catharsisCore;

    constructor(IFractionalToken _fractionToken) {
        catharsisCore = _msgSender();
        fraction = _fractionToken;
    }

    function collect(uint256 _fTokenId, uint256 _shares) external {
        require(
            IFractionalToken(fraction).isApprovedForAll(_msgSender(), address(this)),
            "Fraction token: Fraction token not approved"
        );
        require(
            IFractionalToken(fraction).balanceOf(_msgSender(), _fTokenId) >= _shares,
            "Fraction token: Not enough fraction token balance"
        );

//        if (_shares == IFractionalToken(fraction).)

        fraction.burn(_msgSender(), _fTokenId, _shares);
    }

    function collectBatch(uint256[] calldata _fTokenId, uint256[] calldata _shares) external {
        uint len = _fTokenId.length;

        require(
            len == _shares.length,
            "Fraction token: ids not equal to shares data"
        );
        require(
            IFractionalToken(fraction).isApprovedForAll(_msgSender(), address(this)),
            "Fraction token: Fraction token not approved"
        );

        for (uint256 i = 0; i < len; i++) {
            require(
                IFractionalToken(fraction).balanceOf(_msgSender(), _fTokenId[i]) >= _shares[i],
                "Fraction token: Not enough fraction token balance"
            );
        }

        fraction.burnBatch(_msgSender(), _fTokenId, _shares);
    }
}