/**
 * 成就系统模型
 */
export class Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  category: AchievementCategory;
  condition: AchievementCondition;
  isUnlocked: boolean;
  unlockedAt: number | null;
  progress: number;        // 当前进度
  targetProgress: number;  // 目标进度
  
  constructor(
    id: string,
    name: string,
    description: string,
    icon: string,
    category: AchievementCategory,
    condition: AchievementCondition,
    targetProgress: number = 1,
    isUnlocked: boolean = false,
    unlockedAt: number | null = null,
    progress: number = 0
  ) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.icon = icon;
    this.category = category;
    this.condition = condition;
    this.isUnlocked = isUnlocked;
    this.unlockedAt = unlockedAt;
    this.progress = progress;
    this.targetProgress = targetProgress;
  }
  
  // 检查是否完成
  checkCompletion(): boolean {
    if (this.isUnlocked) return true;
    return this.progress >= this.targetProgress;
  }
  
  // 获取进度百分比
  getProgressPercent(): number {
    return Math.min(100, Math.round((this.progress / this.targetProgress) * 100));
  }
  
  toJson(): ESObject {
    return {
      id: this.id,
      name: this.name,
      description: this.description,
      icon: this.icon,
      category: this.category,
      condition: this.condition,
      isUnlocked: this.isUnlocked,
      unlockedAt: this.unlockedAt,
      progress: this.progress,
      targetProgress: this.targetProgress
    };
  }
  
  static fromJson(json: ESObject): Achievement {
    return new Achievement(
      json['id'] as string,
      json['name'] as string,
      json['description'] as string,
      json['icon'] as string,
      json['category'] as AchievementCategory,
      json['condition'] as AchievementCondition,
      json['targetProgress'] as number,
      json['isUnlocked'] as boolean,
      json['unlockedAt'] as number | null,
      json['progress'] as number
    );
  }
}

/**
 * 成就类别
 */
export enum AchievementCategory {
  TIME = 'time',        // 时间相关
  MOOD = 'mood',        // 心情相关
  CONTENT = 'content',  // 内容相关
  SPECIAL = 'special'   // 特殊成就
}

/**
 * 成就条件类型
 */
export enum AchievementCondition {
  LATE_NIGHT = 'late_night',           // 深夜写笔记
  EARLY_MORNING = 'early_morning',     // 清晨写笔记
  CONTINUOUS_HAPPY = 'continuous_happy', // 连续开心记录
  MOOD_COLLECTOR = 'mood_collector',   // 收集多种心情
  FISHING_MASTER = 'fishing_master',   // 摸鱼笔记
  DAILY_WRITER = 'daily_writer',       // 每日一记
  WEEKLY_WRITER = 'weekly_writer',     // 每周坚持
  FIRST_NOTE = 'first_note',           // 第一篇笔记
  HUNDRED_NOTES = 'hundred_notes',     // 百篇笔记
  RAINBOW_MOOD = 'rainbow_mood',       // 彩虹心情（记录所有心情类型）
  // 【新增】星球成就
  STAR_COLLECTOR = 'star_collector',   // 星际收藏家
  GALAXY_CREATOR = 'galaxy_creator',   // 银河缔造者
  HEALING_NEBULA = 'healing_nebula',   // 治愈星云
  // 【新增】寻宝成就
  MEMORY_MASTER = 'memory_master',     // 记忆大师
  TIME_EXPLORER = 'time_explorer'      // 时光探险家
}

/**
 * 成就定义池
 */
