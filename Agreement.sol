pragma solidity ^0.4.4;
// 0xb6b270ac52b0f0e8341ccc4f96bc42619bf67581 @thomson-reuters-ethereum-network
contract eAgreement {
    
    // Store the owner address
    address private owner;
    
    event SendMessage(string);
    
    event Create(address[]);

    // Function modifier that grants that the sender is the owner
    modifier isOwner {
        if (msg.sender == owner) _;
        else SendMessage("Not owner.");
    }

    // Function modifier that grants that the sender is a subscriber
    modifier isSubscriber {
        if (findRequiredSubscriberIndex(msg.sender) == -1)
            SendMessage("Not a subscriber.");
        else _;
    }
    
    // people that not signed yet
    modifier NotSignedYet {
        int sigix = findSignedSubscriberIndex(msg.sender);
        if (sigix != -1) SendMessage("Already signed");
        else _;
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
            int minx = findSignedSubscriberIndex(members[i]);
            if (minx == -1) {
                requiredSubscribers.push(members[i]);      
                SendMessage("Subscriber added");
            }
            else 
                SendMessage("Already signed.");
        }  
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
        if (signedSubscribers.length == 0) {
            int i = findRequiredSubscriberIndex(member);
            if (i != -1) delete requiredSubscribers[uint(i)];
        }
    }

    // reads the content of the contract
    function ReadContent() isSubscriber constant returns (bytes) {
        return agreementText;
    }

    // This function will be called from an external contract just to sign
    function Sign() isSubscriber NotSignedYet {
        signedSubscribers.push(msg.sender);        
        SendMessage("Signed");
    }
}