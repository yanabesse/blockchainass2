// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    address public owner;
    uint256 public betAmount = 0.0001 ether;
    enum Move { None, Rock, Paper, Scissors }

    struct Game {
        address player;
        Move playerMove;
        Move houseMove;
        bool resultSet;
        bool playerWon;
    }

    Game[] public games;
    mapping(address => uint256) public balances; 

    event NewGame(uint256 gameId);
    event GameResult(uint256 gameId, bool playerWon);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function play(uint256 _move) external payable {
        require(msg.value == betAmount, "Incorrect bet amount.");
        require(_move >= uint(Move.Rock) && _move <= uint(Move.Scissors), "Invalid move.");

        Game memory newGame = Game(msg.sender, Move(_move), Move.None, false, false);
        games.push(newGame);
        uint256 gameId = games.length - 1;
        emit NewGame(gameId);
    }

    function playHouse(uint256 _gameId, uint256 _houseMove) external onlyOwner {
        require(_gameId < games.length, "Game ID does not exist.");
        require(!games[_gameId].resultSet, "Game result already set.");
        require(_houseMove >= uint(Move.Rock) && _houseMove <= uint(Move.Scissors), "Invalid house move.");

        games[_gameId].houseMove = Move(_houseMove);
        games[_gameId].resultSet = true;

        uint256 playerMove = uint(games[_gameId].playerMove);
        uint256 houseMove = uint(games[_gameId].houseMove);

        if (playerMove == houseMove) {
            // It's a tie
            balances[msg.sender] += betAmount;
        } else if ((playerMove == uint(Move.Rock) && houseMove == uint(Move.Scissors)) ||
                   (playerMove == uint(Move.Paper) && houseMove == uint(Move.Rock)) ||
                   (playerMove == uint(Move.Scissors) && houseMove == uint(Move.Paper))) {
            // Player wins
            balances[msg.sender] += betAmount * 2;
            emit GameResult(_gameId, true);
        } else {
            // House wins
            emit GameResult(_gameId, false);
        }
    }

    function getGameCount() external view returns (uint256) {
        return games.length;
    }

    function fund() external payable {
        require(msg.value > 0, "You must send some ETH to fund your balance.");
        balances[msg.sender] += msg.value;
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
}
