/**
 * 备忘录数据模型
 * 定义备忘录的数据结构和基本操作
 */
export class Memo {
  // 唯一标识符
  id: string;
  
  // 标题
  title: string;
  
  // 内容
  content: string;
  
  // 是否已完成
  isCompleted: boolean;
  
  // 优先级 (1-低, 2-中, 3-高)
  priority: number;
  
  // 心情表情
  mood: string;
  
  // 标签列表
  tags: string[];
  
  // 创建时间戳
  createdAt: number;
  
  // 更新时间戳
  updatedAt: number;
  
  // 截止日期（可选）
  dueDate?: number;
  
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
    dueDate?: number
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
  }
  
  // 从JSON对象创建Memo实例
  static fromJson(json: ESObject): Memo {
    return new Memo(
      json['id'] as string || '',
      json['title'] as string || '',
      json['content'] as string || '',
      json['isCompleted'] as boolean || false,
      json['priority'] as number || 2,
      json['mood'] as string || '😊',
      json['tags'] as string[] || [],
      json['createdAt'] as number || Date.now(),
      json['updatedAt'] as number || Date.now(),
      json['dueDate'] as number | undefined
    );
  }
  
  // 转换为JSON对象
  toJson(): ESObject {
    const json: ESObject = {
      'id': this.id,
      'title': this.title,
      'content': this.content,
      'isCompleted': this.isCompleted,
      'priority': this.priority,
      'mood': this.mood,
      'tags': this.tags,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt
    };
    
    if (this.dueDate !== undefined) {
      json['dueDate'] = this.dueDate;
    }
    
    return json;
  }
  
  // 克隆当前实例
  clone(): Memo {
    return Memo.fromJson(this.toJson());
  }
  
  // 是否包含关键词
  containsKeyword(keyword: string): boolean {
    const lowerKeyword = keyword.toLowerCase();
    return (
      this.title.toLowerCase().includes(lowerKeyword) ||
      this.content.toLowerCase().includes(lowerKeyword) ||
      this.tags.some(tag => tag.toLowerCase().includes(lowerKeyword))
    );
  }
  
  // 获取摘要（前50个字符）
  getSummary(maxLength: number = 50): string {
    if (this.content.length <= maxLength) {
      return this.content;
    }
    return this.content.substring(0, maxLength) + '...';
  }
  
  // 是否过期
  isOverdue(): boolean {
    if (!this.dueDate) return false;
    return Date.now() > this.dueDate && !this.isCompleted;
  }
  
  // 获取优先级标签
  getPriorityLabel(): string {
    const labels = ['低', '中', '高'];
    return labels[this.priority - 1] || '中';
  }
}
