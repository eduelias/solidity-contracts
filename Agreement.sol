pragma solidity ^0.4.4;
// 0x0965c80bc9385184e63af86a212c253a4a60c3a3  @thomson-reuters-ethereum-network
contract eAgreement {

    // Function modifier that grants that the sender is the owner
    modifier isOwner {
        if (msg.sender == owner) _;
    }

    // Function modifier that grants that the sender is a subscriber
    modifier isSubscriber {
        for (uint i = 0; i < requiredSubscribers.length; i++) {
            if (msg.sender == requiredSubscribers[i]) _;
        }
    }

    // Store the owner address
    address private owner;
    // DateTime when this contract was created
    uint64 private creationTime;
    // Agreement content
    bytes private agreementText;
                
    // List of default subscribers to this contract
    address[] requiredSubscribers;    
    // List of signed subscribers
    address[] signedSubscribers;      

    // Constructor
    function eAgreement(bytes blob) {
        owner = msg.sender;
        creationTime = uint64(now);
        agreementText = blob;                
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
    function Sign() returns (string) {
        int subsid = findRequiredSubscriberIndex(msg.sender);
        if (subsid == -1) return "the provided member is not a subscriber";

        uint usubix = uint(subsid);        
        
        int sigix = findSignedSubscriberIndex(msg.sender);
        if (sigix != -1) return "the member already signed this agreement";                

        signedSubscribers.push(msg.sender);        
        return "signature collected with success";
    }
}