export class AchievementPool {
  static readonly ALL_ACHIEVEMENTS: Achievement[] = [
    // 时间相关成就
    new Achievement(
      'night_owl',
      '熬夜夜猫子',
      '在凌晨0-4点写笔记',
      '🦉',
      AchievementCategory.TIME,
      AchievementCondition.LATE_NIGHT,
      5  // 需要5次
    ),
    new Achievement(
      'early_bird',
      '早起鸟儿',
      '在清晨5-7点写笔记',
      '🐦',
      AchievementCategory.TIME,
      AchievementCondition.EARLY_MORNING,
      5
    ),
    new Achievement(
      'midnight_poet',
      '深夜诗人',
      '在凌晨3点写笔记',
      '🌙',
      AchievementCategory.TIME,
      AchievementCondition.LATE_NIGHT,
      5
    ),
    
    // 心情相关成就
    new Achievement(
      'sunny_person',
      '阳光体质',
      '连续7天记录开心心情',
      '☀️',
      AchievementCategory.MOOD,
      AchievementCondition.CONTINUOUS_HAPPY,
      7
    ),
    new Achievement(
      'mood_collector',
      '心情收集者',
      '记录10种不同的心情',
      '🎭',
      AchievementCategory.MOOD,
      AchievementCondition.MOOD_COLLECTOR,
      10
    ),
    new Achievement(
      'rainbow_heart',
      '彩虹心',
      '记录所有12种心情类型',
      '🌈',
      AchievementCategory.MOOD,
      AchievementCondition.RAINBOW_MOOD,
      12
    ),
    
    // 内容相关成就
    new Achievement(
      'fishing_master',
      '摸鱼大师',
      '写10条包含"摸鱼"的笔记',
      '🐟',
      AchievementCategory.CONTENT,
      AchievementCondition.FISHING_MASTER,
      10
    ),
    new Achievement(
      'first_step',
      '第一步',
      '写下第一篇笔记',
      '👣',
      AchievementCategory.CONTENT,
      AchievementCondition.FIRST_NOTE,
      1
    ),
    new Achievement(
      'century_writer',
      '百篇达人',
      '累计写100篇笔记',
      '💯',
      AchievementCategory.CONTENT,
      AchievementCondition.HUNDRED_NOTES,
      100
    ),
    
    // 特殊成就
    new Achievement(
      'daily_writer',
      '每日一记',
      '连续7天每天写笔记',
      '📅',
      AchievementCategory.SPECIAL,
      AchievementCondition.DAILY_WRITER,
      7
    ),
    new Achievement(
      'weekly_warrior',
      '周周坚持',
      '连续4周每周都写笔记',
      '🗓️',
      AchievementCategory.SPECIAL,
      AchievementCondition.WEEKLY_WRITER,
      4
    ),
    
    // 【新增】星球成就
    new Achievement(
      'star_collector',
      '星际收藏家',
      '收集50块星球碎片',
      '🌟',
      AchievementCategory.SPECIAL,
      AchievementCondition.STAR_COLLECTOR,
      50
    ),
    new Achievement(
      'galaxy_creator',
      '银河缔造者',
      '收集100块星球碎片',
      '🌌',
      AchievementCategory.SPECIAL,
      AchievementCondition.GALAXY_CREATOR,
      100
    ),
    new Achievement(
      'healing_nebula',
      '治愈星云',
      '收集10块淡蓝星云碎片（难过心情）',
      '💫',
      AchievementCategory.SPECIAL,
      AchievementCondition.HEALING_NEBULA,
      10
    ),
    
    // 【新增】寻宝成就
    new Achievement(
      'memory_master',
      '记忆大师',
      '成功寻宝10次',
      '🎯',
      AchievementCategory.SPECIAL,
      AchievementCondition.MEMORY_MASTER,
      10
    ),
    new Achievement(
      'time_explorer',
      '时光探险家',
      '找到5条凌晨笔记宝藏',
      '⏰',
      AchievementCategory.SPECIAL,
      AchievementCondition.TIME_EXPLORER,
      5
    )
  ];
  
  // 获取所有成就定义（用于初始化）
  static getInitialAchievements(): Achievement[] {
    return AchievementPool.ALL_ACHIEVEMENTS.map(a => new Achievement(
      a.id,
      a.name,
      a.description,
      a.icon,
      a.category,
      a.condition,
      a.targetProgress
    ));
  }
}
