/* SPDX-License-Identifier: GPL-3.0-or-later
 * Author: Dimitrios Sfounis, for Bluechain Social Cooperative Enterprise, Athens (GR), February 2021
 * Website: https://bluechain.tech
 * Project: European Self-Sovereign Identity on blockchain, intended for electronic Health records,
 *      Funded under the European Cohesion Fund's "Vouchers for Innovation" programme.
 */
pragma solidity >=0.8.0 <0.9;

contract PassportManager {
    /* Basic implementation of a user's identity: a Passport! */
    struct Passport {
        string flair_name; //User nickname. It's optional.
        //The controller (owner) of this passport instance.
        //Initially, it's the first user/deployer. This can change later on.
        address controller;
        //the main workhorse of this struct. This is a hashmap of
        //key-value pairs of keccak256 hashes of the (string)sha256 checksum of any identity file (say, a PDF certificate)
        //and a trust-score stored as a simple integer. The more people have voted to trust this particular document of your passport,
        //the higher the score is. Simple, right? Probably not...
        //bytes32 because keccak256, through the web3.eth lib, always produces 32 bytes (256 bits) of output.
        mapping(bytes32 => uint) identity_files;
        //Lookup table for the previous mapping, just so we don't ever have to deal with orphaned values.
        //#NOTE: If you self-destruct this contract, be sure to iterate over `identity_files` and delete all keys using this Lookup Table.
        mapping(bytes32 => bytes32) identity_files_LUT;
        //Also this helps for easy, O(1) search of whether an address is here or not: //#NOTE: DEPRECATED in v0.2.0
        //mapping(bytes32 => bool) identity_files_LUT_Bool;
        //Delegates of this passport and its contained identity files, able to control it too.
        //Disabling this for now, we'll see if we can circumvent delegation functionality as defined in the CALYSPSO paper by Kokkoris-Kogias.
        //address[] delegates;
    }
    
    //The main database of our user IDs. This hashtable stores key-value pairs of
    //address to (struct Passport) objects belonging to this smart contract's users.
    //bytes32 because keccak256, through the web3 library, always produces 32 bytes (256 bits) of output.
    //the public attribute just gives it an automatic getter. However, the getter only returns a tuple containing all atomic fields,
    //and not the actual data structure.
    mapping(address => Passport) public user_passports;
    //And the associated lookup table, for quick O(1) lookup:
    mapping(address => address) public user_passports_LUT;
    
    /* Debugging Events! Respect these, they'll save you headache(s) */
    event PassportInitialized(address passport_id, address by);
    event AddedIDFileToPassport(address passport_id, bytes32 hashed_file);
    event Voted(address passport_id, address voter);
    
    /* Helper function to check if a user has initialized/created a Passport before */
    function hasInitializedPassport(address addr) private view returns (bool) {
        //All these checks cumulatively mean that a passport has been properly initialized
        if(user_passports_LUT[addr] != address(0)){
            Passport storage p = user_passports[addr];
            
            if(p.controller != address(0)){
                return true;
            }
        }
        return false;
    }

    function initPassport(string memory nickname) public returns (string memory, address) {
        require(!(hasInitializedPassport(msg.sender)), "Your User Passport is already initialized!");
        //As taken by the Solidity docs:
        //We cannot use "Passport[campaignID] = Passport(beneficiary, goal, 0, 0)"
        //because the RHS creates a memory-struct "Passport" that contains a mapping.
        Passport storage p = user_passports[msg.sender];
        
        p.flair_name = nickname;
        p.controller = msg.sender;
        //Mark passport as initialized, and emit the event.
        user_passports_LUT[msg.sender] = msg.sender;
        
        emit PassportInitialized(user_passports_LUT[msg.sender], msg.sender);
        return (p.flair_name, p.controller);
    }
    
    function addIDFileToPassport(address passport_id, bytes32 id_file) public returns (address, bytes32, uint) {
        Passport storage p = user_passports[passport_id];
        require(hasInitializedPassport(passport_id));
        require(p.controller == msg.sender, "Sender/controller mismatch when accessing passport");
        require(p.identity_files_LUT[id_file] == "", "ID File is already contained in this Passport!");
        
        p.identity_files_LUT[id_file] = id_file;
        //trust-score == 1 means we've self-added this file and only us do trust it. In other words, this is a new, self-trusted-only doc.
        //#TODO: There's probably a better way to do this other than using magic numbers...
        p.identity_files[id_file] = 1;
        //Return all these for debugging and testing purposes. It's a tuple of (controller_address, identity_file_byte32hash, trust_score).
        emit AddedIDFileToPassport(passport_id, id_file);
        return (p.controller, p.identity_files_LUT[id_file], p.identity_files[id_file]);
    }
    
    //This function raises the trust score of a Passport, when a user vouches for it.
    //Only users with already initiated Passports, and therefore active members of the community, can vouch for other people's Passports.
    function voteForDocInPassport(address passport_id, bytes32 doc_id) public returns (address, bytes32, uint) {
        require(PassportExists(passport_id), "Passport_id does not exist!");
        require(passport_id != msg.sender, "You can't vote on the trust score of your own Passport's documents!");
        Passport storage p = user_passports[passport_id];
        require(DocExistsInPassport(p, doc_id), "Document doesn't exist in specified Passport!");
        require(hasInitializedPassport(msg.sender), "You have to have an active Passport yourself to vote on others!");
        //Everything ok, we found it. Raitse its score by 1.
        p.identity_files[doc_id] = p.identity_files[doc_id] + 1;
        return (passport_id, doc_id, p.identity_files[doc_id]);
    }
    
    function PassportExists(address passport_id) private view returns (bool) {
        if(user_passports_LUT[passport_id] == address(0)){
            return false;
        }
        return true;
    }
    
    function DocExistsInPassport(Passport storage P, bytes32 doc_id) private view returns (bool) {
        if(P.identity_files_LUT[doc_id] == bytes32(0)){
            return false;
        }
        return true;
    }
    
    /* TODO 1: We need a voting function, to play with trust_scores of stored Passport documents */
    /* DONE! */
    /* TODO 2: We need a function to export DID documents and Verifiable Claims as per specification format. Possibly a view function, so it doesn't burn up gas */
    /* TODO 3: We need some failsafe against Orphaned Passports... */
    /* TODO 4: Currently, trust_scores of documents are handled like magic numbers. This is generally an anti-pattern, let's look into a better way of doing this. */ 
    /* TODO 5: The contract should maintain a list of Arbitrator addresses, for example Gnomon's address. Votes to documents from those addresses should give +100 score instead of just +1 */
        /* This is as per the CALYPSO paper where the Trust Committee is maintained as a separate group, and votes from them are stronger */
}
