// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MarketplaceStorage {
    enum ItemStatus {
        LIST,
        BOUGHT,
        OFFER,
        UN_LIST
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
        uint256 tokenId;
        // Price (in wei) for the published item
        uint256 price;
        address offerBy;
    }

    // From ERC721 registry assetId to Item (to avoid asset collision)
//    mapping(address => mapping(uint256 => Item)) public items;
    mapping(uint256 => Item) items;

    // From ERC721 registry assetId to Offer (to avoid asset collision)
    mapping(uint256 => mapping(address => ItemOffer)) public itemOffers;

    address public legacyNFTAddress;
    address public nftAddress;

    bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);

    // EVENTS
    event ListItem(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price // in wei
    );
    event BuyItem(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price,
        address indexed buyer
    );
    event SellItem(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price
    );
    event UnListItem(
        address indexed unListBy,
        uint256 indexed tokenId
    );
    event ItemOfferApproved(
        bytes32 id,
        uint256 indexed assetId,
        address indexed seller,
        address nftAddress,
        uint256 totalPrice,
        address indexed buyer
    );
    event OfferItem(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price,
        address indexed offerBy
    );
    event CancelOfferItem(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price,
        address indexed offerBy
    );
    event ChangeLegacyNFTAddress(address indexed legacyNFTAddress);
}
