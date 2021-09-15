pragma solidity ^0.8.4;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1155, IERC1155, IERC1155MetadataURI } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { IFractionalToken } from "../interfaces/IFractionalToken.sol";

// Minting amount: ERC20 == ERC1155 * 10^18
contract WrappedFractionalToken is ERC20("Catharsis ERC20 Wrapped Token", "CATH20") {
    address public fToken;
    uint256 public tokenId;

    function initialize(IFractionalToken _erc1155, uint256 _tokenId) external {
        require(fToken == address(0), "already initialized");

        fToken = address(_erc1155);
        tokenId = _tokenId;
    }

    function uri() public view returns (string memory) {
        return IERC1155MetadataURI(fToken).uri(tokenId);
    }

    // @dev Wrap ERC1155 to ERC20 token
    // Need {FractionalToken.setApprovalForAll} call before.
    function wrap(
        uint256 _amount,
        address _recipient
    ) external {
        IERC1155(fToken).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");
        _mint(_recipient, _amount);
    }

    // @dev Wrap ERC1155 from ERC20 token
    function unwrap(
        uint256 _amount,
        address _recipient
    ) external {
        _burn(msg.sender, _amount);
        IERC1155(fToken).safeTransferFrom(address(this), _recipient, _tokenId, _amount, "");
    }
}