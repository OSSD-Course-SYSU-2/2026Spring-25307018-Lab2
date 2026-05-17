/**
 * 时间胶囊模型
 */
export class TimeCapsule {
  id: string;
  memoId: string;           // 关联的笔记ID
  memoTitle: string;        // 笔记标题（用于展示）
  memoContent: string;      // 笔记内容
  unlockDate: number;       // 解锁日期时间戳
  createdAt: number;        // 创建时间
  isUnlocked: boolean;      // 是否已解锁
  mood: string;             // 心情
  priority: number;         // 优先级
  
  constructor(
    id: string,
    memoId: string,
    memoTitle: string,
    memoContent: string,
    unlockDate: number,
    createdAt: number = Date.now(),
    isUnlocked: boolean = false,
    mood: string = '😊',
    priority: number = 2
  ) {
    this.id = id;
    this.memoId = memoId;
    this.memoTitle = memoTitle;
    this.memoContent = memoContent;
    this.unlockDate = unlockDate;
    this.createdAt = createdAt;
    this.isUnlocked = isUnlocked;
    this.mood = mood;
    this.priority = priority;
  }
  
  // 检查是否到期
  isExpired(): boolean {
    return Date.now() >= this.unlockDate;
  }
  
  // 获取剩余时间描述
  getRemainingTime(): string {
    const now = Date.now();
    const remaining = this.unlockDate - now;
    
    if (remaining <= 0) return '已到期';
    
    const days = Math.floor(remaining / (1000 * 60 * 60 * 24));
    const hours = Math.floor((remaining % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((remaining % (1000 * 60 * 60)) / (1000 * 60));
    
    if (days > 0) return `${days}天${hours}小时后解锁`;
    if (hours > 0) return `${hours}小时${minutes}分钟后解锁`;
    return `${minutes}分钟后解锁`;
  }
  
  // 获取解锁日期格式化
  getUnlockDateFormatted(): string {
    const date = new Date(this.unlockDate);
    return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
  }
  
  toJson(): ESObject {
    return {
      id: this.id,
      memoId: this.memoId,
      memoTitle: this.memoTitle,
      memoContent: this.memoContent,
      unlockDate: this.unlockDate,
      createdAt: this.createdAt,
      isUnlocked: this.isUnlocked,
      mood: this.mood,
      priority: this.priority
    };
  }
  
  static fromJson(json: ESObject): TimeCapsule {
    return new TimeCapsule(
      json['id'] as string,
      json['memoId'] as string,
      json['memoTitle'] as string,
      json['memoContent'] as string,
      json['unlockDate'] as number,
      json['createdAt'] as number,
      json['isUnlocked'] as boolean,
      json['mood'] as string,
      json['priority'] as number
    );
  }
  
  static generateId(): string {
    return 'capsule_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }
}
