// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";


error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 1e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address _priceFeedAddress){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You did not send enough ETH");  // 1e18 = 1 ETH = 1000000000000000000

        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);

        // Reverts undo any actions that have been done, and send the remaining gas back

    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        // for loop
        // for(/* starting index, ending index, step amount */)
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        // actually withdraw the funds

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        // require(msg.sender == i_owner, "You are not the owner of this contract");
        if (msg.sender != i_owner) { revert("You are not the owner of this contract"); }
        _;
        // _; // This means run the rest of the code
    }

    fallback() external payable {
        fund();
      }

    receive() external payable {
        fund();
     }

     /**
      * View / Pure functions (Getters)
      */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFundeder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    
}