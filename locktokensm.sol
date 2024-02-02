// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract JointLockupContract is Pausable, Ownable {
    using SafeERC20 for IERC20;

    // Swan token contract
    IERC20 public swanToken;

    // Addresses of participants
    address public participant1;
    address public participant2;

    // Flag to track whether tokens have been unlocked
    bool public unlocked = false;

    // Event emitted when tokens are locked
    event TokensLocked(address indexed participant1, address indexed participant2);

    // Event emitted when tokens are unlocked
    event TokensUnlocked(address indexed participant1, address indexed participant2, uint256 amount);

    // Modifier to restrict access to only participants
    modifier onlyParticipants() {
        require(msg.sender == participant1 || msg.sender == participant2, "Not a participant");
        _;
    }

    // Constructor to initialize the contract
    constructor(
        address _swanToken,
        address _participant1,
        address _participant2
    ) Ownable(msg.sender) {
        // Validate input parameters
        require(_swanToken != address(0), "address");
        require(_participant1 != address(0) && _participant2 != address(0), "address");
        require(_participant1 != _participant2, "address");

        // Initialize contract state variables
        swanToken = IERC20(_swanToken);
        participant1 = _participant1;
        participant2 = _participant2;

        // Emit event indicating tokens are locked
        emit TokensLocked(participant1, participant2);
    }

    // Function to lock tokens
    function lockTokens(uint256 amount) external onlyParticipants whenNotPaused {
        // Ensure tokens are not already unlocked
        require(!unlocked, "Tokens are already unlocked");

        // Transfer tokens from the sender to the contract
        swanToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    // Function to unlock tokens (onlyOwner can call this)
    function unlockTokens() external onlyOwner whenNotPaused {
        // Ensure tokens have not been unlocked
        require(!unlocked, "Tokens already unlocked");

        // Calculate total locked tokens
        uint256 totalLocked = swanToken.balanceOf(address(this));
        require(totalLocked > 0, "No tokens to unlock");

        // Calculate unlock amount for each participant (50-50 split)
        uint256 unlockAmount = totalLocked / 2;

        // Transfer tokens to participants
        swanToken.safeTransfer(participant1, unlockAmount);
        swanToken.safeTransfer(participant2, unlockAmount);

        // Mark tokens as unlocked
        unlocked = true;

        // Emit event indicating tokens are unlocked
        emit TokensUnlocked(participant1, participant2, unlockAmount * 2);
    }
}
//not test
