pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract SystemRoles is Context, AccessControlEnumerable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant APPROVE_OPERATOR_ROLE = keccak256("APPROVE_OPERATOR_ROLE");
    bytes32 public constant TOKEN_SPEND_OPERATOR_ROLE = keccak256("TOKEN_SPEND_OPERATOR_ROLE");

    constructor() {
        super.grantRole(ADMIN_ROLE, _msgSender());
    }

    function grantRole(bytes32 role, address account)
        public
        override(AccessControlEnumerable)
        onlyRole(ADMIN_ROLE)
    {
        super.grantRole(role, account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account)
        public
        override(AccessControlEnumerable)
        onlyRole(ADMIN_ROLE)
    {
        super.revokeRole(role, account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account)
        public
        override(AccessControlEnumerable)
    {
        super.renounceRole(role, account);
    }
}