/**
 * 盲盒奖励模型
 */
export class BlindBoxReward {
  id: string;
  type: RewardType;
  name: string;
  description: string;
  icon: string;
  rarity: Rarity;
  unlockedAt: number;
  
  constructor(
    id: string,
    type: RewardType,
    name: string,
    description: string,
    icon: string,
    rarity: Rarity,
    unlockedAt: number = Date.now()
  ) {
    this.id = id;
    this.type = type;
    this.name = name;
    this.description = description;
    this.icon = icon;
    this.rarity = rarity;
    this.unlockedAt = unlockedAt;
  }
  
  toJson(): ESObject {
    return {
      id: this.id,
      type: this.type,
      name: this.name,
      description: this.description,
      icon: this.icon,
      rarity: this.rarity,
      unlockedAt: this.unlockedAt
    };
  }
  
  static fromJson(json: ESObject): BlindBoxReward {
    return new BlindBoxReward(
      json['id'] as string,
      json['type'] as RewardType,
      json['name'] as string,
      json['description'] as string,
      json['icon'] as string,
      json['rarity'] as Rarity,
      json['unlockedAt'] as number
    );
  }
}

/**
 * 奖励类型
 */
export enum RewardType {
  STORY_FRAGMENT = 'story_fragment',    // 剧情碎片
  EMOTICON = 'emoticon',                // 限定表情包
  BORDER = 'border',                    // 笔记边框
  SPRITE_SKIN = 'sprite_skin',          // 小精灵皮肤
  AI_REPLY = 'ai_reply',                // AI趣味回复
  HIDDEN_TASK = 'hidden_task'           // 隐藏任务
}

/**
 * 稀有度
 */
export enum Rarity {
  COMMON = 'common',      // 普通
  RARE = 'rare',          // 稀有
  EPIC = 'epic',          // 史诗
  LEGENDARY = 'legendary' // 传说
}

/**
 * 盲盒奖励池
 */
export class BlindBoxPool {
  // 剧情碎片
  static readonly STORY_FRAGMENTS: BlindBoxReward[] = [
    new BlindBoxReward('sf1', RewardType.STORY_FRAGMENT, '神秘日记残页', '一张泛黄的日记残页，上面写着："今天遇到了..."', '📜', Rarity.COMMON),
    new BlindBoxReward('sf2', RewardType.STORY_FRAGMENT, '时光明信片', '来自未来的明信片，署名模糊不清', '📮', Rarity.RARE),
    new BlindBoxReward('sf3', RewardType.STORY_FRAGMENT, '梦境碎片', '一段似曾相识的梦境，醒来后却记不清了', '💭', Rarity.EPIC),
    new BlindBoxReward('sf4', RewardType.STORY_FRAGMENT, '命运之书残卷', '传说中记载命运的书，只剩一页', '📖', Rarity.LEGENDARY)
  ];
  
  // 限定表情包
  static readonly EMOTICONS: BlindBoxReward[] = [
    new BlindBoxReward('em1', RewardType.EMOTICON, '开心小猫', '一只超级开心的猫咪表情', '😺', Rarity.COMMON),
    new BlindBoxReward('em2', RewardType.EMOTICON, '害羞小兔', '脸红红的可爱小兔子', '🐰', Rarity.RARE),
    new BlindBoxReward('em3', RewardType.EMOTICON, '星星眼', '眼睛闪闪发光的表情', '✨', Rarity.EPIC),
    new BlindBoxReward('em4', RewardType.EMOTICON, '彩虹独角兽', '传说中的彩虹独角兽', '🦄', Rarity.LEGENDARY)
  ];
  
  // 笔记边框
  static readonly BORDERS: BlindBoxReward[] = [
    new BlindBoxReward('bd1', RewardType.BORDER, '简约黑框', '简洁大方的黑色边框', '⬛', Rarity.COMMON),
    new BlindBoxReward('bd2', RewardType.BORDER, '樱花粉框', '浪漫的樱花粉色边框', '🌸', Rarity.RARE),
    new BlindBoxReward('bd3', RewardType.BORDER, '星空紫框', '神秘的星空紫色边框', '🌌', Rarity.EPIC),
    new BlindBoxReward('bd4', RewardType.BORDER, '彩虹渐变框', '七彩渐变的梦幻边框', '🌈', Rarity.LEGENDARY)
  ];
  
