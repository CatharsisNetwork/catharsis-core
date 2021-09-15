pragma solidity ^0.8.4;

import { IFractionalToken } from  "../interfaces/IFractionalToken.sol";
import { WrappedFractionalToken } from "./WrappedFractionalToken.sol";

contract ERC20Wrapper {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(WrappedFractionalToken).creationCode));

    mapping(address => mapping(uint256 => address)) public getWrappedToken;

    IFractionalToken public immutable fractionalToken;

    constructor(IFractionalToken _fractionalToken) {
        fractionalToken = _fractionalToken;
    }

    // @dev Issue Wrapped ERC20 token, pegged for our native fractional token and its id.
    function issue(
        uint256 _tokenId
    ) external returns (address wrappedToken) {
        require(
            getWrappedToken[_fractionalToken][_tokenId] == address(0),
            "Wrapped token already issued"
        );

        bytes memory bytecode = type(WrappedFractionalToken).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_fractionalToken, _tokenId));
        assembly {
            wrappedToken := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        getWrappedToken[_fractionalToken][_tokenId] = wrappedToken;
    }
}