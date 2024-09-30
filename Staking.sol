// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns(address){
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata){
        return msg.data;
    }
}

interface IERC20 {
    event Transfer (address indexed from,address indexed to , uint256 value);

    event Approval (address indexed owner, address indexed spender, uint256 value);

    function transfer(address to,uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve (address spender,uint256 amount) external returns (bool);

    function transferFrom (address from,address to,uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );

        if (isTopLevelCall) {
            _initializing = true;
        }
        _initialized = 1;
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(){
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner(){
        _checkOwner();
        _;
    }

    function owner() public view virtual returns(address){
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership (address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor(){
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require (_status != _ENTERED,"ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
    }
}

contract SID {

    string public name = "@sidharth";
    string public symbol = "SID";
    uint256 public totalSupply;
    address public ownerOfContract;
    uint256 public _userId;

    uint256 constant initialSupply = 10000 * (10**18);

    address[] public holderToken;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping (address => TokenHolderInfo) public tokenHolderInfos;

    struct TokenHolderInfo {
        uint256 _tokenId;
        address _from;
        address _to;
        uint256 _totalToken;
        bool _tokenHolder;
    }

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor () {
        ownerOfContract = msg.sender;
        balanceOf[msg.sender] = initialSupply;
        totalSupply = initialSupply;
    }

    function inc() internal {
        _userId++;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        inc();

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        TokenHolderInfo storage tokenHolderInfo = tokenHolderInfos[_to];

        tokenHolderInfo._to = _to;
        tokenHolderInfo._from = msg.sender;
        tokenHolderInfo._totalToken = _value;
        tokenHolderInfo._tokenHolder = true;
        tokenHolderInfo._tokenId = _userId;

        holderToken.push(_to);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function getTokenHolderData(address _address) public view returns(uint256, address, address, uint256, bool) {
        TokenHolderInfo storage tokenHolderInfo = tokenHolderInfos[_address];
        return (
            tokenHolderInfo._tokenId,
            tokenHolderInfo._to,
            tokenHolderInfo._from,
            tokenHolderInfo._totalToken,
            tokenHolderInfo._tokenHolder
        );
    }

    function getTokenHolder() public view returns (address[] memory) {
        return holderToken;
    }
}

contract TokenStaking is Ownable, ReentrancyGuard, Initializable {

    struct User {
        uint256 stakedAmount;
        uint256 rewardAmount;
        uint256 lastStakeTime;
        uint256 lastRewardCalculationTime;
        uint256 rewardClaimedSoFar;
    }

    uint256 _minimumStakingAmount;
    uint256 _maxStakeTokenLimit;
    uint256 _stakeEndDate;
    uint256 _stakeStartDate;
    uint256 _totalStakedTokens;
    uint256 _totalUsers;
    uint256 _stakeDays;
    uint256 _earlyUnstakeFeePercentage;
    bool _isStakingPaused;

    address private _tokenAddress;

    uint256 _apyRate;

    uint256 public constant PERCENTAGE_DENOMINATOR = 10000;
    uint256 public constant APY_RATE_CHANGE_THRESHOLD = 10;

    mapping (address => User) private _users;

    event Stake(address indexed user, uint256 amount);
    event UnStake(address indexed user, uint256 amount);
    event EarlyUnstakeFee(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);

    modifier whenTreasuryHasBalance(uint256 amount) {
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= amount, "TokenStaking: insufficient balance");
        _;
    }

    function initialize(address owner_, address tokenAddress_, uint256 apyRate_, uint256 minimumStakingAmount_, uint256 maxStakeTokenLimit_, uint256 stakeStartDate_, uint256 stakeEndDate_, uint256 stakeDays_, uint256 earlyUnstakeFeePercentage_) public virtual initializer {
        _TokenStaking_init_unchained(
            owner_,
            tokenAddress_,
            apyRate_,
            minimumStakingAmount_,
            maxStakeTokenLimit_,
            stakeStartDate_,
            stakeEndDate_,
            stakeDays_,
            earlyUnstakeFeePercentage_
        );
    }

    function _TokenStaking_init_unchained(
        address owner_,
        address tokenAddress_,
        uint256 apyRate_,
        uint256 minimumStakingAmount_,
        uint256 maxStakeTokenLimit_,
        uint256 stakeStartDate_,
        uint256 stakeEndDate_,
        uint256 stakeDays_,
        uint256 earlyUnstakeFeePercentage_
    ) internal onlyInitializing {
        require(apyRate_ <= 10000, "TokenStaking: apy rate should be less than 10000");
        require(stakeDays_ > 0, "TokenStaking: stake days should be greater than 0");
        require(stakeStartDate_ < stakeEndDate_, "TokenStaking: start date must be less than end date");

        _transferOwnership(owner_);
        _tokenAddress = tokenAddress_;
        _apyRate = apyRate_;
        _minimumStakingAmount = minimumStakingAmount_;
        _maxStakeTokenLimit = maxStakeTokenLimit_;
        _stakeStartDate = stakeStartDate_;
        _stakeEndDate = stakeEndDate_;
        _stakeDays = stakeDays_ * 1 days;
        _earlyUnstakeFeePercentage = earlyUnstakeFeePercentage_;
    }

    /* View Methods Start */

    function getMinimumStakingAmount() external view returns (uint256) {
        return _minimumStakingAmount;
    }

    function getMaximumStakingTokenLimit() external view returns (uint256) {
        return _maxStakeTokenLimit;
    }

    function getStakeStartDate() external view returns (uint256) {
        return _stakeStartDate;
    }

    function getStakeEndDate() external view returns (uint256) {
        return _stakeEndDate;
    }

    function getTotalStakedTokens() external view returns (uint256) {
        return _totalStakedTokens;
    }

    function getTotalUsers() external view returns (uint256) {
        return _totalUsers;
    }

    function getStakeDays() external view returns (uint256) {
        return _stakeDays;
    }

    function getEarlyUnstakeFeePercentage() external view returns (uint256) {
        return _earlyUnstakeFeePercentage;
    }

    function getStatus() external view returns (bool) {
        return _isStakingPaused;
    }

    function getAPY() external view returns (uint256) {
        return _apyRate;
    }

    function getUserEstimatedRewards(address user) external view returns (uint256) {
        (uint256 amount,) = _getUserEstimatedRewards(user);
        return _users[user].rewardAmount + amount;
    }

    function _getWithdrawableAmount() external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this)) - _totalStakedTokens;
    }

    function getUser(address userAddress) external view returns (User memory) {
        return _users[userAddress];
    }

    function isStakeHolder(address user) external view returns (bool) {
        return _users[user].stakedAmount != 0;
    }

    /* Update Methods Start */

    function updateMinimumStakingAmount(uint256 newAmount) external onlyOwner {
        _minimumStakingAmount = newAmount;
    }

    function updateMaximumStakingAmount(uint256 newAmount) external onlyOwner {
        _maxStakeTokenLimit = newAmount;
    }

    function updateStakingEndDate(uint256 newDate) external onlyOwner {
        _stakeEndDate = newDate;
    }

    function updateUnstakeFeePercentage(uint256 newPercentage) external onlyOwner {
        _earlyUnstakeFeePercentage = newPercentage;
    }

    /* Staking and Unstaking Methods Start */

    function stakeForUser(uint256 amount, address user) external onlyOwner nonReentrant {
        _stakeTokens(amount, user);
    }

    function toggleStakingStatus() external onlyOwner {
        _isStakingPaused = !_isStakingPaused;
    }

    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        require(this._getWithdrawableAmount() >= amount, "TokenStaking: not enough withdrawable tokens");
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }

    function stake(uint256 amount) external nonReentrant {
        _stakeTokens(amount, msg.sender);
    }

    function _stakeTokens(uint256 amount, address user) private {
        require(!_isStakingPaused, "TokenStaking: staking is paused");
        uint256 currentTime = getCurrentTime();
        require(currentTime > _stakeStartDate, "TokenStaking: staking not started yet");
        require(currentTime < _stakeEndDate, "TokenStaking: staking ended");
        require(_totalStakedTokens + amount <= _maxStakeTokenLimit, "TokenStaking: max staking limit reached");
        require(amount > 0, "TokenStaking: stake amount must be non-zero");
        require(amount >= _minimumStakingAmount, "TokenStaking: stake amount must be greater than minimum amount allowed");

        if (_users[user].stakedAmount != 0) {
            _calculateRewards(user);
        } else {
            _users[user].lastRewardCalculationTime = currentTime;
            _totalUsers += 1;
        }

        _users[user].stakedAmount += amount;
        _users[user].lastStakeTime = currentTime;

        _totalStakedTokens += amount;

        require(IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount), "TokenStaking: failed to transfer tokens");
        emit Stake(user, amount);
    }

