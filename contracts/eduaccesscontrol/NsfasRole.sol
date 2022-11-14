// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Import the library 'Roles'
import "../eduaccesscontrol/Roles.sol";

// Define a contract 'StudentRole' to manage this role - add, remove, check
contract NsfasRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event NsfasAdded(address indexed account);
    event NsfasRemoved(address indexed account);

    // Define a struct 'students' by inheriting from 'Roles' library, struct Role
    Roles.Role private nsfas;

    // In the constructor make the address that deploys this contract the 1st student
    constructor() {
        _addNsfas(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyNsfas() {
        require(isNsfas(msg.sender), "You don't have the Nsfas access");
        _;
    }

    // Define a function 'isNsfas' to check this role
    function isNsfas(address account) public view returns (bool) {
        return nsfas.has(account);
    }

    // Define a function 'addNsfas' that adds this role
    function addNsfas(address account) public onlyNsfas {
        _addNsfas(account);
    }

    // Define a function 'renounceNsfas' to renounce this role
    function renounceNsfas() public {
        _removeNsfas(msg.sender);
    }

    // Define an internal function '_addNsfas' to add this role, called by 'addNsfas'
    function _addNsfas(address account) internal {
        nsfas.add(account);
        emit NsfasAdded(account);
    }

    // Define an internal function '_removeNsfas' to remove this role, called by 'removeNsfas'
    function _removeNsfas(address account) internal {
        nsfas.remove(account);
        emit NsfasRemoved(account);
    }
}