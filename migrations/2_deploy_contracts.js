// migrating the appropriate contracts

// EduChain.sol is the super class and all the other contract files inherit from this file, thus only EduChain is deployed
var EduChain = artifacts.require("../contracts/edubase/EduChain.sol");

module.exports = function(deployer) {
  deployer.deploy(EduChain);
};