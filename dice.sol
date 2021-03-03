// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

contract diceBet{

    mapping(address=>player)private Players;


    address nftAddress = address(this);
    address payable _wallet = address(uint160(nftAddress));
    
    constructor() {
  
        House=house(_wallet,_wallet.balance,msg.sender);
    }
    
    struct player{

        uint bet;
        string name;
        uint256 balance;
        uint8 age;
        bool isLogged;
    }
    
    struct house{
        address payable wallet;
        uint256 balance;
        address payable  HouseAddress;
    }
    uint256 timeRestriction=block.timestamp+2;
    

    house House;
    
    event LogDepositMade(address indexed accountAddress, uint amount);

    
    function isWin() private view returns (bool) {
        return ((uint256(keccak256(abi.encodePacked(block.timestamp*block.difficulty*block.number*timeRestriction+1)))%6+1)>=4);
    }


    function login(string memory  _name, uint8 _age) public {

    require(Players[msg.sender].isLogged==false && msg.sender!=House.HouseAddress) ;
    require(bytes(_name).length<=32 && bytes(_name).length>0);
         Players[msg.sender]=player(
            {
                bet:0,
                balance:Players[msg.sender].balance,
                age: _age,
                name: _name,
                isLogged: true
            }
        );
    }
    

    function RollDice()public {
        require(timeRestriction<=block.timestamp);
        timeRestriction=block.timestamp+2;
        require(Players[msg.sender].isLogged==true && msg.sender!=House.HouseAddress);
        require(Players[msg.sender].balance>=Players[msg.sender].bet && House.balance>=Players[msg.sender].bet) ;

        if(isWin()){
                Players[msg.sender].balance+=Players[msg.sender].bet;
                House.balance-=Players[msg.sender].bet;
            }
        else{
                Players[msg.sender].balance-=Players[msg.sender].bet;
                House.balance+=Players[msg.sender].bet;
        }
    }
    

    function putBet(uint  _betAsWei) public {
        require(Players[msg.sender].isLogged==true && msg.sender!=House.HouseAddress);
        require(_betAsWei<=100000000000000000) ;
        require(_betAsWei>0);
        require(Players[msg.sender].balance>=_betAsWei && House.balance>=_betAsWei) ;
        require(timeRestriction<=block.timestamp);
        Players[msg.sender].bet=_betAsWei;
    }
    
    
    function depositMoney() public payable{
        require(timeRestriction<=block.timestamp);
        timeRestriction=block.timestamp+2;
        require(msg.value>0);
        require(Players[msg.sender].isLogged==true || msg.sender==House.HouseAddress);

        
        emit LogDepositMade(msg.sender,msg.value);

        if(msg.sender==House.HouseAddress){
            House.balance+=msg.value;
        }

        else{ 
            Players[msg.sender].balance+= msg.value;
        }
    }

 
    function withdrawMoney(uint _wei)public payable{
        require(timeRestriction<=block.timestamp);
        timeRestriction=block.timestamp+2;
        require(_wei>0);
        require(Players[msg.sender].isLogged==true || msg.sender==House.HouseAddress);

        if(msg.sender==House.HouseAddress){
            require(_wei<=House.balance);
            House.balance-=_wei;
            emit LogDepositMade(House.wallet,msg.value);
            House.HouseAddress.transfer(_wei);
        }
        else{
            require(_wei<=Players[msg.sender].balance);
            Players[msg.sender].balance-=_wei;
            emit LogDepositMade(House.wallet,msg.value);
            msg.sender.transfer(_wei);
        }
    }
    
    function getBalance() public view returns(uint256) {
        if(msg.sender==House.HouseAddress){ 
            return House.balance;
        }
        else{return Players[msg.sender].balance;}
    }
}