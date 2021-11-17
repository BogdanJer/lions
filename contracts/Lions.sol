// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.8.0;

import "./ERC721Namable.sol";
import "./interfaces/IERC1155.sol";
import "./YieldToken.sol";


contract Lions is ERC721Namable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


	address public constant burn = address(0x000000000000000000000000000000000000dEaD);

    address owner;

	mapping(address => uint256) public balanceOG;

	YieldToken public yieldToken;

    uint256 constant PRESALE_COUNT = 500;
    uint256 constant PRESALE_PRICE = 59000000 gwei;
    uint256 constant PRICE = 70000000 gwei;

    uint256 lionsCount; 

    bool private initialized;    


    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

	constructor(string memory _name, string memory _symbol, address _yieldToken) ERC721Namable(_name, _symbol) {
        owner = msg.sender;
		_setBaseURI("https://lions.youaremetaverse.com/api/lion/");
        yieldToken = YieldToken(_yieldToken);
	}

    function withdraw() public onlyOwner {
        address _this = address(this);
        payable(owner).transfer(_this.balance);
    }

	function updateURI(string memory _newURI) public onlyOwner {
		_setBaseURI(_newURI);
	}

    function init() public onlyOwner{
        require(!initialized, "Contract instance has already been initialized");
        
        for(uint i=1; i<=10; i++) {
            _mint(0x85A5F069C4f2C34C2Aa49611e84b634193d0923b, i);
        }
        yieldToken.updateRewardOnMint(0x85A5F069C4f2C34C2Aa49611e84b634193d0923b, 10);

        initialized = true;
    }

    function transferOwnership(address _newOwner) public virtual onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        
         address _oldOwner = owner;
         owner = _newOwner;
        emit OwnershipTransferred(_oldOwner, _newOwner);
    }

    function mint(uint256[] memory _ids) public payable {
       lionsCount < 500 ? require(_ids.length * PRESALE_PRICE == msg.value, "Value isn't correct") :
           require(_ids.length * PRICE == msg.value, "Value isn't correct");

        for(uint i=0; i<_ids.length; i++) {
            _mint(msg.sender, _ids[i]);
        }
        lionsCount += _ids.length;
        yieldToken.updateRewardOnMint(msg.sender, _ids.length);
        balanceOG[msg.sender] += _ids.length;
    }

	function changeNamePrice(uint256 _price) external onlyOwner {
		nameChangePrice = _price;
	}

    function changeBioPrice(uint256 _price) external onlyOwner {
        bioChangePrice = _price;
    }

	function changeName(uint256 _tokenId, string memory _newName) public override {
		yieldToken.burn(msg.sender, nameChangePrice);
		super.changeName(_tokenId, _newName);
	}

	function changeBio(uint256 _tokenId, string memory _bio) public override {
		yieldToken.burn(msg.sender, bioChangePrice);
		super.changeBio(_tokenId, _bio);
	}

	function getReward() external {
		yieldToken.updateReward(msg.sender, address(0));
		yieldToken.getReward(msg.sender);
	}

	function transferFrom(address _from, address _to, uint256 _tokenId) public override {
		yieldToken.updateReward(_from, _to);
		
		balanceOG[_from]--;
		balanceOG[_to]++;
		
		ERC721.transferFrom(_from, _to, _tokenId);
	}

	function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public override {
		yieldToken.updateReward(_from, _to);
		
		balanceOG[_from]--;
		balanceOG[_to]++;
		
		ERC721.safeTransferFrom(_from, _to, _tokenId, _data);
	}

    function getClaimable(address _user) public view returns(uint256) {
        return yieldToken.getTotalClaimable(_user);
    }
}