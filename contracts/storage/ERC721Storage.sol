pragma solidity ^0.8.4;

import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract ERC721Storage is ERC721Holder {

    struct Details {
        uint256[] collection;
        uint256 lockedAt;
        uint256 unlockedAt;
    }

    // user address -> token address
    mapping (address => mapping (address => Details[])) public details;
}