// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BasicNft is ERC721 {
    using Strings for uint;
    string public domain = "https://raw.githubusercontent.com/thanhtungptit1224/robo-market-sc/master/";

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {

    }

    function award(address _to, uint _tokenId) public {
        _mint(_to, _tokenId);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "TokenId is not available");
        if (bytes(domain).length > 0) {
            return string(abi.encodePacked(domain, _tokenId.toString(), ".json"));
        } else {
            return "";
        }
    }
}