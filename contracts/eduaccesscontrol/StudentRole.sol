// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Import the library 'Roles'
import "../eduaccesscontrol/Roles.sol";

// Define a contract 'StudentRole' to manage this role - add, remove, check
contract StudentRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event StudentAdded(address indexed account);
    event StudentRemoved(address indexed account);

    // Define a struct 'students' by inheriting from 'Roles' library, struct Role
    Roles.Role private students;

    // In the constructor make the address that deploys this contract the 1st student
    constructor() {
        _addStudent(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyStudent() {
        require(isStudent(msg.sender), "You don't have the student access");
        _;
    }

    // Define a function 'isStudent' to check this role
    function isStudent(address account) public view returns (bool) {
        return students.has(account);
    }

    // Define a function 'addStudent' that adds this role
    function addStudent(address account) public onlyStudent {
        _addStudent(account);
    }

    // Define a function 'renounceStudent' to renounce this role
    function renounceStudent() public {
        _removeStudent(msg.sender);
    }

    // Define an internal function '_addStudent' to add this role, called by 'addStudent'
    function _addStudent(address account) internal {
        students.add(account);
        emit StudentAdded(account);
    }

    // Define an internal function '_removeStudent' to remove this role, called by 'removeStudent'
    function _removeStudent(address account) internal {
        students.remove(account);
        emit StudentRemoved(account);
    }
}