// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title KindActionRewardSystem
 * @dev 착한 행동 보상 시스템: 착한 행동 검증 시 CHC 코인을 지급하고,
 *      일정량의 CHC가 쌓이면 WHC 코인으로 전환할 수 있도록 구현함.
 */
contract KindActionRewardSystem {
    // ========================================================
    // 관리자 설정
    // ========================================================
    address public admin;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    // ========================================================
    // CHC (ColdHouse Token) 변수 및 이벤트
    // ========================================================
    string public chcName = "ColdHouse Token";
    string public chcSymbol = "CHC";
    uint8 public chcDecimals = 18;
    uint256 public chcTotalSupply;
    uint256 public constant CHC_CAP = 1000000 * 10**18; // 최대 1,000,000 CHC
    
    mapping(address => uint256) public chcBalance;
    
    event CHCTransfer(address indexed from, address indexed to, uint256 value);
    
    // ========================================================
    // WHC (WarmHouse Token) 변수 및 이벤트
    // ========================================================
    string public whcName = "WarmHouse Token";
    string public whcSymbol = "WHC";
    uint8 public whcDecimals = 18;
    uint256 public whcTotalSupply;
    uint256 public constant WHC_CAP = 1000 * 10**18; // 최대 1,000 WHC
    
    mapping(address => uint256) public whcBalance;
    
    event WHCRedeemed(address indexed user, uint256 whcAmount);
    
    // ========================================================
    // 착한 행동 기록 관련
    // ========================================================
    // actionType을 bytes32로 처리하여 가스 최적화
    struct KindAction {
        bytes32 actionType;
        string description;
        uint256 timestamp;
        uint256 rewardAmount;
        bool verified;
    }
    
    mapping(address => KindAction[]) public actionHistory;
    
    event KindActionRecorded(address indexed user, bytes32 actionType, uint256 rewardAmount);
    event ActionVerified(address indexed user, uint256 actionIndex);
    
    // ========================================================
    // 전환 비율 상수: 1000 CHC -> 1 WHC
    // ========================================================
    uint256 public constant CONVERSION_RATE = 1000 * 10**18;
    
    // ========================================================
    // 행동 유형별 보상량 매핑 (bytes32 타입 사용)
    // ========================================================
    mapping(bytes32 => uint256) public rewardAmounts;
    
    // ========================================================
    // 생성자: 관리자 및 보상량 초기화
    // ========================================================
    constructor() {
        admin = msg.sender; // 배포자를 초기 관리자(admin)로 설정
        
        // 보상량 초기화 (mapping에 keccak256 해시 값을 사용)
        rewardAmounts[keccak256(abi.encodePacked("recycling"))] = 10 * 10**18;
        rewardAmounts[keccak256(abi.encodePacked("energy_saving"))] = 20 * 10**18;
        rewardAmounts[keccak256(abi.encodePacked("animal_care"))] = 30 * 10**18;
        // 등록되지 않은 행동의 경우, 기본 보상은 5 CHC로 처리
    }
    
    // ========================================================
    // 착한 행동 기록 등록 함수
    // ========================================================
    // actionType은 bytes32 타입으로 전달 (ex: keccak256("recycling"))
    function recordKindAction(bytes32 actionType, string memory description) public {
        uint256 rewardAmount = calculateReward(actionType); // CHC 보상량 계산
        
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
        
        // CHC 토큰 mint (검증된 행동에 대해 지급)
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
        require(chcBalance[msg.sender] >= amount, "Insufficient CHC balance");
        
        chcBalance[msg.sender] -= amount;
        chcBalance[to] += amount;
        
        emit CHCTransfer(msg.sender, to, amount);
        return true;
    }
    
    // ========================================================
    // 보상 계산 함수 (mapping 기반으로 보상량 조회)
    // ========================================================
    function calculateReward(bytes32 actionType) internal view returns (uint256) {
        uint256 reward = rewardAmounts[actionType];
        if (reward == 0) {
            reward = 5 * 10**18; // 기본 보상: 5 CHC
        }
        return reward;
    }
    
    // ========================================================
    // WHC 토큰 전환 함수: CHC를 소각하여 WHC를 발행
    // ========================================================
    function redeemWHC(uint256 chcAmount) public {
        require(chcAmount > 0, "Amount must be > 0");
        require(chcAmount % CONVERSION_RATE == 0, "Amount must be a multiple of conversion rate");
        require(chcBalance[msg.sender] >= chcAmount, "Insufficient CHC balance");
        
        uint256 whcAmount = chcAmount / CONVERSION_RATE;
        require(whcTotalSupply + whcAmount <= WHC_CAP, "Exceeds WHC cap");
        
        // CHC 토큰 소각
        chcBalance[msg.sender] -= chcAmount;
        chcTotalSupply -= chcAmount;
        
        // WHC 토큰 mint
        whcTotalSupply += whcAmount;
        whcBalance[msg.sender] += whcAmount;
        
        emit WHCRedeemed(msg.sender, whcAmount);
        emit CHCTransfer(msg.sender, address(0), chcAmount); // CHC 소각 이벤트
    }
}
