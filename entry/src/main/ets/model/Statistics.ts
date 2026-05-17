// 统计数据模型
export class Statistics {
  totalMemos: number; // 笔记总数
  todayMemos: number; // 今日笔记数
  completedMemos: number; // 已完成笔记数
  pendingMemos: number; // 待处理笔记数
  
  // 心情分布
  moodDistribution: Map<string, number>; // 心情 -> 数量
  
  // 打卡统计（按日期）
  dailyStats: Map<string, number>; // 日期 -> 笔记数
  
  // 标签统计
  tagDistribution: Map<string, number>; // 标签 -> 数量
  
  // 优先级分布
  priorityDistribution: Map<number, number>; // 优先级 -> 数量
  
  // 最近7天趋势
  weeklyTrend: number[]; // 最近7天的笔记数量
  
  constructor() {
    this.totalMemos = 0;
    this.todayMemos = 0;
    this.completedMemos = 0;
    this.pendingMemos = 0;
    this.moodDistribution = new Map();
    this.dailyStats = new Map();
    this.tagDistribution = new Map();
    this.priorityDistribution = new Map();
    this.weeklyTrend = [0, 0, 0, 0, 0, 0, 0];
  }
  
  // 从备忘录列表生成统计数据
  static fromMemos(memos: Memo[]): Statistics {
    const stats = new Statistics();
    const today = new Date();
    const todayStr = `${today.getFullYear()}-${today.getMonth() + 1}-${today.getDate()}`;
    
    // 计算基础统计
    stats.totalMemos = memos.length;
    stats.completedMemos = memos.filter(memo => memo.isCompleted).length;
    stats.pendingMemos = memos.filter(memo => !memo.isCompleted).length;
    
    // 计算今日笔记
    stats.todayMemos = memos.filter(memo => {
      const memoDate = new Date(memo.createdAt);
      const memoDateStr = `${memoDate.getFullYear()}-${memoDate.getMonth() + 1}-${memoDate.getDate()}`;
      return memoDateStr === todayStr;
    }).length;
    
    // 计算心情分布
    memos.forEach(memo => {
      const count = stats.moodDistribution.get(memo.mood) || 0;
      stats.moodDistribution.set(memo.mood, count + 1);
    });
    
    // 计算标签分布
    memos.forEach(memo => {
      memo.tags.forEach(tag => {
        const count = stats.tagDistribution.get(tag) || 0;
        stats.tagDistribution.set(tag, count + 1);
      });
    });
    
    // 计算优先级分布
    memos.forEach(memo => {
      const count = stats.priorityDistribution.get(memo.priority) || 0;
      stats.priorityDistribution.set(memo.priority, count + 1);
    });
    
    // 计算每日统计（最近30天）
    const last30Days = new Date();
    last30Days.setDate(last30Days.getDate() - 30);
    
    memos.forEach(memo => {
      const memoDate = new Date(memo.createdAt);
      if (memoDate >= last30Days) {
        const dateStr = `${memoDate.getFullYear()}-${memoDate.getMonth() + 1}-${memoDate.getDate()}`;
        const count = stats.dailyStats.get(dateStr) || 0;
        stats.dailyStats.set(dateStr, count + 1);
      }
    });
    
    // 计算最近7天趋势
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
      stats.weeklyTrend[6 - i] = stats.dailyStats.get(dateStr) || 0;
    }
    
    return stats;
  }
  
  // 获取心情分布数组（用于图表）
  getMoodDistributionArray(): Array<{mood: string, count: number}> {
    const result: Array<{mood: string, count: number}> = [];
    this.moodDistribution.forEach((count, mood) => {
      result.push({ mood, count });
    });
    return result.sort((a, b) => b.count - a.count);
  }
  
  // 获取标签分布数组（用于图表）
  getTagDistributionArray(): Array<{tag: string, count: number}> {
    const result: Array<{tag: string, count: number}> = [];
    this.tagDistribution.forEach((count, tag) => {
      result.push({ tag, count });
    });
    return result.sort((a, b) => b.count - a.count).slice(0, 10); // 只取前10
  }
  
  // 获取优先级分布数组
  getPriorityDistributionArray(): Array<{priority: number, count: number}> {
    const result: Array<{priority: number, count: number}> = [];
    this.priorityDistribution.forEach((count, priority) => {
      result.push({ priority, count });
    });
    return result.sort((a, b) => a.priority - b.priority);
  }
  
  // 获取每日统计数组（最近7天）
  getDailyStatsArray(): Array<{date: string, count: number}> {
    const result: Array<{date: string, count: number}> = [];
    const today = new Date();
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
      const fullDateStr = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
      const count = this.dailyStats.get(fullDateStr) || 0;
      result.push({ date: dateStr, count });
    }
    
    return result;
  }
}