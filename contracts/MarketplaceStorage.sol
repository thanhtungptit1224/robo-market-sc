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
        bytes32 id;
        // Owner of the NFT
        address seller;
        // NFT registry address
        address nftAddress;
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
    mapping(address => mapping(uint256 => Item)) public items;

    // From ERC721 registry assetId to Offer (to avoid asset collision)
    mapping(address => mapping(uint256 => mapping(address => ItemOffer)))
    public itemOffers;

    address public legacyNFTAddress;

    bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);

    // EVENTS
    event ItemCreated(
        address indexed sellerAddress,
        address nftAddress,
        uint256 indexed tokenId,
        uint256 priceInWei
    );
    event DelistItemSuccessful(
        address nftAddress,
        bytes32 id,
        uint256 indexed assetId,
        address indexed delistBuy
    );
    event BuyItemSuccessful(
        bytes32 id,
        uint256 indexed assetId,
        address indexed seller,
        address nftAddress,
        uint256 totalPrice,
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
