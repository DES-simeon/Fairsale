pragma solidity 0.4.4;

contract Fairsale {
    address public owner;
    uint public finalblock;
    uint public target;
    uint public raised;
    bool funded;
    mapping(address => uint) public balances;
    mapping(address => bool) public refunded;

    event TargetHit(uint amountRaised);
    event CrowdsaleClosed(uint amountRaised);
    event FundTransfer(address backer, uint amount);
    event Refunded(address backer, uint amount);

    function BrancheProportionalCrowdsale(uint _durationInMinutes, uint _targetETH) {
        owner = msg.sender;
        deadline = now + _durationInMinutes * 1 minutes;
        target = _targetETH * 1 ether;
    }

    function _deposit() private {
        if (now >= deadline) throw;
        balances[msg.sender] += msg.value;
        raised += msg.value;
        FundTransfer(msg.sender, msg.value);
    }

    function deposit() payable {
        _deposit();
    }

    function() payable {
        _deposit();
    }

    function withdrawRefund() {
        if (now <= deadline) throw;
        if (raised <= target) throw;
        if (refunded[msg.sender]) throw;

        uint deposit = balances[msg.sender];
        uint keep = (deposit * target) / raised;
        uint refund = deposit - keep;
        if (refund > this.balance) refund = this.balance;

        refunded[msg.sender] = true;
        Refunded(msg.sender, refund);
        if (!msg.sender.call.value(refund)()) throw;
    }

    function fundOwner() {
        if (block.number <= finalblock) throw;
        if (funded) throw;
        funded = true;
        CrowdsaleClosed(raised);
        if (raised < target) {
            if (raised > this.balance) raised = this.balance;
            if (!owner.call.value(raised)()) throw;
        } else {
            TargetHit(raised);
            if (target > this.balance) target = this.balance;
            if (!owner.call.value(target)()) throw;
        }
    }
}
