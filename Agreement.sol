pragma solidity ^0.4.4;
// 0x2aee116e2766e9f1256353eb6d719e46cb10a8c4  @thomson-reuters-ethereum-network
contract eAgreement {
    
    event SendMessage(string);
    
    event Create(address[]);

    // Function modifier that grants that the sender is the owner
    modifier isOwner {
        if (msg.sender == owner) _;
        else SendMessage("Not owner.");
    }

    // Function modifier that grants that the sender is a subscriber
    modifier isSubscriber {
        if (msg.sender != owner && findRequiredSubscriberIndex(msg.sender) == -1)
            SendMessage("Not a subscriber.");
        else _;
    }

    // Store the owner address
    address private owner;
    
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
        requiredSubscribers = parts;
        Create(parts);
    }    
       
    // Set a new owner to this contract
    function SetOwner(address newOwner) isOwner {
        owner = newOwner;
    }

    // Adds a subscriber to the default subscribers list
    function AddSubscriber(address member) isOwner {        
        requiredSubscribers.push(member);        
    }

    function AddSubscribers(address[] members) isOwner {        
        for (uint i = 0; i < members.length; i++) {
            requiredSubscribers.push(members[i]);      
        }  
        SendMessage("Subscriber added");
    }

    function GetRequiredSubscribers() constant returns (address[]) {
        return requiredSubscribers;
    }

    function GetSignedSubscribers() constant returns (address[]) {         
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
    function RemoveSubscriber(address member) isOwner {
        // only allow removing of required subscribers if no one signed
        if (signedSubscribers.length > 0) return; 

        int i = findRequiredSubscriberIndex(member);
        if (i != -1) delete requiredSubscribers[uint(i)];    
    }

    // reads the content of the contract
    function ReadContent() constant returns (bytes) {
        return agreementText;
    }

    // This function will be called from an external contract just to sign
    function Sign() isSubscriber {
        int sigix = findSignedSubscriberIndex(msg.sender);
        if (sigix != -1) { 
            SendMessage("Already signed"); // not signed
        } else  {                
            signedSubscribers.push(msg.sender);        
            SendMessage("Signed");
        }
    }
}