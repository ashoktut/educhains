// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Import the library 'Roles'
import "../eduaccesscontrol/Roles.sol";

// Define a contract 'StudentRole' to manage this role - add, remove, check
contract UniversityRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event UniversityAdded(address indexed account);
    event UniversityRemoved(address indexed account);

    // Define a struct 'students' by inheriting from 'Roles' library, struct Role
    Roles.Role private universities;

    // In the constructor make the address that deploys this contract the 1st student
    constructor() {
        _addUniversity(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyUniversity() {
        require(isUniversity(msg.sender), "You don't have the University access");
        _;
    }

    // Define a function 'isUniversity' to check this role
    function isUniversity(address account) public view returns (bool) {
        return universities.has(account);
    }

    // Define a function 'addUniversity' that adds this role
    function addUniversity(address account) public onlyUniversity {
        _addUniversity(account);
    }

    // Define a function 'renounceUniversity' to renounce this role
    function renounceUniversity() public {
        _removeUniversity(msg.sender);
    }

    // Define an internal function '_addUniversity' to add this role, called by 'addUniversity'
    function _addUniversity(address account) internal {
        universities.add(account);
        emit UniversityAdded(account);
    }

    // Define an internal function '_removeUniversity' to remove this role, called by 'removeUniversity'
    function _removeUniversity(address account) internal {
        universities.remove(account);
        emit UniversityRemoved(account);
    }
}