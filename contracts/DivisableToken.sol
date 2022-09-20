//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./IterableMapping.sol";

contract Dividends {
    using IterableMapping for IterableMapping.Map;
    IterableMapping.Map private balances;

    string public name = "Divisible Token";
    string public symbol = "DVT";
    uint256 public totalSupply = 1_000_000_000_000_000_000_00;
    uint256 public decimals;
    address public owner;
    mapping(address => uint256) dividendsBalances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        balances.set(msg.sender, 100 ether);
        owner = msg.sender;
        decimals = 18;
    }

    function transfer(address to, uint256 amount) external {
    require(balances.get(msg.sender) >= amount, "Not enough tokens");
    balances.set(msg.sender, balances.get(msg.sender) - amount);
    balances.set(to, balances.get(to) + amount);
    emit Transfer(msg.sender, to, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances.get(account);
    }

    receive() external payable {
        for(uint i = 0; i < balances.size(); i++) {
            address contributor = balances.getKeyAtIndex(i);
            dividendsBalances[contributor] = msg.value * balances.get(contributor) / totalSupply;
        }
    }

    function withdraw() external {
        require(dividendsBalances[msg.sender] > 0, "Not enough tokens");
        payable(msg.sender).transfer(dividendsBalances[msg.sender]);
        dividendsBalances[msg.sender] = 0;
    }

    function checkDividendsBalance() external view returns (uint256){
        return dividendsBalances[msg.sender];
    }
}