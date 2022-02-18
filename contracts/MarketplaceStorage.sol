// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MarketplaceStorage {
    enum ItemStatus {
        LIST,
        BOUGHT,
        OFFER,
        DELIST
    }

    struct Item {
        // Item ID
        uint256 tokenId;
        // Owner of the NFT
        address owner;
        // Price (in wei) for the published item
        uint256 price;
        // status of the item
        ItemStatus status;
    }

    struct ItemOffer {
        // Item ID
        bytes32 id;
        // Price (in wei) for the published item
        uint256 offerPrice;
    }

    // From ERC721 registry assetId to Item (to avoid asset collision)
//    mapping(address => mapping(uint256 => Item)) public items;
    mapping(uint256 => Item) items;

    // From ERC721 registry assetId to Offer (to avoid asset collision)
    mapping(address => mapping(uint256 => mapping(address => ItemOffer)))
    public itemOffers;

    address public legacyNFTAddress;
    address public nftAddress;

    bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);

    // EVENTS
    event ListItem(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price // in wei
    );
    event DelistItemSuccessful(
        address nftAddress,
        bytes32 id,
        uint256 indexed assetId,
        address indexed delistBuy
    );
    event BuyItem(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price,
        address indexed buyer
    );
    event SellItemSuccessful(
        address nftAddress,
        bytes32 id,
        uint256 indexed assetId,
        uint256 totalPrice,
        address indexed seller
    );
    event ItemOfferApproved(
        bytes32 id,
        uint256 indexed assetId,
        address indexed seller,
        address nftAddress,
        uint256 totalPrice,
        address indexed buyer
    );
    event ItemOfferCreated(
        bytes32 id,
        uint256 indexed assetId,
        address indexed seller,
        address nftAddress,
        uint256 offerPrice,
        address indexed offerer
    );
    event ItemOfferCanceled(
        bytes32 id,
        uint256 indexed assetId,
        address indexed seller,
        address nftAddress,
        uint256 offerPrice,
        address indexed offerer
    );
    event ChangeLegacyNFTAddress(address indexed legacyNFTAddress);
}
