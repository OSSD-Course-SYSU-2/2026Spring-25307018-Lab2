// 心情记录模型
export class MoodRecord {
  id: string; // 唯一标识
  date: string; // 日期（YYYY-MM-DD格式）
  mood: string; // 心情表情
  moodLevel: number; // 心情等级：1-5
  memoId?: string; // 关联的备忘录ID（可选）
  note?: string; // 心情备注（可选）
  createdAt: number; // 创建时间戳

  constructor(
    id: string = '',
    date: string = '',
    mood: string = '😊',
    moodLevel: number = 3,
    memoId?: string,
    note?: string,
    createdAt: number = Date.now()
  ) {
    this.id = id;
    this.date = date;
    this.mood = mood;
    this.moodLevel = moodLevel;
    this.memoId = memoId;
    this.note = note;
    this.createdAt = createdAt;
  }

  // 转换为JSON对象
  toJSON(): object {
    return {
      id: this.id,
      date: this.date,
      mood: this.mood,
      moodLevel: this.moodLevel,
      memoId: this.memoId,
      note: this.note,
      createdAt: this.createdAt
    };
  }

  // 从JSON对象创建MoodRecord实例
  static fromJSON(json: any): MoodRecord {
    return new MoodRecord(
      json.id || '',
      json.date || '',
      json.mood || '😊',
      json.moodLevel || 3,
      json.memoId,
      json.note,
      json.createdAt || Date.now()
    );
  }

  // 获取心情等级描述
  getMoodLevelDescription(): string {
    switch (this.moodLevel) {
      case 1:
        return '非常糟糕';
      case 2:
        return '有点糟糕';
      case 3:
        return '一般';
      case 4:
        return '不错';
      case 5:
        return '非常好';
      default:
        return '一般';
    }
  }

  // 获取心情颜色
  getMoodColor(): string {
    switch (this.moodLevel) {
      case 1:
        return '#F44336'; // 红色
      case 2:
        return '#FF9800'; // 橙色
      case 3:
        return '#FFEB3B'; // 黄色
      case 4:
        return '#4CAF50'; // 绿色
      case 5:
        return '#2196F3'; // 蓝色
      default:
        return '#FFEB3B';
    }
  }

  // 获取心情表情列表
  static getMoodEmojis(): string[] {
    return ['😊', '😄', '😍', '🥳', '😎', '😌', '😐', '😔', '😢', '😠', '😴', '🤔'];
  }

  // 获取默认心情记录（用于当天）
  static getDefaultMoodRecord(date?: string): MoodRecord {
    const today = date || new Date().toISOString().split('T')[0];
    return new MoodRecord(
      `mood_${Date.now()}`,
      today,
      '😊',
      3
    );
  }
}