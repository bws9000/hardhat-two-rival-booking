//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract TwoRivalBooking {

    event UserRegistered(bool status);
    event RoomBooked(uint8 roomNum, uint8 hour);
    event RegistrationCleared(bool status);

    address facilitator;
    address[] ActiveUsers;
    
    string groupA;
    string groupB;
    uint256 totalRegistered;
    uint256 totalBooked;
    uint8 roomLimit;

    mapping(uint8 => mapping(address => uint8[24])) groupABooking;
    mapping(uint8 => mapping(address => uint8[24])) groupBBooking;
    
    mapping(address => bool) registeredUsers;
    mapping(address => string) userToGroup;

    constructor() {
        facilitator = msg.sender;
        groupA = "P";
        groupB = "C";
        roomLimit = 10;
    }

    function registerUser(string calldata _group) external {
        if(registeredUsers[msg.sender]){
            revert("you have already registered");
        }
        if( keccak256(bytes(_group)) != keccak256(bytes(groupA)) && 
        keccak256(bytes(_group)) != keccak256(bytes(groupB))){
            revert("group does not exist");
        }

        bool unique = true;
        for(uint8 i=0;i<ActiveUsers.length;i++){
            if(ActiveUsers[i] == msg.sender){
                unique = false;
            }
        }
        if(unique){
            ActiveUsers.push(msg.sender);
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
         --totalRegistered;
         emit RegistrationCleared(true);
    }

    function bookRoom(uint8 hour, uint8 roomNum) external {
        require(registeredUsers[msg.sender], "you have to register before booking room");
        require(roomNum <= roomLimit && roomNum >= 1, "room doesn't exist");
        string memory _group = userToGroup[msg.sender];
        if(keccak256(bytes(_group)) == keccak256(bytes(groupA))){
            uint8[24] memory h = groupABooking[roomNum][msg.sender];
            require(h[hour] == 0, "you already booked this hour");
            h[hour] += 1;
            groupABooking[roomNum][msg.sender] = h;
        }else{
            uint8[24] memory h = groupBBooking[roomNum][msg.sender];
            require(h[hour] == 0, "you already booked this hour");
            h[hour] += 1;
            groupBBooking[roomNum][msg.sender] = h;
        }
        registeredUsers[msg.sender] = true;
        ++totalBooked;
        emit RoomBooked(roomNum, hour);
    }

    function getRoom(uint8 roomNum, string calldata _group) external view returns(uint8[24] memory){

        uint8[24] memory _hours_out;

        for(uint8 i=0; i < ActiveUsers.length;) {      
            address addr = ActiveUsers[i];          
            if(registeredUsers[addr]){

                   uint8[24] memory _hours;
                   if(keccak256(bytes(_group)) == keccak256(bytes(groupA))){
                       _hours = groupABooking[roomNum][addr];
                   }else{
                       _hours = groupBBooking[roomNum][addr];
                   }
                   for(uint8 z = 0;z< 24;z++){
                        _hours_out[z] += _hours[z];
                   }

            }
            i++;
        }
        return _hours_out;
    }

    function checkIfAlreadyBooked(string memory _group, uint8 hour, uint8 roomNum, address addr) internal view returns(bool){
        bool result = false;
        if(keccak256(bytes(_group)) == keccak256(bytes(groupA))){
            uint8[24] memory h = groupABooking[roomNum][addr];
            if(h[hour] < 1){ result = true; }
        }else{
            uint8[24] memory h = groupBBooking[roomNum][addr];
            if(h[hour] > 0){ result = true; }
        }
        return result;
    }

    function totalBookings() external view returns(uint256){
        return totalBooked;
    }

}