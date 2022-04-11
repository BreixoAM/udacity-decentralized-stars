pragma solidity >=0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    struct Star {
        string name;
    }
    
    string public name;
    string public symbol;

    constructor (string memory _name, string memory _symbol) public {
        name = _name;
        symbol = _symbol;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    
    function createStar(string memory _name, uint256 _tokenId) public {
        Star memory newStar = Star(_name);
        tokenIdToStarInfo[_tokenId] = newStar;
        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, _tokenId);
        address payable ownerAddressPayable = _make_payable(ownerAddress);
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        return tokenIdToStarInfo[_tokenId].name;
    }

    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        address star1OwnerAddress = ownerOf(_tokenId1);
        address star2OwnerAddress = ownerOf(_tokenId2);
        _transferFrom(star1OwnerAddress, star2OwnerAddress, _tokenId1);
        _transferFrom(star2OwnerAddress, star1OwnerAddress, _tokenId2);
    }

    function transferStar(address _to1, uint256 _tokenId) public {
        address ownerAddress = ownerOf(_tokenId);
        require(msg.sender == ownerAddress);
        _transferFrom(ownerAddress, _to1, _tokenId);
    }
}
