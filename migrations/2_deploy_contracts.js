// migrating the appropriate contracts
var StudentRole = artifacts.require("../contracts/eduaccesscontrol/StudentRole.sol");
var UniversityRole = artifacts.require("../contracts/eduaccesscontrol/UniversityRole.sol");
var AccommodationRole = artifacts.require("../contracts/eduaccesscontrol/AccommodationRole.sol");
var NsfasRole = artifacts.require("../contracts/eduaccesscontrol/NsfasRole.sol");
var EduChain = artifacts.require("../contracts/edubase/EduChain.sol");

module.exports = function(deployer) {
  deployer.deploy(EduChain);
};