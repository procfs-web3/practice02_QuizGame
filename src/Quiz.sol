// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    Quiz_item[] quiz_list;
    mapping(uint256 => mapping(address => uint256)) public bets;
    uint public vault_balance;
    address owner;

    constructor () {
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        owner = msg.sender;
        bets[0][address(0xdeadbeef)] = 0;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        if (msg.sender != owner) {
            revert("");
        }
        for (uint i = 0; i < quiz_list.length; i++) {
            if (quiz_list[i].id == q.id) {
                revert("");
            }
        }
        quiz_list.push(q);
    }

    function getAnswer(uint quizId) public view returns (string memory){
        for (uint i = 0; i < quiz_list.length; i++) {
            if (quiz_list[i].id == quizId) {
                return quiz_list[i].answer;
            }
        }
        return "";
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        for (uint i = 0; i < quiz_list.length; i++) {
            if (quiz_list[i].id == quizId) {
                Quiz_item memory q;
                q = quiz_list[i];
                q.answer = "";
                return q;
            }
        }
    }

    function getQuizNum() public view returns (uint){
        return quiz_list.length;
    }
    
    function betToPlay(uint quizId) public payable {
        for (uint i = 0; i < quiz_list.length; i++) {
            if (quiz_list[i].id == quizId) {
                if (msg.value < quiz_list[i].min_bet || msg.value > quiz_list[i].max_bet) {
                    revert("");
                }
                else {
                    address sender = msg.sender;
                    bets[quizId - 1][sender] += msg.value;
                    return;
                }
            }
        }
        revert("");
        
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        for (uint i = 0; i < quiz_list.length; i++) {
            if (quiz_list[i].id == quizId) {
                if (keccak256(bytes(quiz_list[i].answer)) == keccak256(bytes(ans))) {
                    return true;
                }
                else {
                    vault_balance += bets[quizId - 1][msg.sender];
                    bets[quizId - 1][msg.sender] = 0;
                    return false;
                }
            }
        }
        revert("");
    }

    function claim() public {
        address payable recipient = payable(msg.sender);
        for (uint i = 0; i < quiz_list.length; i++) {
            uint quiz_id = quiz_list[i].id;
            vault_balance -= 2 * bets[quiz_id- 1][recipient];
            recipient.transfer(2 * bets[quiz_id -1][recipient]);
            bets[quiz_id - 1][recipient]= 0;
        }
        
    }

    receive() external payable {
        vault_balance += msg.value;
    }

}
