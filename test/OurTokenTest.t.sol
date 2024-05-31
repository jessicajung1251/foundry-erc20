// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract OurTokenTest is StdCheats, Test {

    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INTIIAL_ALLOWANCE = 1000;
    uint256 public constant TRANSFER_AMOUNT = 500;
    uint256 public constant APPROVE_AMOUNT = 50 ether;


    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {

        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, INTIIAL_ALLOWANCE);

        vm.prank(alice);
        // if we just do a `transfer` call, whoever is calling this transfer function automatically gets set as the from 
        ourToken.transferFrom(bob, alice, TRANSFER_AMOUNT); 

        assertEq(ourToken.balanceOf(alice), TRANSFER_AMOUNT);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - TRANSFER_AMOUNT);

    }

    function testApprove() public {
        vm.prank(bob);
        ourToken.approve(alice, APPROVE_AMOUNT);

        assertEq(ourToken.allowance(bob, alice), APPROVE_AMOUNT);
    }

    function testTransferFrom() public {
        address receiver = address(0x1);
        vm.prank(msg.sender);
        ourToken.approve(address(this), TRANSFER_AMOUNT);
        ourToken.transferFrom(msg.sender, receiver, TRANSFER_AMOUNT);
        assertEq(ourToken.balanceOf(receiver), TRANSFER_AMOUNT); 

    }

    function testBalanceAfterTransfer() public {
        address receiver = address(0x1);
        uint256 initialBalance = ourToken.balanceOf(msg.sender);
        vm.prank(msg.sender);
        ourToken.transfer(receiver, TRANSFER_AMOUNT);
        assertEq(ourToken.balanceOf(msg.sender), initialBalance - TRANSFER_AMOUNT);
    }

    // function testInitialSupply() public {
    //     assertEq(ourToken.totalSupply(), STARTING_BALANCE);
    //     assertEq(ourToken.balanceOf(msg.sender), STARTING_BALANCE);
    // }

}