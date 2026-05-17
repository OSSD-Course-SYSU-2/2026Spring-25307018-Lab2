/**
 * 【记忆寻宝小游戏】寻宝模型
 * 从历史笔记库随机抽取宝藏笔记，生成趣味线索
 */

/**
 * 线索难度
 */
export enum ClueDifficulty {
  EASY = 'easy',       // 简单 - 直接提示
  MEDIUM = 'medium',   // 中等 - 需要推理
  HARD = 'hard'        // 困难 - 模糊提示
}

/**
 * 寻宝状态
 */
export enum HuntStatus {
  PREPARING = 'preparing',   // 准备中
  PLAYING = 'playing',       // 进行中
  FOUND = 'found',           // 已找到
  FAILED = 'failed',         // 失败
  TIMEOUT = 'timeout'        // 超时
}

/**
 * 寻宝线索
 */
export class TreasureClue {
  id: string;
  content: string;           // 线索内容
  difficulty: ClueDifficulty;
  type: string;              // 线索类型：mood/tag/time/keyword/priority
  isRevealed: boolean;       // 是否已揭示
  cost: number;              // 消耗碎片数量（精准提示需要消耗）
  
  constructor(
    id: string,
    content: string,
    difficulty: ClueDifficulty,
    type: string,
    isRevealed: boolean = false,
    cost: number = 0
  ) {
    this.id = id;
    this.content = content;
    this.difficulty = difficulty;
    this.type = type;
    this.isRevealed = isRevealed;
    this.cost = cost;
  }
  
  toJson(): ESObject {
    return {
      id: this.id,
      content: this.content,
      difficulty: this.difficulty,
      type: this.type,
      isRevealed: this.isRevealed,
      cost: this.cost
    };
  }
  
  static fromJson(json: ESObject): TreasureClue {
    return new TreasureClue(
      json['id'] as string,
      json['content'] as string,
      json['difficulty'] as ClueDifficulty,
      json['type'] as string,
      json['isRevealed'] as boolean,
      json['cost'] as number
    );
  }
}

/**
 * 寻宝会话
 */
export class TreasureHuntSession {
  id: string;                    // 会话ID
  treasureMemoId: string;        // 宝藏笔记ID
  clues: TreasureClue[];         // 线索列表
  status: HuntStatus;            // 状态
  attempts: number;              // 尝试次数
  maxAttempts: number;           // 最大尝试次数
  startTime: number;             // 开始时间
  endTime: number | null;        // 结束时间
  fragmentsUsed: number;         // 消耗的碎片数
  reward: TreasureReward | null; // 奖励
  
  constructor(
    id: string,
    treasureMemoId: string,
    clues: TreasureClue[],
    status: HuntStatus = HuntStatus.PREPARING,
    attempts: number = 0,
    maxAttempts: number = 3,
    startTime: number = Date.now(),
    endTime: number | null = null,
    fragmentsUsed: number = 0,
    reward: TreasureReward | null = null
  ) {
    this.id = id;
    this.treasureMemoId = treasureMemoId;
    this.clues = clues;
    this.status = status;
    this.attempts = attempts;
    this.maxAttempts = maxAttempts;
    this.startTime = startTime;
    this.endTime = endTime;
    this.fragmentsUsed = fragmentsUsed;
    this.reward = reward;
  }
  
  toJson(): ESObject {
    return {
      id: this.id,
      treasureMemoId: this.treasureMemoId,
      clues: this.clues.map((c: TreasureClue): ESObject => c.toJson()),
      status: this.status,
      attempts: this.attempts,
      maxAttempts: this.maxAttempts,
      startTime: this.startTime,
      endTime: this.endTime,
      fragmentsUsed: this.fragmentsUsed,
      reward: this.reward ? this.reward.toJson() : null
    };
  }
  