  // 小精灵皮肤
  static readonly SPRITE_SKINS: BlindBoxReward[] = [
    new BlindBoxReward('sk1', RewardType.SPRITE_SKIN, '小黄鸭', '可爱的小黄鸭皮肤', '🦆', Rarity.COMMON),
    new BlindBoxReward('sk2', RewardType.SPRITE_SKIN, '小企鹅', '呆萌的小企鹅皮肤', '🐧', Rarity.RARE),
    new BlindBoxReward('sk3', RewardType.SPRITE_SKIN, '小狐狸', '机灵的小狐狸皮肤', '🦊', Rarity.EPIC),
    new BlindBoxReward('sk4', RewardType.SPRITE_SKIN, '小凤凰', '传说中的凤凰皮肤', '🔥', Rarity.LEGENDARY)
  ];
  
  // AI趣味回复
  static readonly AI_REPLIES: BlindBoxReward[] = [
    new BlindBoxReward('ai1', RewardType.AI_REPLY, '鼓励大师', 'AI会给你超多鼓励！', '💪', Rarity.COMMON),
    new BlindBoxReward('ai2', RewardType.AI_REPLY, '幽默达人', 'AI会用幽默的方式回应你', '😄', Rarity.RARE),
    new BlindBoxReward('ai3', RewardType.AI_REPLY, '哲学家', 'AI会用哲学的角度分析你的笔记', '🤔', Rarity.EPIC),
    new BlindBoxReward('ai4', RewardType.AI_REPLY, '预言家', 'AI会给你一些神秘的预言', '🔮', Rarity.LEGENDARY)
  ];
  
  // 隐藏任务
  static readonly HIDDEN_TASKS: BlindBoxReward[] = [
    new BlindBoxReward('ht1', RewardType.HIDDEN_TASK, '每日一记', '连续7天每天写一篇笔记', '📅', Rarity.RARE),
    new BlindBoxReward('ht2', RewardType.HIDDEN_TASK, '心情收集者', '记录10种不同的心情', '🎭', Rarity.EPIC),
    new BlindBoxReward('ht3', RewardType.HIDDEN_TASK, '深夜诗人', '在凌晨写5篇笔记', '🌙', Rarity.LEGENDARY)
  ];
  
  // 获取所有奖励
  static getAllRewards(): BlindBoxReward[] {
    return [
      ...BlindBoxPool.STORY_FRAGMENTS,
      ...BlindBoxPool.EMOTICONS,
      ...BlindBoxPool.BORDERS,
      ...BlindBoxPool.SPRITE_SKINS,
      ...BlindBoxPool.AI_REPLIES,
      ...BlindBoxPool.HIDDEN_TASKS
    ];
  }
  
  // 随机抽取一个奖励（根据稀有度权重）
  static drawRandom(): BlindBoxReward {
    const allRewards = BlindBoxPool.getAllRewards();
    
    // 稀有度权重：普通60%、稀有25%、史诗12%、传说3%
    const rand = Math.random() * 100;
    let targetRarity: Rarity;
    
    if (rand < 3) {
      targetRarity = Rarity.LEGENDARY;
    } else if (rand < 15) {
      targetRarity = Rarity.EPIC;
    } else if (rand < 40) {
      targetRarity = Rarity.RARE;
    } else {
      targetRarity = Rarity.COMMON;
    }
    
    // 从该稀有度的奖励中随机选择
    const filteredRewards = allRewards.filter(r => r.rarity === targetRarity);
    const selectedReward = filteredRewards[Math.floor(Math.random() * filteredRewards.length)];
    
    // 返回新的实例（带当前时间戳）
    return new BlindBoxReward(
      selectedReward.id + '_' + Date.now(),
      selectedReward.type,
      selectedReward.name,
      selectedReward.description,
      selectedReward.icon,
      selectedReward.rarity
    );
  }
}
