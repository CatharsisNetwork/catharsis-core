pragma solidity ^0.8.4;

import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { IFractionalToken } from "../interfaces/IFractionalToken.sol";

contract FractionalToken is IFractionalToken, ERC1155, Ownable {
    Counters.Counter private _tokenIdTracker;

    string public name = "Catarsis Network | Fractional Token";
    uint8 public override decimals = 18;

    constructor(string memory uri) ERC1155(uri) {
        //
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     */
    function mint(
        address to,
        uint256 amount,
        bytes memory data
    )
        external
        override
        onlyOwner
        returns (uint256 id)
    {
        Counters.increment(_tokenIdTracker);
        id = Counters.current(_tokenIdTracker);
        _mint(to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory amounts,
        bytes memory data
    )
        external
        override
        onlyOwner
        returns (uint256[] memory ids)
    {
        uint i = 0;
        uint l = amounts.length;
        ids = new uint256[](l);
        for (i; i < l; i++) {
            Counters.increment(_tokenIdTracker);
            ids[i] = Counters.current(_tokenIdTracker);
        }
        _mintBatch(to, ids, amounts, data);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    )
        external
        override
        onlyOwner
    {
        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    )
        external
        override
        onlyOwner
    {
        _burnBatch(account, ids, values);
    }
}