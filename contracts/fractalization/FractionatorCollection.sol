pragma solidity ^0.8.4;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from  "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { IFractionalToken } from "../interfaces/IFractionalToken.sol";
import { ICatharsisCore } from "../interfaces/ICatharsisCore.sol";

contract FractionatorCollection is Context {

    enum TokenProtocol {
        ERC721,
        ERC1155
    }

    struct Token {
        address token;
        TokenProtocol protocol;
        uint256 tokenId;
        uint256 amount;
        bytes data;
    }

    IFractionalToken public fraction;

    address public catharsisCore;

    constructor(IFractionalToken _fractionToken) {
        catharsisCore = _msgSender();
        fraction = _fractionToken;
    }

    function split(
        Token[] calldata _tokens,
        uint256 _shares
    )
        external
        returns (uint256 fTokenId)
    {
        require(
            _shares <= ICatharsisCore(catharsisCore).MAX_SHARES_PER_TOKEN() &&
            _shares > 0,
            "Core: wrong shares amount"
        );

        uint256 tokensLen = _tokens.length;
        uint256 i = 0;
        for (i; i < tokensLen; i++) {
            if (_tokens[i].protocol == TokenProtocol.ERC721) {
                _erc721Handler(_tokens[i]);
            } else {
                _erc1155Handler(_tokens[i]);
            }
        }

        fTokenId = fraction.mint(_msgSender(), uint256(fraction.decimals()), _tokens[i].data);
    }

    function _erc721Handler(Token memory _t) private {
        require(
            IERC721(_t.token).isApprovedForAll(_msgSender(), address(this)),
            "Wrapper ERC721: Token not approved"
        );
        require(
            IERC721(_t.token).ownerOf(_t.tokenId) == _msgSender(),
            "Wrapper ERC721: Not token holder"
        );

        IERC721(_t.token).safeTransferFrom(
            _msgSender(),
            address(this),
            _t.tokenId
        );
    }

    function _erc1155Handler(Token memory _t) private {
        require(
            IERC1155(_t.token).isApprovedForAll(_msgSender(), address(this)),
            "Wrapper ERC1155: Token not approved"
        );
        require(
            IERC1155(_t.token).balanceOf(_msgSender(), _t.tokenId) >= _t.amount,
            "Wrapper ERC1155: Not token holder"
        );

        IERC1155(_t.token).safeTransferFrom(
            _msgSender(),
            address(this),
            _t.tokenId,
            _t.amount,
            _t.data
        );
    }
}