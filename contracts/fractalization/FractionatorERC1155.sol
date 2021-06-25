pragma solidity ^0.8.4;

import { IERC1155 } from  "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { IFractionalToken } from "../interfaces/IFractionalToken.sol";
import { ICatharsisCore } from "../interfaces/ICatharsisCore.sol";

contract FractionatorERC1155 is Context {

    struct Token {
        IERC1155 token;
        uint256 tokenId;
        uint256 amount;
        uint256 shares;
        bytes data;
    }

    IFractionalToken public fraction;

    address public catharsisCore;

    constructor(IFractionalToken _fractionToken) {
        catharsisCore = _msgSender();
        fraction = _fractionToken;
    }

    function split(
        IERC1155 _token,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _shares,
        bytes memory _data
    )
        external
        returns (uint256 fTokenId)
    {
        require(
            _shares <= ICatharsisCore(catharsisCore).MAX_SHARES_PER_TOKEN() && _shares > 0,
            "Core: wrong shares amount"
        );
        require(
            _token.isApprovedForAll(_msgSender(), address(this)),
            "Wrapper ERC1155: Token not approved"
        );
        require(
            _token.balanceOf(_msgSender(), _tokenId) >= _amount,
            "Wrapper ERC1155: Not token holder"
        );

        _token.safeTransferFrom(_msgSender(), address(this), _tokenId, _amount, _data);

        fTokenId = fraction.mint(_msgSender(), uint256(fraction.decimals()), _data);
    }

    function splitBatch(
        Token[] calldata _tokens
    )
        external
        returns (uint256[] memory fTokenId)
    {
        uint256 maxSharesPerToken = ICatharsisCore(catharsisCore).MAX_SHARES_PER_TOKEN();
        uint256 fTokenDecimals = uint256(fraction.decimals());

        uint256 tokensLen = _tokens.length;
        uint256 i = 0;
        for (i; i < tokensLen; i++) {
            require(
                _tokens[i].shares <= maxSharesPerToken &&
                _tokens[i].shares > 0,
                "Core: wrong shares amount"
            );
            require(
                _tokens[i].token.isApprovedForAll(_msgSender(), address(this)),
                "Wrapper ERC1155: Token not approved"
            );
            require(
                _tokens[i].token.balanceOf(_msgSender(), _tokens[i].tokenId) >= _tokens[i].amount,
                "Wrapper ERC1155: Not token holder"
            );
        }

        fTokenId = new uint256[](tokensLen);
        i = 0;
        for (i; i < tokensLen; i++) {
            _tokens[i].token.safeTransferFrom(
                _msgSender(),
                address(this),
                _tokens[i].tokenId,
                _tokens[i].amount,
                _tokens[i].data
            );

            fTokenId[i] = fraction.mint(_msgSender(), fTokenDecimals, _tokens[i].data);
        }
    }
}