  static fromJson(json: ESObject): TreasureHuntSession {
    const cluesData: ESObject = json['clues'] as ESObject;
    const cluesArray: ESObject[] = Array.isArray(cluesData) ? cluesData as ESObject[] : [];
    const clues = cluesArray.map((c: ESObject): TreasureClue => TreasureClue.fromJson(c));
    const rewardData: ESObject = json['reward'] as ESObject;
    const rewardJson: ESObject | null = rewardData ? rewardData : null;
    
    return new TreasureHuntSession(
      json['id'] as string,
      json['treasureMemoId'] as string,
      clues,
      json['status'] as HuntStatus,
      json['attempts'] as number,
      json['maxAttempts'] as number,
      json['startTime'] as number,
      json['endTime'] as number | null,
      json['fragmentsUsed'] as number,
      rewardJson ? TreasureReward.fromJson(rewardJson) : null
    );
  }
  
  static generateId(): string {
    return `hunt_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

/**
 * 寻宝奖励
 */
export class TreasureReward {
  fragments: number;        // 星球碎片数量
  blindBoxDraws: number;    // 盲盒抽奖次数
  bonusReason: string;      // 奖励翻倍原因
  
  constructor(
    fragments: number = 1,
    blindBoxDraws: number = 1,
    bonusReason: string = ''
  ) {
    this.fragments = fragments;
    this.blindBoxDraws = blindBoxDraws;
    this.bonusReason = bonusReason;
  }
  
  toJson(): ESObject {
    return {
      fragments: this.fragments,
      blindBoxDraws: this.blindBoxDraws,
      bonusReason: this.bonusReason
    };
  }
  
  static fromJson(json: ESObject): TreasureReward {
    return new TreasureReward(
      json['fragments'] as number,
      json['blindBoxDraws'] as number,
      json['bonusReason'] as string
    );
  }
}

/**
 * 寻宝战绩统计
 */
export class TreasureHuntStats {
  totalHunts: number;       // 总寻宝次数
  successfulHunts: number;  // 成功次数
  failedHunts: number;      // 失败次数
  totalFragmentsEarned: number;  // 累计获得碎片
  totalBlindBoxDraws: number;    // 累计获得抽奖次数
  nightOwlFinds: number;    // 夜猫子发现次数（凌晨笔记）
  highPriorityFinds: number; // 高优先级发现次数
  lastHuntTime: number;     // 上次寻宝时间
  
  constructor(
    totalHunts: number = 0,
    successfulHunts: number = 0,
    failedHunts: number = 0,
    totalFragmentsEarned: number = 0,
    totalBlindBoxDraws: number = 0,
    nightOwlFinds: number = 0,
    highPriorityFinds: number = 0,
    lastHuntTime: number = 0
  ) {
    this.totalHunts = totalHunts;
    this.successfulHunts = successfulHunts;
    this.failedHunts = failedHunts;
    this.totalFragmentsEarned = totalFragmentsEarned;
    this.totalBlindBoxDraws = totalBlindBoxDraws;
    this.nightOwlFinds = nightOwlFinds;
    this.highPriorityFinds = highPriorityFinds;
    this.lastHuntTime = lastHuntTime;
  }
  
  // 计算成功率
  getSuccessRate(): number {
    if (this.totalHunts === 0) return 0;
    return Math.round((this.successfulHunts / this.totalHunts) * 100);
  }
  
  toJson(): ESObject {
    return {
      totalHunts: this.totalHunts,
      successfulHunts: this.successfulHunts,
      failedHunts: this.failedHunts,
      totalFragmentsEarned: this.totalFragmentsEarned,
      totalBlindBoxDraws: this.totalBlindBoxDraws,
      nightOwlFinds: this.nightOwlFinds,
      highPriorityFinds: this.highPriorityFinds,
      lastHuntTime: this.lastHuntTime
    };
  }
  
  static fromJson(json: ESObject): TreasureHuntStats {
    return new TreasureHuntStats(
      json['totalHunts'] as number || 0,
      json['successfulHunts'] as number || 0,
      json['failedHunts'] as number || 0,
      json['totalFragmentsEarned'] as number || 0,
      json['totalBlindBoxDraws'] as number || 0,
      json['nightOwlFinds'] as number || 0,
      json['highPriorityFinds'] as number || 0,
      json['lastHuntTime'] as number || 0
    );
  }
}
