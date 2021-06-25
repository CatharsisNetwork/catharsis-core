pragma solidity ^0.8.4;

import "../libs/FractStructs.sol";

interface IFractionalizable {
    function spendTokens(address _token, uint256 _tokenId, uint256 _amount) external;

    function spendTokensBatch(FractStructs.Token[] memory _tokens) external;
}