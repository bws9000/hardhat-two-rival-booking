//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract TwoRivalBooking {

    event UserRegistered(bool status);
    event RoomBooked(uint8 roomNum, uint8 hour);
    event RegistrationCleared(bool status);

    address facilitator;
    
    string groupA;
    string groupB;
    uint8 groupSize;

    uint256 public totalRegistered;
    mapping(address => mapping(uint8 => uint8[24] )) groupABooking;
    mapping(address => mapping(uint8 => uint8[24])) groupBBooking;
    
    address[] ActiveUsers;
    
    mapping(address => bool) registeredUsers;
    mapping(address => string) userToGroup;

    constructor() {
        facilitator = msg.sender;
        groupA = "P";
        groupB = "C";
    }

    function registerUser(string calldata _group) external {
        if(registeredUsers[msg.sender]){
            revert("you have already registered");
        }
        if( keccak256(bytes(_group)) != keccak256(bytes(groupA)) && 
        keccak256(bytes(_group)) != keccak256(bytes(groupB))){
            revert("group does not exist");
        }
        registeredUsers[msg.sender] = true;
        userToGroup[msg.sender] = _group;
        ++totalRegistered;
        emit UserRegistered(true);
    }

    function registrationStatus() external view returns(bool) {
        return registeredUsers[msg.sender];
    }

    function clearRegistration() external {
         require(registeredUsers[msg.sender], "you're not currently registered");
         registeredUsers[msg.sender] = false;
         emit RegistrationCleared(true);
    }

    function bookRoom(uint8 hour, uint8 roomNum) external {
        require(registeredUsers[msg.sender], "you have to register before booking room");
        string memory _group = userToGroup[msg.sender];
        if(keccak256(bytes(_group)) == keccak256(bytes(groupA))){
            uint8[24] memory h = groupABooking[msg.sender][roomNum];
            require(h[hour] == 0, "you already booked this hour");
            h[hour] += 1;
            groupABooking[msg.sender][roomNum] = h;
        }else{
            uint8[24] memory h = groupBBooking[msg.sender][roomNum];
            require(h[hour] == 0, "you already booked this hour");
            h[hour] += 1;
            groupBBooking[msg.sender][roomNum] = h;
        }
        address user = msg.sender;
        ActiveUsers.push(user);
        emit RoomBooked(roomNum, hour);
    }

    function checkIfAlreadyBooked(string memory _group, 
    uint8 hour, uint8 roomNum, address addr) internal view returns(bool){
        bool result = false;
        if(keccak256(bytes(_group)) == keccak256(bytes(groupA))){
            uint8[24] memory h = groupABooking[addr][roomNum];
            if(h[hour] < 1){ result = true; }
        }else{
            uint8[24] memory h = groupBBooking[addr][roomNum];
            if(h[hour] > 0){ result = true; }
        }
        return result;
    }

    function totalBookings() external view returns(uint256){
        return ActiveUsers.length;
    }

    function getRoom(uint8 room) external view returns(uint8[24] memory){
        
        string memory _group = userToGroup[msg.sender];
        uint8[24] memory roomsBooked;

        for(uint8 i=0; i < ActiveUsers.length; i++) {      
            address addr = ActiveUsers[i];
            if(keccak256(bytes(_group)) == keccak256(bytes(groupA))){
                roomsBooked = groupABooking[addr][room];
            }else{
                roomsBooked = groupBBooking[addr][room];
            }
        }
        return roomsBooked;
    }

}