pragma solidity ^0.4.16;

contract SmartAgreement {
    
    // Store the owner address
    address private owner;
    
    event SendMessage(string message);
    
    // Function modifier that grants that the sender is the owner
    modifier isOwner {
        if (msg.sender == owner) 
            _;
        else 
            SendMessage("Not owner.");
    }

    // Function modifier that grants that the sender is a subscriber
    modifier isSubscriber {
        if (findRequiredSubscriberIndex(msg.sender) == -1)
            SendMessage("Not a subscriber.");
        else 
            _;
    }
    
    // people that not signed yet
    modifier notSignedYet {
        int sigix = findSignedSubscriberIndex(msg.sender);
        if (sigix != -1) 
            SendMessage("Already signed");
        else 
            _;
    }
    
    // Agreement content
    bytes private agreementText;
                
    // List of default subscribers to this contract
    address[] requiredSubscribers;    
    // List of signed subscribers
    address[] signedSubscribers;      

    // Constructor
    function eAgreement(bytes blob, address[] parts) {
        owner = msg.sender;
        agreementText = blob;
        for (uint i = 0; i < parts.length; i++) {
            requiredSubscribers.push(parts[i]);
        }
        SendMessage("Created");
    }    
       
    // Set a new owner to this contract
    function setOwner(address newOwner) isOwner {
        owner = newOwner;
    }

    // Adds a subscriber to the default subscribers list
    function addSubscriber(address member) isOwner {        
        int ix = findRequiredSubscriberIndex(member);  
        if (ix == -1) {
            requiredSubscribers.push(member);      
            SendMessage("Subscriber added");
        } else {
            SendMessage("Already a subscriber");
        }
    }

    function getRequiredSubscribers() constant returns (address[]) {
        return requiredSubscribers;
    }

    function getSignedSubscribers() constant returns (address[]) {         
        return signedSubscribers;
    }

    // Finds a required subscriber index by its address
    function findRequiredSubscriberIndex(address member) private returns(int) {
        for (uint i = 0; i < requiredSubscribers.length; i++) {
                if (member == requiredSubscribers[i]) {
                    return int(i);
            }
        }
        return -1;
    }

    // Finds a required subscriber index by its address
    function findSignedSubscriberIndex(address member) private returns(int) {
        for (uint i = 0; i < signedSubscribers.length; i++) {
                if (member == signedSubscribers[i]) {
                    return int(i);
            }
        }
        return -1;
    }

    // Removes a subscriber from the default subscriber list
    function removeSubscriber(address member) isOwner {
        // only allow removing of required subscribers if no one signed
        if (signedSubscribers.length == 0) {
            int i = findRequiredSubscriberIndex(member);
            if (i != -1) 
                delete requiredSubscribers[uint(i)];
        }
    }

    // reads the content of the contract
    function readContent() isSubscriber constant returns (bytes) {
        return agreementText;
    }

    // This function will be called from an external contract just to sign
    function sign() isSubscriber notSignedYet {
        signedSubscribers.push(msg.sender);        
        SendMessage("Signed");
    }
}