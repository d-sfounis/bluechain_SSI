// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/PassportManager.sol";

contract TestPassportManager {
    // The address of the adoption contract to be tested
    PassportManager PM_instance = PassportManager(DeployedAddresses.PassportManager());

    // The id of the pet that will be used for testing
    string doc_hash = "21f3a9de43f07d855f49b946a10c30df432e8af95311435f77daf894216dcd41"; //This is a simple sha256 sum, ran in a linux terminal
    string doc_filename = "driverslicense.pdf";
    bytes32 doc_hash_solidityhash = 0x61462029f64c97e46ee5c64c5aa5c0f4dab299e7ba4c50371e320d57213dcbf5;

    //TODO: Fix everything below here
    //The expected owner of adopted pet is this contract
    address current_addr = address(this);
 
    // Testing the adopt() function
    function test_doc_storage() public {
      bytes32 returned_doc_hash = PM_instance.store_doc(doc_hash_solidityhash);

      Assert.equal(returned_doc_hash, doc_hash_solidityhash, "Document hashes (of type: bytes32) should match!");
    }
    
    /* 
    // Testing retrieval of a single pet's owner
    function testGetAdopterAddressByPetId() public {
      address adopter = adoption.adopters(expectedPetId);

      Assert.equal(adopter, expectedAdopter, "Owner of the expected pet should be this contract");
    }
    
    // Testing retrieval of all pet owners
    function testGetAdopterAddressByPetIdInArray() public {
      // Store adopters in memory rather than contract's storage
      address[16] memory adopters = adoption.getAdopters();

      Assert.equal(adopters[expectedPetId], expectedAdopter, "Owner of the expected pet should be this contract");
    }
    */

}
