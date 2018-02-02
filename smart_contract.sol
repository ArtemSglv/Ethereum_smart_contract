pragma solidity ^0.4.11;

contract Owned {

    address public owner;

    function owned() public payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        owner = _owner;
    }
}

contract Crowdsale is Owned {
    
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function Crowdsale() public payable Owned() {
        totalSupply = 21000000;
        balanceOf[this] = 20000000;
        balanceOf[owner] = totalSupply - balanceOf[this];
        Transfer(this, owner, balanceOf[owner]);
    }

    function () public payable {
        require(balanceOf[this] > 0);
        uint256 tokensPerOneEther = 5000;
        uint256 tokens = tokensPerOneEther * msg.value / 1000000000000000000;
        if (tokens > balanceOf[this]) {
            tokens = balanceOf[this];
            uint valueWei = tokens * 1000000000000000000 / tokensPerOneEther;
            msg.sender.transfer(msg.value - valueWei);
        }
        require(tokens > 0);
        balanceOf[msg.sender] += tokens;
        balanceOf[this] -= tokens;
        Transfer(this, msg.sender, tokens);
    }
}

contract EasyToken is Crowdsale {
    
    string  public standard    = "Token 0.1";
    string  public name        = "EasyTokens";
    string  public symbol      = "ETN";
    uint8   public decimals    = 0;

    function EasyToken() public payable Crowdsale() {}

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
}

contract EasyCrowdsale is EasyToken {

    function EasyCrowdsale() public payable EasyToken() {}
    
    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }
}