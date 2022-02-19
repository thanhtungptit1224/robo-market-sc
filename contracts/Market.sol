// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "./Storage.sol";

contract Market is Initializable, OwnableUpgradeable, PausableUpgradeable, Storage {

    function initialize(address _nftAddress) initializer public {
        validateNftAddress(_nftAddress);
        nftAddress = _nftAddress;
        __Ownable_init();
    }

    function validateNftAddress(address _nftAddress) internal view {
        require(_nftAddress.code.length > 0, "The NFT Address should be a contract");
        IERC721Upgradeable nft = IERC721Upgradeable(_nftAddress);
        require(nft.supportsInterface(ERC721_Interface), "The NFT contract has an invalid ERC721 implementation");
    }

    // owner listing to other buy. must approve before
    function list(uint256 _tokenId, uint256 _price) public {
        IERC721Upgradeable nft  = IERC721Upgradeable(nftAddress);
        address owner           = nft.ownerOf(_tokenId);

        require(_price > 0, "Price should be bigger than 0");
        require(_msgSender() == owner, "Only the owner can list item");
        require(
            nft.getApproved(_tokenId) == address(this) || nft.isApprovedForAll(owner, address(this)),
            "The contract is not authorized to manage the nft"
        );

        items[_tokenId] = Item({
            tokenId: _tokenId,
            owner  : owner,
            price  : _price,
            status : ItemStatus.LIST
        });

        emit ListItem(owner, _tokenId, _price);
    }

    function buyItem(uint256 _tokenId) public payable {
        IERC721Upgradeable nft  = IERC721Upgradeable(nftAddress);
        Item memory item        = items[_tokenId];

        require(msg.value >= item.price, "Value need equal price");
        require(item.status == ItemStatus.LIST, "Nft is not list to buy");
        require(
            item.owner == nft.ownerOf(_tokenId),
            "The seller is no longer the owner"
        );

        payable(item.owner).transfer(msg.value);
        nft.safeTransferFrom(item.owner, _msgSender(), _tokenId);

        items[_tokenId].owner  = _msgSender();
        items[_tokenId].status = ItemStatus.BOUGHT;

        emit BuyItem(item.owner, _tokenId, item.price, _msgSender());
    }

    function sellItem(uint256 _tokenId, uint256 _price) public {
        IERC721Upgradeable nft  = IERC721Upgradeable(nftAddress);
        Item memory item        = items[_tokenId];

        require(_price > 0, "Price should be bigger than 0");
        require(item.status == ItemStatus.BOUGHT || item.status == ItemStatus.UN_LIST, "NFT is not ready to sell");
        require(
            nft.ownerOf(_tokenId) == _msgSender(),
            "The seller is no longer the owner"
        );

        items[_tokenId].owner  = _msgSender();
        items[_tokenId].price  = _price;
        items[_tokenId].status = ItemStatus.LIST;

        emit SellItem(_msgSender(), _tokenId, _price);
    }

    function unListItem(uint256 _tokenId) public {
        IERC721Upgradeable nft = IERC721Upgradeable(nftAddress);
        Item memory item       = items[_tokenId];

        require(item.status == ItemStatus.LIST, "NFT is not list");
        require(
            nft.ownerOf(_tokenId) == _msgSender(),
            "The seller is no longer the owner"
        );

        items[_tokenId].status = ItemStatus.UN_LIST;

        emit UnListItem(_msgSender(), _tokenId);
    }

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function offerItem(uint256 _tokenId) onlyInitializing public payable {
        IERC721Upgradeable nft  = IERC721Upgradeable(nftAddress);
        Item memory item        = items[_tokenId];

        require(item.tokenId > 0, "Asset not published");
        require(
            item.owner == nft.ownerOf(_tokenId),
            "The seller is no longer the owner"
        );
        require(
            msg.value > 0,
            "Offer price should be bigger than 0"
        );

        itemOffers[_tokenId][_msgSender()] = ItemOffer({
            tokenId: _tokenId,
            price  : msg.value,
            offerBy: _msgSender()
        });

        emit OfferItem(_tokenId, item.owner, msg.value, _msgSender());
    }

    // Function to transfer BNB from this contract to address from sender
    function cancelOfferItem(uint256 _tokenId) onlyInitializing public {
        Item memory item            = items[_tokenId];
        ItemOffer memory itemOffer  = itemOffers[_tokenId][_msgSender()];

        require(item.tokenId > 0, "Asset not published");
        require(itemOffer.offerBy == _msgSender(), "You're not offer item");

        payable(_msgSender()).transfer(itemOffer.price);

        delete itemOffers[_tokenId][_msgSender()];

        emit CancelOfferItem(_tokenId, item.owner, itemOffer.price, _msgSender());
    }

    function approveOfferItem(uint256 _tokenId, address _offerBy) onlyInitializing public {
        IERC721Upgradeable nft     = IERC721Upgradeable(nftAddress);
        Item memory item           = items[_tokenId];
        ItemOffer memory itemOffer = itemOffers[_tokenId][_offerBy];

        require(item.tokenId > 0, "Asset not published");
        require(
            item.owner == msg.sender && item.owner == nft.ownerOf(_tokenId),
            "The seller is no longer the owner"
        );

        payable(item.owner).transfer(itemOffer.price);
        nft.safeTransferFrom(item.owner, _offerBy, _tokenId);

        items[_tokenId].owner  = _offerBy;
        items[_tokenId].status = ItemStatus.BOUGHT;
        items[_tokenId].price  = itemOffer.price;

        delete itemOffers[_tokenId][_offerBy];

        emit ApproveOfferItem(_tokenId, item.owner, itemOffer.price, _offerBy);
    }

}
