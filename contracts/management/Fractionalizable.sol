// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SystemRoles.sol";

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from  "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/IFractionalizable.sol";
import "../libs/FractStructs.sol";

contract Fractionalizable is IFractionalizable, SystemRoles {
    using FractStructs for *;

    enum TokenProtocol {
        ERC721,
        ERC1155
    }

    struct Data {
        TokenProtocol protocol;
        address candidate;
        uint256 amount;
    }

    // account address -> token Id
    mapping (address => mapping (uint256 => Data)) public approved;

    function isApproved(address _token, uint256 _tokenId) public view returns (bool) {
        if (approved[_token][_tokenId].candidate != address(0)) {
            return true;
        }

        return false;
    }

    function approveCandidate(
        address _candidate,
        address _token,
        uint256 _tokenId,
        uint256 _amount,
        TokenProtocol _protocol
    ) public {
        require(
            hasRole(APPROVE_OPERATOR_ROLE, msg.sender),
            "Has no rights"
        );

        Data memory d = approved[_token][_tokenId];
        d.candidate = _candidate;
        if (_protocol == TokenProtocol.ERC721) {
            // if token not exist throw
            IERC721(_token).ownerOf(_tokenId);
            d.protocol = TokenProtocol.ERC721;
        } else {
            d.protocol = TokenProtocol.ERC1155;

            unchecked {
                d.amount += _amount;
            }
        }

        approved[_token][_tokenId] = d;
    }

    function disapproveCandidate(address _token, uint256 _tokenId) public {
        require(
            hasRole(APPROVE_OPERATOR_ROLE, msg.sender),
            "Has no rights"
        );

        Data storage d = approved[_token][_tokenId];
        d.candidate = address(0);
        d.amount = 0;
    }

    /**
     * @dev Check and spend allowance for fractionalization.
     */
    function spendTokens(address _token, uint256 _tokenId, uint256 _amount) external override(IFractionalizable) {
        require(
            hasRole(TOKEN_SPEND_OPERATOR_ROLE, msg.sender),
            "Has no rights"
        );

        require(isApproved(_token, _tokenId), "Only approved candidates");

        Data storage d = approved[_token][_tokenId];

        if (d.protocol == TokenProtocol.ERC721) {
            d.candidate = address(0);
        } else {
            require(d.amount >= _amount, "Only approved candidates");

            unchecked {
                d.amount -= _amount;
            }

            if (d.amount == 0) {
                d.candidate = address(0);
            }
        }
    }

    /**
     * @dev Check and spend allowance for fractionalization by batch.
     */
    function spendTokensBatch(FractStructs.Token[] memory _tokens) external override(IFractionalizable) {
        require(
            hasRole(TOKEN_SPEND_OPERATOR_ROLE, msg.sender),
            "Has no rights"
        );

        uint tokensLen = _tokens.length;
        uint i = 0;
        for (i; i < tokensLen; i++) {
            if (!isApproved(_tokens[i].token, _tokens[i].tokenId)) {
                require(false, "Only approved candidates");
            }
        }

        Data storage d;

        i = 0;
        for (i; i < tokensLen; i++) {
            d = approved[_tokens[i].token][_tokens[i].tokenId];

            if (d.protocol == TokenProtocol.ERC721) {
                d.candidate = address(0);
            } else {
                require(d.amount >= _tokens[i].amount, "Only approved candidates");

                unchecked {
                    d.amount -= _tokens[i].amount;
                }

                if (d.amount == 0) {
                    d.candidate = address(0);
                }
            }
        }
    }
}