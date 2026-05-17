/**
 * 统计数据模型
 * 用于计算和存储备忘录的各种统计信息
 */
import { Memo } from './Memo';

// 定义图表数据项接口
export interface ChartDataItem {
  mood?: string;
  tag?: string;
  priority?: number;
  date?: string;
  count: number;
}

export class Statistics {
  // 总笔记数
  totalMemos: number = 0;
  
  // 已完成笔记数
  completedMemos: number = 0;
  
  // 今日笔记数
  todayMemos: number = 0;
  
  // 心情分布 Map<心情, 数量>
  moodDistribution: Map<string, number> = new Map();
  
  // 标签分布 Map<标签, 数量>
  tagDistribution: Map<string, number> = new Map();
  
  // 优先级分布 Map<优先级, 数量>
  priorityDistribution: Map<number, number> = new Map();
  
  // 最近7天的笔记数
  last7DaysMemos: number = 0;
  
  // 连续打卡天数
  streakDays: number = 0;
  
  // 每日统计 Map<日期字符串, 数量>
  dailyStats: Map<string, number> = new Map();
  
  constructor() {}
  
  // 从备忘录列表生成统计数据
  static fromMemos(memos: Memo[]): Statistics {
    const stats = new Statistics();
    const now = Date.now();
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStart = today.getTime();
    const sevenDaysAgo = todayStart - 7 * 24 * 60 * 60 * 1000;
    
    stats.totalMemos = memos.length;
    stats.completedMemos = memos.filter((m: Memo) => m.isCompleted).length;
    stats.todayMemos = memos.filter((m: Memo) => m.createdAt >= todayStart).length;
    stats.last7DaysMemos = memos.filter((m: Memo) => m.createdAt >= sevenDaysAgo).length;
    
    // 统计心情分布
    memos.forEach((memo: Memo) => {
      const count = stats.moodDistribution.get(memo.mood) || 0;
      stats.moodDistribution.set(memo.mood, count + 1);
    });
    
    // 统计标签分布
    memos.forEach((memo: Memo) => {
      memo.tags.forEach((tag: string) => {
        const count = stats.tagDistribution.get(tag) || 0;
        stats.tagDistribution.set(tag, count + 1);
      });
    });
    
    // 统计优先级分布
    memos.forEach((memo: Memo) => {
      const count = stats.priorityDistribution.get(memo.priority) || 0;
      stats.priorityDistribution.set(memo.priority, count + 1);
    });
    
    // 统计每日笔记数
    memos.forEach((memo: Memo) => {
      const date = new Date(memo.createdAt);
      const dateStr = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
      const count = stats.dailyStats.get(dateStr) || 0;
      stats.dailyStats.set(dateStr, count + 1);
    });
    
    // 计算连续打卡天数
    stats.streakDays = stats.calculateStreak(memos);
    
    return stats;
  }
  
  // 计算连续打卡天数
  private calculateStreak(memos: Memo[]): number {
    if (memos.length === 0) return 0;
    
    // 按日期分组，格式化为 YYYY-MM-DD
    const dateSet = new Set<string>();
    memos.forEach((memo: Memo) => {
      const date = new Date(memo.createdAt);
      const dateStr = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
      dateSet.add(dateStr);
    });
    
    // 检查连续天数
    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    // 从今天开始往前检查
    for (let i = 0; i < 365; i++) {
      const checkDate = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
      const dateStr = `${checkDate.getFullYear()}-${(checkDate.getMonth() + 1).toString().padStart(2, '0')}-${checkDate.getDate().toString().padStart(2, '0')}`;
      
      if (dateSet.has(dateStr)) {
        streak++;
      } else {
        // 如果某一天没有记录，则中断连续计数
        // 但如果是今天没有记录，仍然可以继续检查昨天
        if (i === 0) {
          // 今天没有记录，继续检查昨天
          continue;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }
  
  // 获取心情分布数组（用于图表）
  getMoodDistributionArray(): ChartDataItem[] {
    const array: ChartDataItem[] = [];
    this.moodDistribution.forEach((count: number, mood: string) => {
      array.push({ mood: mood, count: count });
    });
    return array.sort((a: ChartDataItem, b: ChartDataItem) => b.count - a.count);
  }
  
  // 获取标签分布数组（用于图表）
  getTagDistributionArray(): ChartDataItem[] {
    const array: ChartDataItem[] = [];
    this.tagDistribution.forEach((count: number, tag: string) => {
      array.push({ tag: tag, count: count });
    });
    return array.sort((a: ChartDataItem, b: ChartDataItem) => b.count - a.count);
  }
  
  // 获取优先级分布数组（用于图表）
  getPriorityDistributionArray(): ChartDataItem[] {
    const array: ChartDataItem[] = [];
    this.priorityDistribution.forEach((count: number, priority: number) => {
      array.push({ priority: priority, count: count });
    });
    return array.sort((a: ChartDataItem, b: ChartDataItem) => (a.priority || 0) - (b.priority || 0));
  }
  
  // 获取最近7天每日统计数组
  getDailyStatsArray(): ChartDataItem[] {
    const array: ChartDataItem[] = [];
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    // 从最近7天开始计算
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
      const dateStr = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
      const displayDate = `${date.getMonth() + 1}/${date.getDate()}`;
      const count = this.dailyStats.get(dateStr) || 0;
      array.push({ date: displayDate, count: count });
    }
    
    return array;
  }
  
  // 获取完成率
  getCompletionRate(): number {
    if (this.totalMemos === 0) return 0;
    return Math.round((this.completedMemos / this.totalMemos) * 100);
  }
  
  // 获取最常用心情
  getMostCommonMood(): string {
    let maxCount = 0;
    let mostCommon = '😊';
    
    this.moodDistribution.forEach((count: number, mood: string) => {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = mood;
      }
    });
    
    return mostCommon;
  }
  
  // 获取最常用标签
  getMostCommonTags(count: number = 5): string[] {
    return this.getTagDistributionArray()
      .slice(0, count)
      .map((item: ChartDataItem) => item.tag || '');
  }
}
