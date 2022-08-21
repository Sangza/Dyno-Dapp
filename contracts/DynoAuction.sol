// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract DynoAuction is ERC721Holder, Ownable {
	using SafeMath for uint256;

	IERC20 public DYNO;
	address public DYNO_;

	//Auction Config for DynoAvatars
	IERC721Enumerable public DynoAvatar;
	struct Auction_Props {
		uint256 duration;
		uint256 startTime;
		uint256 tokenId;
		address auctioneer;
		uint256 currentBid;
		address highestBidder;
		uint256 startingPrice;
	}
	mapping(uint256 => Auction_Props) public Auctions;
	event Init(address indexed auctioneer, uint256 indexed tokenId);
	event Bid(address indexed bidder, uint256 indexed amount);
	event Closed(address indexed auctioneer, uint256 indexed tokenId, uint256 endTime);

	constructor(address _DYNO, address _DynoAvatar) {
		DYNO_ = _DYNO;
		DYNO = IERC20(_DYNO);
		DynoAvatar = IERC721Enumerable(_DynoAvatar);
	}

	function init(uint256 tokenId, uint256 duration, uint256 startingPrice) external {
		DynoAvatar.safeTransferFrom(msg.sender, address(this), tokenId);

		Auction_Props memory auction = Auction_Props({
			duration : duration,
			startTime : block.timestamp,
			tokenId : tokenId,
			auctioneer : msg.sender,
			currentBid : 0,
			highestBidder : msg.sender,
			startingPrice : startingPrice
		});

		Auctions[tokenId] = auction;

		emit Init(msg.sender, tokenId);
	}

	function bid(uint256 tokenId, uint256 amount) external {
		Auction_Props memory auction = Auctions[tokenId];
		uint256 prevBid = auction.currentBid;

		require(auction.duration > block.timestamp.sub(auction.startTime), "Auction for this Avatar has ended");
		require(amount >= auction.currentBid, "Bid not accepted");

		DYNO.transferFrom(msg.sender, address(this), amount);
		if(prevBid != 0) {
			DYNO.transferFrom(address(this), auction.highestBidder, prevBid);
		}

		Auctions[tokenId].currentBid = amount;
		Auctions[tokenId].highestBidder = msg.sender;
		emit Bid(msg.sender, amount);
	}

	function close(uint256 tokenId) external {
		Auction_Props memory auction = Auctions[tokenId];

		require(msg.sender == auction.auctioneer, "Access Rights Denied");
		require(auction.duration == block.timestamp.sub(auction.startTime), "Auction for this Avatar has not ended");

		DYNO.transferFrom(address(this), auction.auctioneer, auction.currentBid);
		DynoAvatar.safeTransferFrom(address(this), auction.highestBidder, tokenId);

		delete Auctions[tokenId];
		emit Closed(msg.sender, tokenId, block.timestamp);
	}
}