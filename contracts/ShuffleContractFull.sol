// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract ShuffleContractFull {
    uint256 public activePlayers;
    uint256 public totalPlayers;

    struct Player {
        address sigAddress;
        address currentOpponent;
        uint256 buyinAmount;
        uint256 depositAmount;
        uint256 buyinTime;
        bool isActive;
    }
    mapping(address => Player) public players;

    mapping(address => uint256) public unfinishedGames;

    event UnfinishedGameEvent(
        address _submitter,
        address indexed _offender,
        uint256 _timestamp
    );

    event GameCreated(
        address indexed _creator,
        address indexed _opponent,
        uint256 _buyin
    );
    event GameStarted(
        address indexed _creator,
        address indexed _opponent,
        uint256 _buyin
    );
    event GameCompleted(
        address indexed _winner,
        address indexed _loser,
        uint256 _buyin,
        uint256 _hands
    );

    receive() external payable {}

    function buyin(
        address _sigAddress,
        address _opponent,
        uint256 _buyin
    ) external payable {
        require(!players[msg.sender].isActive, "already active");
        require(msg.value >= ((_buyin * 12) / 10), "insufficient deposit");
        Player memory player = Player(
            _sigAddress,
            _opponent,
            _buyin,
            msg.value,
            block.timestamp,
            true
        );
        players[msg.sender] = player;
        if (players[_opponent].currentOpponent == msg.sender) {
            emit GameStarted(_opponent, msg.sender, msg.value);
        } else {
            emit GameCreated(msg.sender, _opponent, msg.value);
        }
        totalPlayers++;
        activePlayers++;
    }

    function concede(uint256 _hands) external {
        require(players[msg.sender].isActive);
        address _opponent = players[msg.sender].currentOpponent;
        uint256 _buyin = players[msg.sender].buyinAmount;
        uint256 _remainder = players[msg.sender].depositAmount - _buyin;
        uint256 _transferAmount = _buyin * 2 + _remainder;
        payable(_opponent).transfer(_transferAmount);
        payable(msg.sender).transfer(_remainder);
        // reset player accounts to 0
        players[_opponent].depositAmount = 0;
        players[_opponent].buyinAmount = 0;
        players[_opponent].isActive = false;
        players[msg.sender].depositAmount = 0;
        players[msg.sender].buyinAmount = 0;
        players[msg.sender].isActive = false;
        activePlayers = activePlayers - 2;
        // emit final event announcing the game as completed
        emit GameCompleted(_opponent, msg.sender, _buyin, _hands);
    }

    function getSigKey(address _userAddress)
        public
        view
        returns (address _sigAddress)
    {
        require(players[msg.sender].isActive);
        _sigAddress = players[_userAddress].sigAddress;
    }

    // returns corresponding address of signature attached to string message
    function verifySig(
        string memory message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address signer) {
        // message header --- fill in length later
        string memory header = "\x19Ethereum Signed Message:\n000000";
        uint256 lengthOffset;
        uint256 length;
        assembly {
            length := mload(message)
            lengthOffset := add(header, 57)
        }
        require(length <= 999999);
        uint256 lengthLength = 0;
        uint256 divisor = 100000;
        while (divisor != 0) {
            uint256 digit = length / divisor;
            if (digit == 0) {
                // Skip leading zeros
                if (lengthLength == 0) {
                    divisor /= 10;
                    continue;
                }
            }
            // non-zero digit or non-leading zero digit
            lengthLength++;
            length -= digit * divisor;
            divisor /= 10;

            // convert the digit to its asciii representation (man ascii)
            digit += 0x30;
            lengthOffset++;
            assembly {
                mstore8(lengthOffset, digit)
            }
        }
        // null string requires exactly 1 zero (unskip 1 leading 0)
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }
        assembly {
            mstore(header, lengthLength)
        }
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return ecrecover(check, v, r, s);
    }

    function submitCompletedGame(
        string memory _proof,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        require(players[msg.sender].isActive);
        require(
            verifySig(_proof, _v, _r, _s) ==
                players[players[msg.sender].currentOpponent].sigAddress,
            "verification unsuccessful"
        );
        require(
            keccak256(abi.encodePacked("allin")) ==
                keccak256(abi.encodePacked(_proof))
        );
        unfinishedGames[players[msg.sender].currentOpponent] = block.timestamp;
        emit UnfinishedGameEvent(
            msg.sender,
            players[msg.sender].currentOpponent,
            block.timestamp
        );
    }
}
