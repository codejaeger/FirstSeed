pragma solidity ^0.8.13;

contract SeedChain {
    bool public adminSet = false;
    uint32 public product_id = 0;   // Product ID
    uint32 public participant_id = 0;   // Participant ID
    uint32 public owner_id = 0;   // Ownership ID
    uint32 public quality_id = 0; // Quality ID

    struct product {
        string seedName;
        string seedType;
        string serialNumber;
        address productOwner;
        uint32 cost;
        uint32 supplyTimeStamp;
    }

    mapping(uint32 => product) public products;
    mapping(string => uint32) public serialNumberToProduct;

    struct quality {
        uint32 productId;
        string color;
        string weight;
        string description;
        bytes32 productHash;            // Hash of product secret shared inside product packaging
        uint32 productAnalyserId;
        address productAnalyserAddress;
        uint32 qaTimeStamp;
    }

    mapping(uint32 => quality) public qualityChecks;
    mapping(uint32 => uint32) public productToQuality;

    struct participant {
        string userName;
        string password;        // Fix this: Storing password on the blockchain is a bad idea!!
        string participantType;
        address participantAddress;
        uint32 entryTimeStamp;
    }
    mapping(uint32 => participant) public participants;
    mapping(address => uint32) public addressToParticipants;

    struct ownership {
        uint32 productId;
        uint32 ownerId;
        uint32 trxTimeStamp;
        address productOwner;
    }
    mapping(uint32 => ownership) public ownerships; // ownerships by ownership ID (owner_id)
    mapping(uint32 => uint32[]) public productTrack;  // ownerships by Product ID (product_id) / Movement track for a product

    event TransferOwnership(uint32 productId);

    modifier onlyAdmin() {
         require(!adminSet || (keccak256(abi.encodePacked(participants[addressToParticipants[msg.sender]].participantType)) == keccak256("admin")), "Non-admin cannot add participants");
         _;
    }

    function addParticipant(string memory _name, string memory _pass, address _pAdd, string memory _pType) onlyAdmin() public returns (uint32){
        if (keccak256(abi.encodePacked(_pType)) != keccak256("admin") && adminSet)
        {
            // Add a normal participant.
            // check duplicate
            require(participants[addressToParticipants[_pAdd]].entryTimeStamp == 0, "Duplicate participant");
            uint32 userId = ++participant_id;
            participants[userId].userName = _name;
            participants[userId].password = _pass;
            participants[userId].participantAddress = _pAdd;
            participants[userId].participantType = _pType;
            participants[userId].entryTimeStamp = uint32(block.timestamp);
            addressToParticipants[_pAdd] = userId;

            return userId;
        }
        else if (keccak256(abi.encodePacked(_pType)) == keccak256("admin"))
        {
            if (adminSet)
            {
                revert("Admin is already set");
            }
            else
            {
                // Add admin user. Needs to be done at the launch of contract to ensure 
                // monopolisitic admin.
                adminSet = true;
                uint32 userId = ++participant_id;
                participants[userId].userName = _name;
                participants[userId].password = _pass;
                participants[userId].participantAddress = _pAdd;
                participants[userId].participantType = _pType;
                participants[userId].entryTimeStamp = uint32(block.timestamp);
                addressToParticipants[_pAdd] = userId;

                return userId;
            }
        }
        else
        {
            revert("Admin is not set");
        }
    }

    function getParticipant(address _participant_address) public view returns (string memory,address,string memory) {
        uint32 _participant_id = addressToParticipants[_participant_address];
        return (participants[_participant_id].userName,
                participants[_participant_id].participantAddress,
                participants[_participant_id].participantType);
    }

    function addProduct(address _ownerAddress,
                        string memory _seedName,
                        string memory _seedType,
                        string memory _serialNumber,
                        uint32 _productCost) public returns (uint32) {
        uint32 _ownerId = addressToParticipants[_ownerAddress];
        if(keccak256(abi.encodePacked(participants[_ownerId].participantType)) == keccak256("Producer")) {
            require( products[serialNumberToProduct[_serialNumber]].supplyTimeStamp == 0, "Product already added.");
            uint32 productId = ++product_id;

            products[productId].seedName = _seedName;
            products[productId].seedType = _seedType;
            products[productId].serialNumber = _serialNumber;
            products[productId].cost = _productCost;
            products[productId].productOwner = participants[_ownerId].participantAddress;
            products[productId].supplyTimeStamp = uint32(block.timestamp);
            serialNumberToProduct[_serialNumber] = productId;

            return productId;
        }

       return 0;
    }

    function addQualityReport(string memory _serialNumber,
                              string memory _color,
                              string memory _weight,
                              string memory _description,
                              bytes32 _productHash,
                              address _productAnalyserAddress) public returns (uint32) {
        uint32 _productAnalyserId = addressToParticipants[_productAnalyserAddress];
        uint32 _productId = serialNumberToProduct[_serialNumber];
        if(keccak256(abi.encodePacked(participants[_productAnalyserId].participantType)) == keccak256("Quality-Analyser")) {
            require( qualityChecks[productToQuality[_productId]].qaTimeStamp == 0, "Quality report already added for product");
            uint32 qualityId = ++quality_id;

            qualityChecks[qualityId].productId = _productId;
            qualityChecks[qualityId].color = _color;
            qualityChecks[qualityId].weight = _weight;
            qualityChecks[qualityId].description = _description;
            qualityChecks[qualityId].productHash = _productHash;
            qualityChecks[qualityId].productAnalyserId = _productAnalyserId;
            qualityChecks[qualityId].productAnalyserAddress = participants[_productAnalyserId].participantAddress;
            qualityChecks[qualityId].qaTimeStamp = uint32(block.timestamp);

            productToQuality[_productId] = qualityId;

            return productToQuality[_productId];
        }

       return 0;
    }

    function getQualityReport(string memory _serialNumber) public view returns (string memory,string memory,string memory,bytes32,uint32,uint32) {
        uint32 _productId = serialNumberToProduct[_serialNumber];
        quality memory report = qualityChecks[productToQuality[_productId]];
        return (report.color,
                report.weight,
                report.description,
                report.productHash,
                report.productAnalyserId,
                report.qaTimeStamp);
    }

    modifier onlyOwner(string memory _serialNumber) {
        uint32 _productId = serialNumberToProduct[_serialNumber];
         require(msg.sender == products[_productId].productOwner,"");
         _;

    }

    function getProduct(string memory _serialNumber) public view returns (string memory,string memory,string memory,uint32,address,uint32){
        uint32 _productId = serialNumberToProduct[_serialNumber];
        return (products[_productId].seedName,
                products[_productId].seedType,
                products[_productId].serialNumber,
                products[_productId].cost,
                products[_productId].productOwner,
                products[_productId].supplyTimeStamp);
    }

    function newOwner(address _participant_address1,address _participant_address2, string memory _serialNumber) onlyOwner(_serialNumber) public returns (bool) {
        uint32 _user1Id = addressToParticipants[_participant_address1];
        uint32 _user2Id = addressToParticipants[_participant_address2];
        uint32 _prodId = serialNumberToProduct[_serialNumber];
        participant memory p1 = participants[_user1Id];
        participant memory p2 = participants[_user2Id];
        uint32 ownership_id = ++owner_id;

        if(keccak256(abi.encodePacked(p1.participantType)) == keccak256("Producer")
            && keccak256(abi.encodePacked(p2.participantType))==keccak256("Quality-Analyser")){
            
        }
        else if(keccak256(abi.encodePacked(p1.participantType)) == keccak256("Quality-Analyser")
            && keccak256(abi.encodePacked(p2.participantType))==keccak256("Distributor")){
            
        }
        else if(keccak256(abi.encodePacked(p1.participantType)) == keccak256("Distributor") && keccak256(abi.encodePacked(p2.participantType))==keccak256("Distributor")){
            
        }
        else if(keccak256(abi.encodePacked(p1.participantType)) == keccak256("Distributor") && keccak256(abi.encodePacked(p2.participantType))==keccak256("Consumer")){
            
        }
        else{
            return (false);
        }
        ownerships[ownership_id].productId = _prodId;
        ownerships[ownership_id].productOwner = p2.participantAddress;
        ownerships[ownership_id].ownerId = _user2Id;
        ownerships[ownership_id].trxTimeStamp = uint32(block.timestamp);
        products[_prodId].productOwner = p2.participantAddress;
        productTrack[_prodId].push(ownership_id);
        emit TransferOwnership(_prodId);

        return (true);
    }

   function getProvenance(string memory _serialNumber) external view returns (uint32[] memory) {
       uint32 _prodId = serialNumberToProduct[_serialNumber];
       return productTrack[_prodId];
    }

    function getOwnership(uint32 _regId)  public view returns (uint32,uint32,address,uint32) {

        ownership memory r = ownerships[_regId];

         return (r.productId,r.ownerId,r.productOwner,r.trxTimeStamp);
    }

    function authenticateParticipant(uint32 _uid,
                                    string memory _uname,
                                    string memory _pass,
                                    string memory _utype) public view returns (bool){
        if(keccak256(abi.encodePacked(participants[_uid].participantType)) == keccak256(abi.encodePacked(_utype))) {
            if(keccak256(abi.encodePacked(participants[_uid].userName)) == keccak256(abi.encodePacked(_uname))) {
                if(keccak256(abi.encodePacked(participants[_uid].password)) == keccak256(abi.encodePacked(_pass))) {
                    return (true);
                }
            }
        }

        return (false);
    }
}