    function unstake(uint256 amount) external nonReentrant whenTreasuryHasBalance(amount) {
        address user = msg.sender;
        require(amount != 0, "TokenStaking: amount should be non-zero");
        require(_users[user].stakedAmount != 0, "TokenStaking: not a stakeholder");
        require(_users[user].stakedAmount >= amount, "TokenStaking: not enough stake to unstake");

        _calculateRewards(user);
        uint256 feeEarlyUnstake;

        if (getCurrentTime() <= _users[user].lastStakeTime + _stakeDays) {
            feeEarlyUnstake = (amount * _earlyUnstakeFeePercentage) / PERCENTAGE_DENOMINATOR;
            emit EarlyUnstakeFee(user, feeEarlyUnstake);
        }

        uint256 amountToUnstake = amount - feeEarlyUnstake;

        _users[user].stakedAmount -= amount;

        if (_users[user].stakedAmount == 0) {
            _totalUsers -= 1;
        }

        require(IERC20(_tokenAddress).transfer(user, amountToUnstake), "TokenStaking: failed to transfer");
        emit UnStake(user, amount);
    }

    function claimReward() external nonReentrant whenTreasuryHasBalance(_users[msg.sender].rewardAmount) {
        _calculateRewards(msg.sender);
        uint256 rewardAmount = _users[msg.sender].rewardAmount;
        require(rewardAmount > 0, "TokenStaking: no reward to claim");
        require(IERC20(_tokenAddress).transfer(msg.sender, rewardAmount), "TokenStaking: failed to transfer");

        _users[msg.sender].rewardAmount = 0;
        _users[msg.sender].rewardClaimedSoFar += rewardAmount;

        emit ClaimReward(msg.sender, rewardAmount);
    }

    function _calculateRewards(address user) private {
        (uint256 userReward, uint256 currentTime) = _getUserEstimatedRewards(user);

        _users[user].rewardAmount += userReward;
        _users[user].lastRewardCalculationTime = currentTime;
    }

    function _getUserEstimatedRewards(address user) private view returns (uint256, uint256) {
        uint256 userReward;
        uint256 userTimestamp = _users[user].lastRewardCalculationTime;

        uint256 currentTime = getCurrentTime();

        if (currentTime > _users[user].lastStakeTime + _stakeDays) {
            currentTime = _users[user].lastStakeTime + _stakeDays;
        }

        uint256 totalStakedTime = currentTime - userTimestamp;
        userReward += (totalStakedTime * _users[user].stakedAmount * _apyRate) / 365 days / PERCENTAGE_DENOMINATOR;

        return (userReward, currentTime);
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}