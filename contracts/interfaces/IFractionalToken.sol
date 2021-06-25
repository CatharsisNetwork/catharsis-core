pragma solidity ^0.8.4;

import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IFractionalToken is IERC1155  {
    function decimals() external view returns (uint8);

    function mint(
        address to,
        uint256 amount,
        bytes calldata data
    ) external returns (uint256 id);

    function mintBatch(
        address to,
        uint256[] memory amounts,
        bytes calldata data
    ) external returns (uint256[] memory ids);

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external;
}