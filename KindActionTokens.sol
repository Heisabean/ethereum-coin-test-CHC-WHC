// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 착한 행동 토큰의 기본 구조를 정의하는 컨트랙트
abstract contract KindActionToken {
    string public name;         // 토큰 이름
    string public symbol;       // 토큰 심볼
    uint8 public decimals;      // 소수점 자릿수
    uint256 public totalSupply; // 총 발행량

    // 주소별 잔액
    mapping(address => uint256) public balanceOf;
    
    // 착한 행동 기록 구조체
    struct KindAction {
        string actionType;      // 행동 유형
        string description;     // 행동 설명
        uint256 timestamp;      // 발생 시간
        uint256 rewardAmount;   // 보상 금액
        bool verified;          // 검증 여부
    }
    
    // 주소별 착한 행동 기록
    mapping(address => KindAction[]) public actionHistory;
    
    // 이벤트 정의
    event Transfer(address indexed from, address indexed to, uint256 value);
    event KindActionRecorded(address indexed user, string actionType, uint256 rewardAmount);
    event ActionVerified(address indexed user, uint256 actionIndex);
    
    // 생성자
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;  // 표준 decimals 값 사용
    }
    
    // 토큰 전송 함수
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    // 착한 행동 기록 함수
    function recordKindAction(string memory actionType, string memory description) public {
        uint256 rewardAmount = calculateReward(actionType);  // 보상 계산
        
        // 행동 기록 추가
        actionHistory[msg.sender].push(KindAction({
            actionType: actionType,
            description: description,
            timestamp: block.timestamp,
            rewardAmount: rewardAmount,
            verified: false
        }));
        
        emit KindActionRecorded(msg.sender, actionType, rewardAmount);
    }
    
    // 행동 검증 함수 (관리자만 호출 가능)
    function verifyAction(address user, uint256 actionIndex) public {
        require(actionIndex < actionHistory[user].length, "Invalid action index");
        require(!actionHistory[user][actionIndex].verified, "Already verified");
        
        actionHistory[user][actionIndex].verified = true;
        uint256 rewardAmount = actionHistory[user][actionIndex].rewardAmount;
        
        // 보상 지급
        totalSupply += rewardAmount;
        balanceOf[user] += rewardAmount;
        
        emit ActionVerified(user, actionIndex);
        emit Transfer(address(0), user, rewardAmount);
    }
    
    // 보상 계산 함수 (각 토큰별로 다르게 구현)
    function calculateReward(string memory actionType) internal virtual returns (uint256);
}

// ColdHouse 토큰 구현
contract ColdHouseToken is KindActionToken {
    constructor() KindActionToken("ColdHouse Token", "CHC") {}
    
    // CHC 보상 계산 구현
    function calculateReward(string memory actionType) internal pure override returns (uint256) {
        // 환경 보호 활동별 보상 정책 구현
        bytes32 actionHash = keccak256(abi.encodePacked(actionType));
        
        if (actionHash == keccak256(abi.encodePacked("recycling"))) {
            return 10 * 10**18;  // 재활용 활동: 10 CHC
        } else if (actionHash == keccak256(abi.encodePacked("energy_saving"))) {
            return 20 * 10**18;  // 에너지 절약: 20 CHC
        } else if (actionHash == keccak256(abi.encodePacked("animal_care"))) {
            return 30 * 10**18;  // 동물 보호: 30 CHC
        }
        
        return 5 * 10**18;  // 기본 보상: 5 CHC
    }
}

// WarmHouse 토큰 구현
contract WarmHouseToken is KindActionToken {
    constructor() KindActionToken("WarmHouse Token", "WHC") {}
    
    // WHC 보상 계산 구현
    function calculateReward(string memory actionType) internal pure override returns (uint256) {
        // 따뜻한 행동별 보상 정책 구현
        bytes32 actionHash = keccak256(abi.encodePacked(actionType));
        
        if (actionHash == keccak256(abi.encodePacked("donation"))) {
            return 15 * 10**18;  // 기부: 15 WHC
        } else if (actionHash == keccak256(abi.encodePacked("volunteer"))) {
            return 25 * 10**18;  // 봉사: 25 WHC
        } else if (actionHash == keccak256(abi.encodePacked("sharing_warmth"))) {
            return 35 * 10**18;  // 난방 공유: 35 WHC
        }
        
        return 5 * 10**18;  // 기본 보상: 5 WHC
    }
}