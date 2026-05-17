// 鼓励语模型
export class Encouragement {
  id: string; // 唯一标识
  text: string; // 鼓励语文本
  category: string; // 分类：daily, achievement, motivation, funny
  mood: string; // 相关心情
  usedCount: number; // 使用次数
  lastUsed?: number; // 最后使用时间戳

  constructor(
    id: string = '',
    text: string = '',
    category: string = 'daily',
    mood: string = '😊',
    usedCount: number = 0,
    lastUsed?: number
  ) {
    this.id = id;
    this.text = text;
    this.category = category;
    this.mood = mood;
    this.usedCount = usedCount;
    this.lastUsed = lastUsed;
  }

  // 转换为JSON对象
  toJSON(): object {
    return {
      id: this.id,
      text: this.text,
      category: this.category,
      mood: this.mood,
      usedCount: this.usedCount,
      lastUsed: this.lastUsed
    };
  }

  // 从JSON对象创建Encouragement实例
  static fromJSON(json: any): Encouragement {
    return new Encouragement(
      json.id || '',
      json.text || '',
      json.category || 'daily',
      json.mood || '😊',
      json.usedCount || 0,
      json.lastUsed
    );
  }

  // 获取默认鼓励语列表
  static getDefaultEncouragements(): Encouragement[] {
    return [
      new Encouragement(
        'enc_1',
        '今天又是美好的一天！加油！',
        'daily',
        '😊',
        0
      ),
      new Encouragement(
        'enc_2',
        '你已经很棒了！继续前进！',
        'motivation',
        '😄',
        0
      ),
      new Encouragement(
        'enc_3',
        '每一个小进步都值得庆祝！',
        'achievement',
        '🥳',
        0
      ),
      new Encouragement(
        'enc_4',
        '相信自己，你可以做到的！',
        'motivation',
        '😎',
        0
      ),
      new Encouragement(
        'enc_5',
        '生活就像巧克力，你永远不知道下一颗是什么味道~',
        'funny',
        '😄',
        0
      ),
      new Encouragement(
        'enc_6',
        '今天的努力是明天的收获！',
        'daily',
        '😊',
        0
      ),
      new Encouragement(
        'enc_7',
        '你已经完成了这么多，真为你骄傲！',
        'achievement',
        '😍',
        0
      ),
      new Encouragement(
        'enc_8',
        '慢慢来，比较快~',
        'motivation',
        '😌',
        0
      ),
      new Encouragement(
        'enc_9',
        '笑一笑，没什么大不了！',
        'funny',
        '😄',
        0
      ),
      new Encouragement(
        'enc_10',
        '每一天都是新的开始！',
        'daily',
        '😊',
        0
      ),
      new Encouragement(
        'enc_11',
        '你的坚持终将美好！',
        'motivation',
        '🌟',
        0
      ),
      new Encouragement(
        'enc_12',
        '完成一个小目标，奖励自己一下吧！',
        'achievement',
        '🎯',
        0
      ),
      new Encouragement(
        'enc_13',
        '即使慢，只要不停下脚步！',
        'motivation',
        '🚶',
        0
      ),
      new Encouragement(
        'enc_14',
        '保持微笑，好运自然来~',
        'funny',
        '😊',
        0
      ),
      new Encouragement(
        'enc_15',
        '你已经比昨天更优秀了！',
        'daily',
        '😊',
        0
      ),
      new Encouragement(
        'enc_16',
        '困难只是暂时的，坚持就是胜利！',
        'motivation',
        '💪',
        0
      ),
      new Encouragement(
        'enc_17',
        '记录生活，感受美好！',
        'daily',
        '📝',
        0
      ),
      new Encouragement(
        'enc_18',
        '你的心情值得被温柔对待~',
        'mood',
        '😊',
        0
      ),
      new Encouragement(
        'enc_19',
        '每一次记录都是成长的印记！',
        'achievement',
        '🌱',
        0
      ),
      new Encouragement(
        'enc_20',
        '今天也要元气满满哦！',
        'daily',
        '😄',
        0
      )
    ];
  }

  // 根据心情获取鼓励语
  static getEncouragementsByMood(mood: string): Encouragement[] {
    const encouragements = this.getDefaultEncouragements();
    return encouragements.filter(enc => enc.mood === mood || enc.category === 'daily');
  }

  // 获取随机鼓励语
  static getRandomEncouragement(mood?: string): Encouragement {
    const encouragements = mood ? this.getEncouragementsByMood(mood) : this.getDefaultEncouragements();
    if (encouragements.length === 0) {
      return new Encouragement('default', '今天也要加油哦！', 'daily', '😊');
    }
    
    const randomIndex = Math.floor(Math.random() * encouragements.length);
    return encouragements[randomIndex];
  }

  // 标记为已使用
  markAsUsed(): void {
    this.usedCount++;
    this.lastUsed = Date.now();
  }
}