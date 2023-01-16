// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ERC20 {
    uint256 public totalSupply;
    string public name;
    string public symbol;
    //address public owner;
    uint public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(
        address indexed AccountOwner,
        address indexed spender,
        uint amount
    );

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor(string memory _name, string memory _symbol, uint _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        //owner = msg.sender;
        balanceOf[msg.sender] += totalSupply;
    }

    function deposit() external payable returns (bool) {
        totalSupply += msg.value;
        balanceOf[msg.sender] += msg.value;
        _mint(msg.sender, msg.value);
        return true;
    }

    function redeem(uint _amount) external returns (bool success) {
        require(
            balanceOf[msg.sender] >= _amount,
            "ERC20: Insufficient funds to redeem"
        );
        payable(msg.sender).transfer(_amount);
        success = _burn(msg.sender, _amount);
    }

    function _burn(address _from, uint _amount) internal returns (bool) {
        require(_from != address(0));
        totalSupply -= _amount; //Will revert if negative number
        balanceOf[_from] -= _amount; //Will revert if negative number
        emit Transfer(_from, address(0), _amount);
        return true;
    }

    function _mint(address _to, uint _amount) internal {
        require(_to != address(0));
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function approve(address _spender, uint _amount) external returns (bool) {
        require(
            _spender != address(0),
            "ERC20: Can't approve to the zero address"
        );
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _to, uint _amount) external returns (bool) {
        return _transfer(msg.sender, _to, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint _amount
    ) external returns (bool) {
        require(
            allowance[_from][msg.sender] >= _amount,
            "ERC20: You can't transfer that amount"
        );
        allowance[_from][msg.sender] -= _amount;
        emit Approval(_from, msg.sender, allowance[_from][msg.sender]);
        return _transfer(_from, _to, _amount);
    }

    function _transfer(
        address _from,
        address _to,
        uint _amount
    ) internal returns (bool) {
        require(_to != address(0), "ERC20: Transfer to the zero address");
        require(balanceOf[_from] >= _amount, "ERC:20 Not enough balance");
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }
}
