// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

/**
User can lock accepted ERC20 token in to this contract.
When locking token, user can not lock more
*/

contract SimpleLockPool is
Initializable,
OwnableUpgradeable,
ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;
    using SafeCastUpgradeable for uint256;

    struct LockingData {
        uint256 balance;
        uint256 vested;
        uint128 joinTime;
        uint128 lockingDuration;
        uint128 vestingDuration;
    }

    // Accepted token
    IERC20 public acceptedToken;

    // Default locking duration
    uint128 public defaultLockingDuration;

    // Default vesting duration
    uint128 public defaultVestingDuration;

    // Info of each user that currently locking
    mapping(address => LockingData) public lockingData;

    // List of operator (locking for other wallet)
    mapping(address => bool) public operator;

    // Allow emergency transfer feature
    mapping(address => address) public targetEmergencyTransfer;

    event Lock(address indexed account, uint256 amount);

    event ClaimVesting(address indexed account, uint256 amount);

    event EmergencyTransfer(
        address indexed account,
        address recipient,
        uint256 amount
    );

    /**
     * @notice Initialize the contract, get called in the first time deploy
     * @param _acceptedToken the token that the pools will use as staking and reward token
     */
    function __LockPool_init(IERC20 _acceptedToken) public initializer {
        __Ownable_init();

        acceptedToken = _acceptedToken;
        defaultLockingDuration = 180 days;
        defaultVestingDuration = 180 days;
    }

    function setOperator(address _account, bool _isOperator)
    external
    onlyOwner
    {
        operator[_account] = _isOperator;
    }

    function setDefaultLockingDuration(uint128 _duration) external onlyOwner {
        defaultLockingDuration = _duration;
    }

    function setDefaultVestingDuration(uint128 _duration) external onlyOwner {
        defaultVestingDuration = _duration;
    }

    /**
     * @notice Lock token into the contract
     * @param _amount amount of token to lock
     */
    function lock(uint128 _amount) external nonReentrant {
        LockingData storage accountData = lockingData[msg.sender];

        if (accountData.joinTime > 0) {
            require(
                accountData.joinTime + accountData.lockingDuration >
                block.timestamp.toUint128(),
                "Can't lock during vesting duration"
            );
        }

        accountData.balance += _amount;
        accountData.joinTime = block.timestamp.toUint128();
        accountData.lockingDuration = defaultLockingDuration;
        accountData.vestingDuration = defaultVestingDuration;

        acceptedToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Lock(msg.sender, _amount);
    }

    /**
     * @notice Operator can lock token for other into the contract
     * @param _amount amount of token to lock
     */
    function lockFor(address _account, uint128 _amount) external nonReentrant {
        require(operator[msg.sender], "Not allowed");

        LockingData storage accountData = lockingData[_account];

        if (accountData.joinTime > 0) {
            require(
                accountData.joinTime + accountData.lockingDuration >
                block.timestamp.toUint128(),
                "Can't lock during vesting duration"
            );
        }

        accountData.balance += _amount;
        accountData.joinTime = block.timestamp.toUint128();
        accountData.lockingDuration = defaultLockingDuration;
        accountData.vestingDuration = defaultVestingDuration;

        acceptedToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Lock(_account, _amount);
    }

    /**
 * @notice Claim vesting token from a pool
     */
    function claimVesting() external nonReentrant {
        LockingData storage accountData = lockingData[msg.sender];

        require(accountData.balance > 0, "Nothing to claim");

        uint128 endLockingTime = accountData.joinTime +
        accountData.lockingDuration;
        require(block.timestamp.toUint128() > endLockingTime, "Still locked");

        uint256 unlocked = ((block.timestamp.toUint128() - endLockingTime) *
        accountData.balance) / accountData.vestingDuration;

        if (unlocked > accountData.balance) {
            unlocked = accountData.balance;
        }

        uint256 claimable = unlocked - accountData.vested;
        accountData.vested += claimable;

        if (accountData.vested >= accountData.balance) {
            delete lockingData[msg.sender];
        }

        acceptedToken.safeTransfer(msg.sender, claimable);
        emit ClaimVesting(msg.sender, claimable);
    }
}
