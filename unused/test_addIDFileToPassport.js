const PassportManager = artifacts.require("PassportManager");

contract("PassportManager", accounts => {
    
    it("should add an identity file sha256 hash to a controlled passport", () => {
        let this_address = accounts[0];
        let doc_hash = "0x21f3a9de43f07d855f49b946a10c30df432e8af95311435f77daf894216dcd41";
        let meta;
        
    return PassportManager.deployed()
        .then(instance => {
            meta = instance;
            console.log("Test3 on PassportManager address: " + meta.address);
            //console.log(this_address);
            //console.log(doc_hash);
            //console.log(meta);
            return meta.addIDFileToPassport.call(this_address, doc_hash);
        })
        .then(returned_tuple => {
            assert.equal(returned_tuple[0], this_address, "Passport controller, passed and returned by PassportManager.addIDFileToPassport(), should match!");
            assert.equal(returned_tuple[1], doc_hash, "Document hash (bytes32), passed and returned by PassportManager.addIDFileToPassport(), should match!");
            assert.equal(returned_tuple[2], 1, "Trust score of newly added doc_hash should be 1!");
            console.log(returned_tuple);
            //Now let's actually pass a concrete, actuallly persistent transaction instead of a call.
            const result = meta.addIDFileToPassport.sendTransaction(this_address, doc_hash, {from: accounts[0]});
            console.log("Test2 transaction submitted with tx id: " + result.tx);
        });
    });
    
  
});
