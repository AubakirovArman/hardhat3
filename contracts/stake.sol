// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract USDT is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() ERC20("USDT", "USDT")  {
        _mint(msg.sender, 1000000000000000000000000);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}


contract YourToken is ERC20, AccessControl  {
      bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() ERC20("YouToken", "YouToken")  {
        _mint(msg.sender, 1000000000000000000000000);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}

contract Staking is Ownable {
    IERC20  private usdt;
    IERC20  private yourToken;
    uint public totalStaked;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint) public lastClaimedTime;

    constructor(address _usdt, address _yourToken) {
        usdt = USDT(_usdt);
        yourToken = YourToken(_yourToken);
    }

    function BuyToken(uint _usdtAmount) public payable {
        usdt.approve(msg.sender,_usdtAmount);
        usdt.transferFrom(msg.sender, address(this), _usdtAmount);
        uint tokenAmount = calculateTokenAmount(_usdtAmount);
        yourToken.transfer(msg.sender, tokenAmount);
        stake(tokenAmount);
    }

    function stake(uint _tokenAmount) private {
        stakedBalance[msg.sender] += _tokenAmount;
        totalStaked += _tokenAmount;
        lastClaimedTime[msg.sender] = block.timestamp;
    }

    function claim() public {
        uint timePassed = block.timestamp - lastClaimedTime[msg.sender];
        uint stakedAmount = stakedBalance[msg.sender];
        uint yourTokenBalance = yourToken.balanceOf(address(this));
        uint reward = calculateReward(stakedAmount, timePassed);
        require(reward <= yourTokenBalance, "Insufficient balance in the contract");
        yourToken.transfer(msg.sender, reward);
        lastClaimedTime[msg.sender] = block.timestamp;
    }

    function withdraw() public {
        uint stakedAmount = stakedBalance[msg.sender];
        require(stakedAmount > 0, "No staked amount to withdraw");
        stakedBalance[msg.sender] = 0;
        totalStaked -= stakedAmount;
        yourToken.transfer(msg.sender, stakedAmount);
    }

    function calculateTokenAmount(uint _usdtAmount) private pure returns(uint) {
        return _usdtAmount;
    }

    function calculateReward(uint _stakedAmount, uint _timePassed) private pure returns(uint) {
        uint annualInterestRate = 10; // 10% годовых
        uint secondsInYear = 10; // Количество секунд в году
        uint reward = _stakedAmount * annualInterestRate * _timePassed / secondsInYear / 100;
        require(reward >= _stakedAmount, "Multiplication overflow");
        return reward;
    }
}