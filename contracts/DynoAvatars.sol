    // SPDX-License-Identifier: MIT

    pragma solidity ^0.8.7;

    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/utils/Strings.sol";
    import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
    import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

    contract DynoAvatars is ERC721Enumerable, VRFConsumerBaseV2, Ownable {
  	  using Strings for uint256;

  	  string baseURI;
    	bool public paused = false;
    	uint256 public cost = 1*10**18;
    	uint256 public maxAmount = 1;
    	uint256 public maxSupply = 10;
      VRFCoordinatorV2Interface COORDINATOR;

      address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
      bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
      uint32 callbackGasLimit = 100000;
      uint16 requestConfirmations = 3;
      uint32 numWords =  4;
      uint64 subscriptionId = 1488;

      uint256[] public randomWords;
      uint256 public requestId;

      struct Avatar {
        uint256 speed;
        uint256 power;
        uint256 agility;
        uint256 strength;
      }

      mapping(uint256 => Avatar) public avatar;

      constructor(string memory name, string memory symbol, string memory initBaseURI) ERC721(name, symbol) VRFConsumerBaseV2(vrfCoordinator) {
        setBaseURI(initBaseURI);
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
      }

    	// Internal Functions -- _baseURI is a getter function for the baseURI of our NFTs.
  	  function _baseURI() internal view override returns (string memory) {
  		  return baseURI;
  	  }

    	//Public Functions
    	function mint(uint256 amount) public payable {
    		uint256 supply = totalSupply();

    		require(!paused, "Minting is currently Paused.");
    		require(amount <= maxAmount, "Exceeded minting amount limits.");
    		require(amount + supply <= maxSupply, "Exceeded minting supply limits.");

    		if (msg.sender != owner()) {
    	    require(msg.value >= cost, "Insufficent Funds for minting.");
    	  }

        requestRandomWords();

        Avatar memory _avatar = Avatar({
          speed : randomWords[0] % 100,
          power : randomWords[1] % 50,
          agility : randomWords[2] % 75,
          strength : randomWords[3] % 100
        });

        avatar[supply + 1] = _avatar;
        _safeMint(msg.sender, supply + 1);
  	  }

    	function walletOfOwner(address _owner) public view returns (uint256[] memory) {
  		  uint256 ownerTokenCount = balanceOf(_owner);
      	uint256[] memory tokenIds = new uint256[](ownerTokenCount);

      	for (uint256 i; i < ownerTokenCount; i++) {
      		tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
      	}

      	return tokenIds;
  	  }

    	function tokenURI(uint256 tokenId) public view override returns (string memory) {
    		require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent Token");

    		string memory currentBaseURI = _baseURI();

    		return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId, ".json")) : "";
    	}

      //Verifiable Random Functions via ChainLink's VRF v2.
      function requestRandomWords() internal onlyOwner {
        requestId = COORDINATOR.requestRandomWords(keyHash, subscriptionId, requestConfirmations, callbackGasLimit, numWords);
      }

      function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        randomWords = _randomWords;
      }

	    //only owner
    	function setCost(uint256 _newCost) public onlyOwner {
      	cost = _newCost;
    	}

    	function setBaseURI(string memory _newBaseURI) public onlyOwner {
      	baseURI = _newBaseURI;
    	}

    	function pause(bool _state) public onlyOwner {
      	paused = _state;
    	}

    	function withdraw() public payable onlyOwner {
      	(bool os, ) = payable(owner()).call{value: address(this).balance}("");
      	require(os);
    	}
    }