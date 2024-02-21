// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserManagementContract {
    struct User {
        string username;
        uint256 age;
        bool isActive;
    }

    mapping(address => User) private users;
    address[] private userAddresses;

    event UserAdded(address indexed userAddress, string username, uint256 age);
    event UserRemoved(address indexed userAddress);
    event UserUpdated(address indexed userAddress, string newUsername, uint256 newAge);

    function addUser(string calldata username, uint256 age) external {
        require(bytes(username).length > 0, "Username cannot be empty");
        require(age > 0, "Age must be greater than 0");

        address userAddress = msg.sender;

        require(users[userAddress].age == 0, "User already exists");

        User memory newUser = User(username, age, true);
        users[userAddress] = newUser;
        userAddresses.push(userAddress);

        emit UserAdded(userAddress, username, age);
    }

    function removeUser() external {
        address userAddress = msg.sender;
        require(users[userAddress].age > 0, "User does not exist");

        delete users[userAddress];

        // Find and remove user address from the array
        for (uint256 i = 0; i < userAddresses.length; i++) {
            if (userAddresses[i] == userAddress) {
                userAddresses[i] = userAddresses[userAddresses.length - 1];
                userAddresses.pop();
                break;
            }
        }

        emit UserRemoved(userAddress);
    }

    function getUser(address userAddress) external view returns (string memory, uint256, bool) {
        User memory user = users[userAddress];
        require(user.age > 0, "User does not exist");

        return (user.username, user.age, user.isActive);
    }

    function getAllUsers() external view returns (address[] memory) {
        return userAddresses;
    }

    function updateUser(string calldata newUsername, uint256 newAge) external {
        address userAddress = msg.sender;
        User storage user = users[userAddress];
        require(user.age > 0, "User does not exist");

        require(bytes(newUsername).length > 0, "New username cannot be empty");
        require(newAge > 0, "New age must be greater than 0");

        user.username = newUsername;
        user.age = newAge;

        emit UserUpdated(userAddress, newUsername, newAge);
    }
}
