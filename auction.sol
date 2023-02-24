// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Auction{

    address payable public auctioneer;

    enum AuctionState{running,ended,cancelled}

    mapping(address=>uint) biddersData;
    uint public highestBidAmount;
    address payable public  highestBidder;
    uint numberOfBids=0;
  
    AuctionState public auctionState;

    uint startTime;
    uint endTime;

    constructor(uint _endTime){
        auctioneer=payable(msg.sender);
        auctionState=AuctionState.running;
        startTime=block.timestamp;
        endTime=_endTime;
    }

    // modifiers
    modifier owner(){
        require(msg.sender==auctioneer,"Only allowed by owner");
        _;
    }

    modifier notOwner(){
        require(msg.sender!=auctioneer,"Auctioneer can't do this on their own auction");
        _;
    }

    modifier bidder(){
        require(biddersData[msg.sender]>0,"You must be a bidder to do this");
        _;
    }



    // get Contract Balace
    function getContractBalance() public view owner returns(uint){
        return address(this).balance;
    }

    // get the bidder's bid
     function getBiddersBid(address _address) public view owner returns(uint){
        return biddersData[_address];
    }


    // get number of bids
    function getNumberOfBids() public view owner returns(uint){
        return numberOfBids;
    }

    // function to cancel auction
    function cancelAuction() public owner{
        auctionState=AuctionState.cancelled;
    }

    // to check bidder's bid
    function getYourBid() public view notOwner bidder returns(uint){
        return biddersData[msg.sender];
    }


    // function to change endtime
    function changeEndTime(uint _endTime) public owner {
        endTime=_endTime;
    }

    // function to end the Auction explicitly(testing Only)
    // function endAuctionEarly() public owner{
    //     auctionState=AuctionState.ended;
    //     endTime=block.timestamp;
    // }



    // function new bid
    function putBid() payable public notOwner {
        
        require(block.timestamp>=startTime,"Auction has not started yet");
        require(block.timestamp<=endTime,"Auction is Ended");
        require(auctionState==AuctionState.running,"Auction state is not running");
        require(msg.value>0,"Bid amount must be greater than zero");


        uint newAmount=biddersData[msg.sender]+msg.value;
        require(newAmount>highestBidAmount,"New Bid should be greater than current highest bid");


        biddersData[msg.sender]=newAmount;
        highestBidder=payable(msg.sender);
        highestBidAmount=newAmount;
        numberOfBids++;
    }

    // function to withdraw money
    function withdrawMoney() public {
        require(auctionState!=AuctionState.running||block.timestamp>endTime,"Auction is running");
        require(msg.sender==auctioneer||biddersData[msg.sender]>0,"Invalid User");
        

        address payable person;
        uint value;
       if(auctionState==AuctionState.cancelled){
            person=payable(msg.sender);
            value=biddersData[msg.sender];
       }
       else{
           if(msg.sender==auctioneer){
               person=payable(msg.sender);
               value=highestBidAmount;
           }else{
               require(msg.sender!=highestBidder,"You have won the auction, money has been given to auctioneer");
                person=payable(msg.sender);
                value=biddersData[msg.sender];
           }
       }

    person.transfer(value);

    }
}
