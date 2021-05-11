const PassportManager = artifacts.require("PassportManager");

contract("PassportManager testsuite Alpha", accounts => {
    it("should initialize a new passport linked with the current user's address", () => {
        let this_address = accounts[0];
        let this_nickname = "John Doe";
        let meta;
        
    return PassportManager.deployed()
        .then(instance => {
            meta = instance;
            console.log("Test1 on PassportManager address: " + meta.address);
            return meta.initPassport.call(this_nickname);
        })
        .then(returned_tuple => {
            //console.log(returned_tuple[0]);
            //console.log(returned_tuple[1]);
            assert.equal(returned_tuple[0], this_nickname, "Nickname, passed and returned by PassportManager.initPassport(), should match!");
            assert.equal(returned_tuple[1], this_address, "Controller address, passed and returned by PassportManager.initPassport(), should match!");
            //If we're here, it means the previous call() has succeeded. Now,
            //let's take things up a notch and let's actually send a transaction that changes the state of the blockchain.
            //Remember: We can't check for return values with a transaction, we have to debug the tx id manually.
            //#NOTE: We passed an extra parameter here. For more info on this special parameter object, check out:
            //https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts#making-a-transaction
            const result = meta.initPassport.sendTransaction(this_nickname, {from: accounts[0]});
            result.on('transactionHash', (hash) => {
                console.log('TxHash', hash);
            });
            return result;
        })
        .then(result => {
            //#NOTE: This is a hacky solution at ensuring Ganache has had time to process the tx.
            console.log("Test 1 should've succeeded!");
        });
    });
    
    it("should successfully initialize a 2nd passport linked with accounts[1].", () => {
        let this_address = accounts[1];
        let this_nickname = "Theocharis Iordanidis";
        let meta;
    
    return PassportManager.deployed()
        .then(instance => {
            meta = instance;
            console.log("Test2 on PassportManager address: " + meta.address);
            return meta.initPassport.call(this_nickname, {from: accounts[1]});
        })
        .then(returned_tuple => {
            //console.log(returned_tuple[0]);
            //console.log(returned_tuple[1]);
            assert.equal(returned_tuple[0], this_nickname, "Nickname, passed and returned by PassportManager.initPassport(), should match!");
            assert.equal(returned_tuple[1], this_address, "Controller address, passed and returned by PassportManager.initPassport(), should match!");
            //If we're here, it means the previous call() has succeeded. Now,
            //let's take things up a notch and let's actually send a transaction that changes the state of the blockchain.
            //Remember: We can't check for return values with a transaction, we have to debug the tx id manually.
            //#NOTE: We passed an extra parameter here. For more info on this special parameter object, check out:
            //https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts#making-a-transaction
            const result = meta.initPassport.sendTransaction(this_nickname, {from: accounts[1]});
            result.on('transactionHash', (hash) => {
                console.log('TxHash', hash);
            });
            return result;
        })
        .then(result => {
            //#NOTE: This is a hacky solution at ensuring Ganache has had time to process the tx.
            console.log("Test 2 should've succeeded!");
        });
    });
    
    it("should add an identity file sha256 hash to a controlled passport", () => {
        let this_address = accounts[0];
        let doc_hash = "0x21f3a9de43f07d855f49b946a10c30df432e8af95311435f77daf894216dcd41";
        let meta;
        
    return PassportManager.deployed()
        .then(instance => {
            meta = instance;
            console.log("Test3 on PassportManager address: " + meta.address);
            return meta.addIDFileToPassport.call(this_address, doc_hash);
        })
        .then(returned_tuple => {
            assert.equal(returned_tuple[0], this_address, "Passport controller, passed and returned by PassportManager.addIDFileToPassport(), should match!");
            assert.equal(returned_tuple[1], doc_hash, "Document hash (bytes32), passed and returned by PassportManager.addIDFileToPassport(), should match!");
            assert.equal(returned_tuple[2], 1, "Trust score of newly added doc_hash should be 1!");
            console.log(returned_tuple);
            //Now let's actually pass a concrete, actuallly persistent transaction instead of a call.
            const result = meta.addIDFileToPassport.sendTransaction(this_address, doc_hash, {from: accounts[0]});
            result.on('transactionHash', (hash) => {
                console.log('TxHash', hash);
            });
            console.log("what the hell");
            return result;
        })
        .then(result => {
            //#NOTE: This is a hacky solution at ensuring Ganache has had time to process the tx.
            console.log("Test 3 should've succeeded!");
        });
    });
    
    it("should add +1 to the trust score of a doc in a passport", () => {
        let this_address = accounts[1];
        let passport_address = accounts[0];
        let doc_hash = "0x21f3a9de43f07d855f49b946a10c30df432e8af95311435f77daf894216dcd41";
        let meta;
        
    return PassportManager.deployed()
        .then(instance => {
            meta = instance;
            console.log("Test4 on PassportManager address: " + meta.address);
            return meta.voteForDocInPassport.call(passport_address, doc_hash, {from: this_address});
        })
        .then(returned_tuple => {
            assert.equal(returned_tuple[0], passport_address, "Passport ID address, passed and returned by PassportManager.voteForDocInPassport(), should match!");
            assert.equal(returned_tuple[1], doc_hash, "Document hash (bytes32), passed and returned by PassportManager.voteForDocInPassport(), should match!");
            assert.equal(returned_tuple[2], 2, "Trust score of doc_id should have been raised to 2!");
            console.log(returned_tuple);
            //Now let's actually pass a concrete, actuallly persistent transaction instead of a call.
            const result = meta.voteForDocInPassport.sendTransaction(passport_address, doc_hash, {from: this_address});
            result.on('transactionHash', (hash) => {
                console.log('TxHash', hash);
            });
            console.log("what the hell2");
            return result;
        })
        .then(result => {
            //#NOTE: This is a hacky solution at ensuring Ganache has had time to process the tx.
            console.log("Test 4 should've succeeded!");
        });
    });
    
  
  /*it("return false", () => {
    assert(0==1);
  });
  */
  
});
