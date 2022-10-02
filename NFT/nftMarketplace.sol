// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract nftMarketplace is ReentrancyGuard {
    struct Listing {
        uint256 price;
        address seller;
    }
        ///////events
        event ItemListed(
            address indexed seller,
            address indexed nftAddress
            uint256 indexed tokenId
            uint256 price
        );
        event ListingCancelled(
            address indexed seller,
            address indexed nftAddress,
            uint256 indexed tokenId
        );
        event ItemBought(
            address indexed buyer,
            address indexed nftAddress,
            uint256 indexed tokenId
            uint256 price
        );
        event ListingUpdated(
            address indexed seller,
            address indexed nftAddress,
            uint256 indexed tokenId,
            uint256 tokenId
        );
        
        ////mapping
        mapping (address => uint256) private s_proceeds;
        mapping (address => mapping (uint256 => Listing) ) s_listing;

        ////modifiers
        modifier Listed(address nftAddress,uint256 tokenId) {
            Listing memory listing=s_listing[nftAddress][tokenId];
            require(listing.price>=0,"not listed")
            
        }
        modifier notListed(address nftAddress,uint256 tokenId,address owner) {
            Listing memory listing=s_listing[nftAddress][tokenId];
            require(listing.price<=0,"already Listed")
        }
        modifier isOwner(address nftAddress,uint256 tokenId,address spender) {
            IERC721 nft=IERC721(nftAddress);
            address owner=nft.ownerOf(tokenId);
            require(spender==owner,"not owner")
        }


        function ListItem(address nftAdress,uint256 tokenId,uint256 price)  
        external isOwner(nftAddress,tokenId,msg.sender)
        notListed(nftAddress,tokenId,msg.sender) {
            require(price>0,"must be more than Zero")
            IERC721 nft=IERC721(nftAdress);
            if (nft.getApproved(tokenId)!=address(this)) {
                revert notApprovedForListing();
            }
            s_listing[nftAddress][tokenId]=Listing(price,msg.sender);
            emit ItemListed(msg.sender,nftAddress,tokenId,price);

        }
        function CancelListing(address nftAddress,uint256 tokenId)
          external 
        isOwner(nftAddress,tokenId,msg.sender)
        Listed(nftAddress,tokenId) {
            delete(s_listing[nftAddress][tokenId]);
            emit ListingCancelled(msg.sender,tokenId,)
        }
        function buyItem(address nftAddress,uint256 tokenId) 
         external payable Listed(nftAddress,tokenId) {
            Listing memory listedItem=s_listing[nftAddress][tokenId];
            require(msg.value>=listedItem.price,"price not met");
            s_proceeds[listedItem.seller]+=msg.value;
            IERC721(nftAddress).safeTransferFrom(listedItem.seller,msg.sender,tokenId);
            emit ItemBought(msg.sender,nftAddress,)
        }
        function updateListing(address nftAddress,uint256 tokenId,uint256 newPrice) 
         external isOwner(nftAddress,tokenId,msg.sender) Listed(nftAddress,tokenId){
            s_listing[nftAddress][tokenId].price=newPrice;
            emit ListingUpdated(msg.sender,nftAddress,tokenId,newPrice)
        }
        function withdrawPayments()external{
            uint256 proceeds=s_proceeds[msg.sender] 
            require(proceeds > 0,"no proceeds") 
            s_proceeds[msg.sender]=0
            (bool success,)= payable(msg.sender).call{value:proceeds}("")
            require(success,"transfer failed")

            /////////////////////
    // Getter Functions //
    /////////////////////

    function getListing(address nftAddress, uint256 tokenId)
        external
        view
        returns (Listing memory)
    {
        return s_listings[nftAddress][tokenId];
    }

    function getProceeds(address seller) external view returns (uint256) {
        return s_proceeds[seller];
    }

      }

    
}