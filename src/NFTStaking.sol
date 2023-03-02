// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20Mintable} from "@main/interfaces/IERC20Mintable.sol";

import {Errors} from "@main/shared/Error.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";


contract NFTStaking is IERC721Receiver, Ownable2Step {

    event Stake(address indexed sender, uint256 indexed tokenId, uint256 indexed timestamp);
    event Unstake(address indexed sender, uint256 indexed tokenId, uint256 indexed timestamp);
    event ClaimReward(address indexed receiver, uint256 indexed timestamp, uint256 rewardAmount);
    event RewardPerDaySet(uint256 indexed previousRewardPerDay, uint256 newRewardPerDay);

    // Info of each user.
    struct UserInfo {
        address owner;
        uint256 startTime;
    }

    mapping(uint256 => UserInfo) stakes;

    /**
     * @notice the ERC20 Game token rewardable
    **/
    IERC20Mintable public immutable gameToken;

    /**
     * @notice the ER721 Game NFT Stakable
    **/
    IERC721 public immutable gameNFT;

    /**
     * @notice the reward amount of ERC20 per day i.e. 20 token perday
    **/
    uint256 public rewardPerDay;

    /**
     * @notice NFT Staking constructor
     * @param _gameToken ERC20 token 
     * @param _gameNFT ERC721 token sale 
     */
    constructor(
        IERC20Mintable _gameToken,
        IERC721 _gameNFT,
        uint256 _rewardPerDay
        ) {
        gameToken = _gameToken;
        gameNFT = _gameNFT;
        rewardPerDay = _rewardPerDay;
    }

    /**
     * @notice checks if the msg.sender is the owener of the NFT
     * @param _tokenId tokenId
     */
    modifier onlyNFTOwner(uint256 _tokenId) {
        if (gameNFT.ownerOf(_tokenId) != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    /**
     * @notice Stake NFT and start gaining erc20 rewards
     * @param tokenId   NFT Id
     */
    function stakeNFT(uint256 tokenId) external onlyNFTOwner(tokenId) {
        require(stakes[tokenId].owner != msg.sender, "ID_ALREADY_STAKED" );
        stakes[tokenId] = UserInfo(msg.sender, block.timestamp);
        gameNFT.transferFrom(msg.sender, address(this), tokenId);
        emit Stake(msg.sender, tokenId, block.timestamp);
    }

    /**
     * @notice Unstake staked NFT and obtain erc20 rewards
     * @param tokenId NFT Id
     */
    function unStakeNFT(uint256 tokenId) external onlyNFTOwner(tokenId) {
        UserInfo memory _stake = stakes[tokenId];
        require(stakes[tokenId].owner == msg.sender, "CALLER_NOT_STAKING_OWNER");

        uint256 rewardAmount = calculateRewards(_stake.startTime);
        gameNFT.safeTransferFrom(address(this), msg.sender, tokenId);

        gameToken.mint(msg.sender, rewardAmount);

        emit Unstake(msg.sender, block.timestamp, rewardAmount);
        emit ClaimReward(msg.sender, block.timestamp, rewardAmount);
    }

    /**
     * @notice Claim rewards without unstaking  NFT
     * @param tokenId NFT Id
     */
    function claimRewards(uint256 tokenId) external onlyNFTOwner(tokenId) {
        UserInfo memory _stake = stakes[tokenId];
        require(stakes[tokenId].owner == msg.sender, "CALLER_NOT_STAKING_OWNER");

        uint256 rewardAmount = calculateRewards(_stake.startTime);
        _stake.startTime = block.timestamp;
        stakes[tokenId] = _stake;
        gameToken.mint(msg.sender, rewardAmount);
        emit ClaimReward(msg.sender, block.timestamp, rewardAmount);
    }


    /**
     * @notice set reward per day, only callable by owner
     * @param _rewardAmount account to be sanctioned
     */
    function setRewardPerDay(uint256 _rewardAmount) external onlyOwner {
        uint256 oldRewardAmount = _rewardAmount;
        rewardPerDay = _rewardAmount;
        emit RewardPerDaySet(oldRewardAmount, rewardPerDay);
    }

    /**
     * @notice The calcul is based on 10 tokens every 24 hours
     * @param depositTimestamp Time to start calculation
     * @return The rewards reporteda
     */
    function calculateRewards(uint256 depositTimestamp) public view returns(uint256) {
        uint256 _timeSinceDeposit = block.timestamp - depositTimestamp;
        uint256 _calculatedRewards = (_timeSinceDeposit * rewardPerDay) / 1 days;
        return _calculatedRewards;
    }

    /**
     * @dev accept erc721 from safeTransferFrom and safeMint after callback
     * @return returns received selector
     */
    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {
        require(address(gameNFT) == msg.sender, "CALLER_NOT_NFT_CONTRACT");
        stakes[tokenId] = UserInfo(operator, block.timestamp);
        return this.onERC721Received.selector;
    }
}