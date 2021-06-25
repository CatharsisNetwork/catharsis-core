pragma solidity ^0.8.4;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IFractionalToken } from "../interfaces/IFractionalToken.sol";
import { ICatharsisCore } from "../interfaces/ICatharsisCore.sol";
import { IFractionalizable } from "../interfaces/IFractionalizable.sol";
import "../libs/FractStructs.sol";


contract FractionatorERC721 is Context, Ownable {

    struct Token {
        IERC721 token;
        uint256[] tokenIds;
        uint256[] shares;
        bytes data;
    }

    IFractionalToken public fraction;

    address public catharsisCore;

    constructor(IFractionalToken _fractionToken) {
        catharsisCore = _msgSender();
        fraction = _fractionToken;
    }

    function split(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _shares,
        bytes memory _data
    )
        external
        returns (uint256 fTokenId)
    {
        require(
            _shares <= ICatharsisCore(catharsisCore).MAX_SHARES_PER_TOKEN() &&
            _shares > 0,
            "Core: wrong shares amount"
        );

        require(
            _token.isApprovedForAll(_msgSender(), address(this)),
            "Wrapper ERC721: Token not approved"
        );
        require(
            _token.ownerOf(_tokenId) == _msgSender(),
            "Wrapper ERC721: Not token holder"
        );

        IFractionalizable(ICatharsisCore(catharsisCore).fractionalizable()).spendTokens(
            address(_token),
            _tokenId,
            0
        );

        _token.safeTransferFrom(_msgSender(), address(this), _tokenId);

        fTokenId = fraction.mint(_msgSender(), uint256(fraction.decimals()), _data);
    }

    // todo: issue fraction from different tokens
    function splitBatch(Token[] calldata _tokens)
        external
        returns (uint256[] memory fTokenId)
    {
        uint256 maxSharesPerToken = ICatharsisCore(catharsisCore).MAX_SHARES_PER_TOKEN();
        address fractionalizable = ICatharsisCore(catharsisCore).fractionalizable();

        uint256 fTokenDecimals = uint256(fraction.decimals());

        FractStructs.Token[] memory fractToken;

        uint256 tokensLen = _tokens.length;
        uint256 tokenIdsLen;
        uint256 i = 0;

        for (i; i < tokensLen; i++) {
            tokenIdsLen = _tokens[i].tokenIds.length;

            require(
                tokenIdsLen == _tokens[i].shares.length,
                "Wrapper ERC721: ids not equal to shares data"
            );
            require(
                _tokens[i].token.isApprovedForAll(_msgSender(), address(this)),
                "Wrapper ERC721: Token not approved"
            );

            for (uint256 ii = 0; ii < tokenIdsLen; ii++) {
                require(
                    _tokens[i].token.ownerOf(_tokens[i].tokenIds[ii]) == _msgSender(),
                    "Wrapper ERC721: Not token holder"
                );

                require(
                    _tokens[i].shares[ii] <= maxSharesPerToken &&
                    _tokens[i].shares[ii] > 0,
                    "Core: wrong shares amount"
                );

                fractToken[fractToken.length] = FractStructs.Token({
                    token: address(_tokens[i].token),
                    tokenId: _tokens[i].tokenIds[ii],
                    amount: 0
                });

                _tokens[i].token.safeTransferFrom(
                    _msgSender(),
                    address(this),
                    _tokens[i].tokenIds[ii]
                );

                fTokenId[fTokenId.length] = fraction.mint(_msgSender(), fTokenDecimals, _tokens[i].data);
            }
        }

        IFractionalizable(fractionalizable).spendTokensBatch(fractToken);
    }
}