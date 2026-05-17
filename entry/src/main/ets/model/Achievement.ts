// 成就勋章模型
export class Achievement {
  id: string; // 唯一标识
  title: string; // 成就标题
  description: string; // 成就描述
  icon: string; // 图标
  type: string; // 类型：memo_count, mood_streak, completion_rate, etc.
  requirement: number; // 达成要求
  currentProgress: number; // 当前进度
  isUnlocked: boolean; // 是否已解锁
  unlockedAt?: number; // 解锁时间戳
  rarity: string; // 稀有度：common, rare, epic, legendary
  category: string; // 分类：memo, mood, streak, challenge

  constructor(
    id: string = '',
    title: string = '',
    description: string = '',
    icon: string = '🏆',
    type: string = '',
    requirement: number = 0,
    currentProgress: number = 0,
    isUnlocked: boolean = false,
    unlockedAt?: number,
    rarity: string = 'common',
    category: string = 'memo'
  ) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.icon = icon;
    this.type = type;
    this.requirement = requirement;
    this.currentProgress = currentProgress;
    this.isUnlocked = isUnlocked;
    this.unlockedAt = unlockedAt;
    this.rarity = rarity;
    this.category = category;
  }

  // 转换为JSON对象
  toJSON(): object {
    return {
      id: this.id,
      title: this.title,
      description: this.description,
      icon: this.icon,
      type: this.type,
      requirement: this.requirement,
      currentProgress: this.currentProgress,
      isUnlocked: this.isUnlocked,
      unlockedAt: this.unlockedAt,
      rarity: this.rarity,
      category: this.category
    };
  }

  // 从JSON对象创建Achievement实例
  static fromJSON(json: any): Achievement {
    return new Achievement(
      json.id || '',
      json.title || '',
      json.description || '',
      json.icon || '🏆',
      json.type || '',
      json.requirement || 0,
      json.currentProgress || 0,
      json.isUnlocked || false,
      json.unlockedAt,
      json.rarity || 'common',
      json.category || 'memo'
    );
  }

  // 获取进度百分比
  getProgressPercentage(): number {
    if (this.requirement === 0) return 100;
    return Math.min(100, Math.round((this.currentProgress / this.requirement) * 100));
  }

  // 获取稀有度颜色
  getRarityColor(): string {
    switch (this.rarity) {
      case 'common':
        return '#757575'; // 灰色
      case 'rare':
        return '#2196F3'; // 蓝色
      case 'epic':
        return '#9C27B0'; // 紫色
      case 'legendary':
        return '#FF9800'; // 橙色
      default:
        return '#757575';
    }
  }

  // 获取稀有度文本
  getRarityText(): string {
    switch (this.rarity) {
      case 'common':
        return '普通';
      case 'rare':
        return '稀有';
      case 'epic':
        return '史诗';
      case 'legendary':
        return '传说';
      default:
        return '普通';
    }
  }

  // 更新进度
  updateProgress(newProgress: number): void {
    this.currentProgress = newProgress;
    if (!this.isUnlocked && this.currentProgress >= this.requirement) {
      this.isUnlocked = true;
      this.unlockedAt = Date.now();
    }
  }

  // 增加进度
  incrementProgress(amount: number = 1): void {
    this.updateProgress(this.currentProgress + amount);
  }

  // 获取默认成就列表
  static getDefaultAchievements(): Achievement[] {
    return [
      new Achievement(
        'first_memo',
        '第一次记录',
        '创建你的第一条备忘录',
        '📝',
        'memo_count',
        1,
        0,
        false,
        undefined,
        'common',
        'memo'
      ),
      new Achievement(
        'memo_master',
        '备忘录大师',
        '创建10条备忘录',
        '📚',
        'memo_count',
        10,
        0,
        false,
        undefined,
        'rare',
        'memo'
      ),
      new Achievement(
        'completionist',
        '完成者',
        '完成5条备忘录',
        '✅',
        'completed_memos',
        5,
        0,
        false,
        undefined,
        'rare',
        'memo'
      ),
      new Achievement(
        'mood_tracker',
        '心情记录者',
        '记录5天心情',
        '😊',
        'mood_days',
        5,
        0,
        false,
        undefined,
        'common',
        'mood'
      ),
      new Achievement(
        'mood_explorer',
        '心情探索者',
        '使用5种不同的心情表情',
        '🌈',
        'mood_variety',
        5,
        0,
        false,
        undefined,
        'rare',
        'mood'
      ),
      new Achievement(
        'streak_3',
        '三日坚持',
        '连续3天记录备忘录',
        '🔥',
        'memo_streak',
        3,
        0,
        false,
        undefined,
        'common',
        'streak'
      ),
      new Achievement(
        'streak_7',
        '一周坚持',
        '连续7天记录备忘录',
        '🌟',
        'memo_streak',
        7,
        0,
        false,
        undefined,
        'epic',
        'streak'
      ),
      new Achievement(
        'priority_queen',
        '优先级女王',
        '创建3条高优先级备忘录',
        '👑',
        'high_priority',
        3,
        0,
        false,
        undefined,
        'legendary',
        'memo'
      ),
      new Achievement(
        'tag_master',
        '标签大师',
        '使用5个不同的标签',
        '🏷️',
        'tag_variety',
        5,
        0,
        false,
        undefined,
        'rare',
        'memo'
      ),
      new Achievement(
        'early_bird',
        '早起的鸟儿',
        '在早上8点前创建备忘录',
        '🌅',
        'early_memo',
        1,
        0,
        false,
        undefined,
        'epic',
        'challenge'
      )
    ];
  }
}