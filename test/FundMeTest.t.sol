// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 5e18);        
    }

    function testOwnerIsMsgSender() public view{
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view{
        uint256 version = fundMe.getVersion();
        console.log("Price Feed Version: ", version);
        assertEq(version, 4);
    }
}