// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Import the library 'Roles'
import "../eduaccesscontrol/Roles.sol";

// Define a contract 'UniversityRole' to manage this role - add, remove, check
contract AccommodationRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event AccommodationAdded(address indexed account);
    event AccommodationRemoved(address indexed account);

    // Define a struct 'accommodations' by inheriting from 'Roles' library, struct Role
    Roles.Role private accommodations;

    // In the constructor make the address that deploys this contract the 1st student
    constructor() {
        _addAccommodation(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyAccommodation() {
        require(isAccommodation(msg.sender), "You don't have the Accommodation access");
        _;
    }

    // Define a function 'isAccommodation' to check this role
    function isAccommodation(address account) public view returns (bool) {
        return accommodations.has(account);
    }

    // Define a function 'addAccommodation' that adds this role
    function addAccommodation(address account) public onlyAccommodation {
        _addAccommodation(account);
    }

    // Define a function 'renounceAccommodation' to renounce this role
    function renounceAccommodation() public {
        _removeAccommodation(msg.sender);
    }

    // Define an internal function '_addAccommodation' to add this role, called by 'addAccommodation'
    function _addAccommodation(address account) internal {
        accommodations.add(account);
        emit AccommodationAdded(account);
    }

    // Define an internal function '_removeAccommodation' to remove this role, called by 'removeAccommodation'
    function _removeAccommodation(address account) internal {
        accommodations.remove(account);
        emit AccommodationRemoved(account);
    }
}