// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title KindActionRewardSystem
 * @dev 착한 행동 보상 시스템:
 *  - CHC (ColdHouse Coin)는 착한 행동에 대한 보상으로 지급되며 최대 10,000,000개까지 발행됩니다.
 *  - WHC (WarmHouse Coin)는 CHC 전환을 통해 발행되며 최대 1,000개까지 공급됩니다.
 *  - CHC를 WHC로 전환할 때는 CHC를 소각하는 대신 락업(lock-up) 처리하여,
 *    나중에 WHC를 반환하면 락업된 CHC를 해제할 수 있도록 설계되었습니다.
 */
contract KindActionRewardSystem {
    // 관리자 설정
    address public admin;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    // ========================================================
    // CHC (ColdHouse Coin) 관련 변수 및 이벤트
    // ========================================================
    string public chcName = "ColdHouse Coin";
    string public chcSymbol = "CHC";
    uint8 public chcDecimals = 18;
    uint256 public chcTotalSupply;
    uint256 public constant CHC_CAP = 10000000 * 10**18; // 최대 10,000,000 CHC
    
    // 사용자의 CHC 잔액
    mapping(address => uint256) public chcBalance;
    // WHC 전환 시 락업된 CHC (반환 시 해제됨)
    mapping(address => uint256) public chcLocked;
    
    event CHCTransfer(address indexed from, address indexed to, uint256 value);
    event CHCLocked(address indexed user, uint256 amount);
    event CHCUnlocked(address indexed user, uint256 amount);
    
    // ========================================================
    // WHC (WarmHouse Coin) 관련 변수 및 이벤트
    // ========================================================
    string public whcName = "WarmHouse Coin";
    string public whcSymbol = "WHC";
    uint8 public whcDecimals = 18;
    uint256 public whcTotalSupply;
    uint256 public constant WHC_CAP = 1000 * 10**18; // 최대 1,000 WHC
    
    mapping(address => uint256) public whcBalance;
    
    event WHCRedeemed(address indexed user, uint256 whcAmount);
    
    // ========================================================
    // 착한 행동 기록 관련
    // ========================================================
    struct KindAction {
        bytes32 actionType; // 가스 최적화를 위해 bytes32 사용
        string description;
        uint256 timestamp;
        uint256 rewardAmount; // CHC 보상량
        bool verified;
    }
    
    mapping(address => KindAction[]) public actionHistory;
    
    event KindActionRecorded(address indexed user, bytes32 actionType, uint256 rewardAmount);
    event ActionVerified(address indexed user, uint256 actionIndex);
    
    // ========================================================
    // 전환 관련 상수
    // ========================================================
    // CHC를 WHC로 전환하는데 필요한 CHC 수량 (예: 10,000 CHC -> 1 WHC)
    uint256 public constant CONVERSION_RATE = 10000 * 10**18;
    
    // ========================================================
    // 행동 유형별 보상량 (bytes32를 key로 사용)
    // ========================================================
    mapping(bytes32 => uint256) public rewardAmounts;
    
    // ========================================================
    // 생성자: 관리자 및 보상량 초기화
    // ========================================================
    constructor() {
        admin = msg.sender; // 배포자를 관리자(admin)로 설정
        
        // 보상량 초기화
        rewardAmounts[keccak256(abi.encodePacked("recycling"))] = 10 * 10**18;
        rewardAmounts[keccak256(abi.encodePacked("energy_saving"))] = 20 * 10**18;
        rewardAmounts[keccak256(abi.encodePacked("animal_care"))] = 30 * 10**18;
        // 등록되지 않은 행동은 기본 보상: 5 CHC
    }
    
    // ========================================================
    // 착한 행동 기록 등록 함수
    // ========================================================
    // actionType은 bytes32 형태로 전달 (예: keccak256("recycling"))
    function recordKindAction(bytes32 actionType, string memory description) public {
        uint256 rewardAmount = calculateReward(actionType);
        actionHistory[msg.sender].push(KindAction({
            actionType: actionType,
            description: description,
            timestamp: block.timestamp,
            rewardAmount: rewardAmount,
            verified: false
        }));
        emit KindActionRecorded(msg.sender, actionType, rewardAmount);
    }
    
    // ========================================================
    // 행동 검증 함수 (관리자 전용)
    // ========================================================
    function verifyAction(address user, uint256 actionIndex) public onlyAdmin {
        require(actionIndex < actionHistory[user].length, "Invalid action index");
        KindAction storage action = actionHistory[user][actionIndex];
        require(!action.verified, "Action already verified");
        
        action.verified = true;
        uint256 rewardAmount = action.rewardAmount;
        require(chcTotalSupply + rewardAmount <= CHC_CAP, "Exceeds CHC cap");
        
        // CHC 토큰 mint
        chcTotalSupply += rewardAmount;
        chcBalance[user] += rewardAmount;
        
        emit ActionVerified(user, actionIndex);
        emit CHCTransfer(address(0), user, rewardAmount);
    }
    
    // ========================================================
    // CHC 토큰 전송 함수
    // ========================================================
    function transferCHC(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Invalid address");
        // 사용 가능한 CHC = 전체 CHC 잔액 - 락업된 CHC
        require(chcBalance[msg.sender] - chcLocked[msg.sender] >= amount, "Insufficient available CHC balance");
        
        chcBalance[msg.sender] -= amount;
        chcBalance[to] += amount;
        
        emit CHCTransfer(msg.sender, to, amount);
        return true;
    }
    
    // ========================================================
    // 보상 계산 함수 (mapping 기반 조회)
    // ========================================================
    function calculateReward(bytes32 actionType) internal view returns (uint256) {
        uint256 reward = rewardAmounts[actionType];
        if (reward == 0) {
            reward = 5 * 10**18; // 기본 보상: 5 CHC
        }
        return reward;
    }
    
    // ========================================================
    // WHC 전환 함수 (CHC를 락업하여 WHC 발행)
    // ========================================================
    function redeemWHC(uint256 chcAmount) public {
        require(chcAmount > 0, "Amount must be > 0");
        require(chcAmount % CONVERSION_RATE == 0, "Amount must be a multiple of conversion rate");
        uint256 availableCHC = chcBalance[msg.sender] - chcLocked[msg.sender];
        require(availableCHC >= chcAmount, "Insufficient available CHC balance");
        
        uint256 whcAmount = chcAmount / CONVERSION_RATE;
        require(whcTotalSupply + whcAmount <= WHC_CAP, "Exceeds WHC cap");
        
        // CHC를 소각하지 않고 락업 처리
        chcLocked[msg.sender] += chcAmount;
        // WHC 토큰 발행
        whcTotalSupply += whcAmount;
        whcBalance[msg.sender] += whcAmount;
        
        emit WHCRedeemed(msg.sender, whcAmount);
        emit CHCLocked(msg.sender, chcAmount);
    }
    
    // ========================================================
    // WHC 반환 시 락업된 CHC를 해제하는 함수
    // ========================================================
    function unlockCHC(uint256 whcAmount) public {
        require(whcAmount > 0, "Amount must be > 0");
        require(whcBalance[msg.sender] >= whcAmount, "Insufficient WHC balance");
        
        uint256 chcToUnlock = whcAmount * CONVERSION_RATE;
        require(chcLocked[msg.sender] >= chcToUnlock, "Not enough locked CHC to unlock");
        
        // WHC 소각 (반환)
        whcBalance[msg.sender] -= whcAmount;
        whcTotalSupply -= whcAmount;
        
        // 락업 해제: CHC의 락업된 부분을 감소시킴
        chcLocked[msg.sender] -= chcToUnlock;
        
        emit CHCUnlocked(msg.sender, chcToUnlock);
    }
}
