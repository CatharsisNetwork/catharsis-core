pragma solidity ^0.8.4;

interface ICatharsisCore {
    function MAX_SHARES_PER_TOKEN() external view returns(uint256);

    function fractionalizable() external view returns (address);
}