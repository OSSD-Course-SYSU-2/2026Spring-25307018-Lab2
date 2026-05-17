// 备忘录数据模型
export class Memo {
  id: string; // 唯一标识
  title: string; // 标题
  content: string; // 内容
  isCompleted: boolean; // 是否完成
  priority: number; // 优先级：1-低，2-中，3-高
  mood: string; // 心情表情
  tags: string[]; // 标签
  createdAt: number; // 创建时间戳
  updatedAt: number; // 更新时间戳
  dueDate?: number; // 截止日期（可选）
  reminderTime?: number; // 提醒时间（可选）
  color?: string; // 卡片颜色（可选）

  constructor(
    id: string = '',
    title: string = '',
    content: string = '',
    isCompleted: boolean = false,
    priority: number = 2,
    mood: string = '😊',
    tags: string[] = [],
    createdAt: number = Date.now(),
    updatedAt: number = Date.now(),
    dueDate?: number,
    reminderTime?: number,
    color?: string
  ) {
    this.id = id;
    this.title = title;
    this.content = content;
    this.isCompleted = isCompleted;
    this.priority = priority;
    this.mood = mood;
    this.tags = tags;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.dueDate = dueDate;
    this.reminderTime = reminderTime;
    this.color = color;
  }

  // 转换为JSON对象
  toJSON(): object {
    return {
      id: this.id,
      title: this.title,
      content: this.content,
      isCompleted: this.isCompleted,
      priority: this.priority,
      mood: this.mood,
      tags: this.tags,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      dueDate: this.dueDate,
      reminderTime: this.reminderTime,
      color: this.color
    };
  }

  // 从JSON对象创建Memo实例
  static fromJSON(json: any): Memo {
    return new Memo(
      json.id || '',
      json.title || '',
      json.content || '',
      json.isCompleted || false,
      json.priority || 2,
      json.mood || '😊',
      json.tags || [],
      json.createdAt || Date.now(),
      json.updatedAt || Date.now(),
      json.dueDate,
      json.reminderTime,
      json.color
    );
  }

  // 获取优先级文本
  getPriorityText(): string {
    switch (this.priority) {
      case 1:
        return '低';
      case 2:
        return '中';
      case 3:
        return '高';
      default:
        return '中';
    }
  }

  // 获取优先级颜色
  getPriorityColor(): string {
    switch (this.priority) {
      case 1:
        return '#4CAF50'; // 绿色
      case 2:
        return '#FF9800'; // 橙色
      case 3:
        return '#F44336'; // 红色
      default:
        return '#FF9800';
    }
  }

  // 格式化日期
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
  }

  // 获取创建日期字符串
  getCreatedDate(): string {
    return this.formatDate(this.createdAt);
  }

  // 获取截止日期字符串
  getDueDateString(): string | undefined {
    return this.dueDate ? this.formatDate(this.dueDate) : undefined;
  }

  // 检查是否过期
  isOverdue(): boolean {
    if (!this.dueDate) return false;
    return !this.isCompleted && this.dueDate < Date.now();
  }

  // 检查是否有提醒
  hasReminder(): boolean {
    return this.reminderTime !== undefined;
  }

  // 检查提醒是否已触发
  isReminderTriggered(): boolean {
    if (!this.reminderTime) return false;
    return this.reminderTime <= Date.now();
  }
}