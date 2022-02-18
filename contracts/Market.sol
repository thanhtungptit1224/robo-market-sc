// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "MarketplaceStorage.sol";

contract Market is Initializable, OwnableUpgradeable, PausableUpgradeable, MarketplaceStorage {
    address public nftAddress;
    
    function initialize(address _nftAddress) initializer public {
        validateNftAddress(_nftAddress);
        nftAddress = _nftAddress;
        __Ownable_init();
    }

    function validateNftAddress(address _nftAddress) internal view {
        require(_nftAddress.isContract(), "The NFT Address should be a contract");

        IERC721Upgradeable nft = IERC721Upgradeable(_nftAddress);

        require(nft.supportsInterface(ERC721_Interface), "The NFT contract has an invalid ERC721 implementation");
    }

    function list(uint256 _tokenId, uint256 _price) onlyInitializing public {
        IERC721Upgradeable nft = IERC721Upgradeable(nftAddress);
        address ownerAddress = nft.ownerOf(_tokenId);

        require(_msgSender() == ownerAddress, "Only the owner can list item");
        require(
            nft.getApproved(_tokenId) == address(this) || nft.isApprovedForAll(ownerAddress, address(this)),
            "The contract is not authorized to manage the nft"
        );
        require(_price > 0, "Price should be bigger than 0");

        emit ListItem(ownerAddress, nftAddress, _tokenId, _price);
    }
}
