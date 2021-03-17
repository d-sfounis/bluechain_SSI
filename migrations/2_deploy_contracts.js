var PassportManager = artifacts.require("PassportManager");

module.exports = function(deployer) {
    deployer.deploy(PassportManager)
    //deployer.deploy(PassportManager, {overwrite:false})
    // Console log the address:
    .then(() => console.log("PassportManager contract deployed at address: " + PassportManager.address));
};
