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

    // owner listing to other buy. must approve before
    function list(uint256 _tokenId, uint256 _price) onlyInitializing public {
        IERC721Upgradeable nft = IERC721Upgradeable(nftAddress);
        address owner = nft.ownerOf(_tokenId);

        require(_price > 0, "Price should be bigger than 0");
        require(_msgSender() == owner, "Only the owner can list item");
        require(
            nft.getApproved(_tokenId) == address(this) || nft.isApprovedForAll(owner, address(this)),
            "The contract is not authorized to manage the nft"
        );

        items[_tokenId] = Item({
            tokenId: _tokenId,
            owner : owner,
            price  : _price,
            status : ItemStatus.LIST
        });

        emit ListItem(owner, _tokenId, _price);
    }

    function buyItem(uint256 _tokenId) onlyInitializing public payable {
        IERC721Upgradeable nft = IERC721Upgradeable(nftAddress);
        Item memory item = items[_tokenId];

        require(msg.value >= item.price, "Value need equal price");
        require(item.status == ItemStatus.LIST, "Nft is not list to buy");
        require(
            item.owner == nft.ownerOf(_tokenId),
            "The seller is no longer the owner"
        );

        payable(item.owner).transfer(msg.value);
        nft.safeTransferFrom(item.owner, _msgSender(), _tokenId);

        items[_tokenId].owner = _msgSender();
        items[_tokenId].status = ItemStatus.BOUGHT;

        emit BuyItem(
            item.owner,
            _tokenId,
            item.price,
            _msgSender()
        );
    }

}
