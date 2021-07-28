// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";

contract dBank {

    Token private token;

    mapping(address => uint) public etherBalanceOf;
    mapping(address => uint) public depositStart;
    mapping(address => bool) public isDeposited;

    event Deposited(address indexed user, uint etherAmount, uint timeStart);
    event Withdrawn(address indexed user, uint etherAmount, uint depositTime, uint interest);

    constructor(Token _token) {
        token = _token;
    }

    function deposit() payable public {
        require(isDeposited[msg.sender] == false, 'Error, deposit already active');
        require(msg.value >= 1e16, 'Error, deposit must ne >= 0.01 ETH');

        etherBalanceOf[msg.sender] = etherBalanceOf[msg.sender] + msg.value;
        depositStart[msg.sender] = depositStart[msg.sender] + block.timestamp;
        isDeposited[msg.sender] = true;
        emit Deposited(msg.sender, msg.value, block.timestamp);

    }

    function withdraw() public {
        payable(msg.sender).transfer(etherBalanceOf[msg.sender]);
        uint userBalance = etherBalanceOf[msg.sender];

        uint depositTime = block.timestamp - depositStart[msg.sender];
        //     31668017 - interest(10% APY) per second for min deposit aount (0.01 ETH)
        //    1e15(10% of 0.01 ETH) / 3157760 (seconds in 365.25 days)

        uint interestPerSecond = 31668017 * (etherBalanceOf[msg.sender] / 1e16);
        uint interest = interestPerSecond * depositTime;

        //        msg.sender.transfer(etherBalanceOf[msg.sender]);
        //        payable(msg.sender).transfer(etherBalanceOf[msg.sender]);


        payable(msg.sender).transfer(etherBalanceOf[msg.sender]);
        token.mint(msg.sender, interest);
        // interest to user

        etherBalanceOf[msg.sender] = 0;
        depositStart[msg.sender] = 0;
        isDeposited[msg.sender] = false;

        emit Withdrawn(msg.sender, userBalance, depositTime, interest);

    }
}