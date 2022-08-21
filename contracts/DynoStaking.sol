// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract DynoStaking is ERC721Holder, Ownable {
	IERC20 public stDYNO;
	address public stDYNO_;

	//Staking Config for DynoAvatars
	IERC721Enumerable public DynoAvatar;
	mapping(uint256 => uint256) public DynoAvatarStakedAt;
	mapping(uint256 => address) public DynoAvatarOwners;
	uint256 public DA_STAKING_RATE = 86400;
	uint256 public minimumStakingTime = 86400;

	constructor(address _stDYNO, address _DynoAvatar) {
		stDYNO_ = _stDYNO;
		stDYNO = IERC20(_stDYNO);
		DynoAvatar = IERC721Enumerable(_DynoAvatar);
	}

	function stake(uint256 tokenId) external {
		DynoAvatar.safeTransferFrom(msg.sender, address(this), tokenId);
		DynoAvatarOwners[tokenId] = msg.sender;
		DynoAvatarStakedAt[tokenId] = block.timestamp;
	}

	function calculateStakingYield(uint256 tokenId) public view returns (uint256) {
		uint256 timeElasped = block.timestamp - DynoAvatarStakedAt[tokenId];
		return timeElasped / DA_STAKING_RATE;
	}

	function unstake(uint256 tokenId) external {
		uint256 timeElasped = block.timestamp - DynoAvatarStakedAt[tokenId];

		require(timeElasped >= minimumStakingTime, "You cannot unstake at this time");
		require(DynoAvatarOwners[tokenId] == msg.sender, "A Fatal Error has occured, Not the owner of the Stake.");
		stDYNO.transferFrom(stDYNO_, msg.sender, calculateStakingYield(tokenId));
		DynoAvatar.safeTransferFrom(address(this), msg.sender, tokenId);

		delete DynoAvatarOwners[tokenId];
		delete DynoAvatarStakedAt[tokenId];
	}
}