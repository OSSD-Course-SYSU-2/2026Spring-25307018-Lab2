import { Memo } from '../model/Memo';
import { MoodRecord } from '../model/MoodRecord';
import { Achievement } from '../model/Achievement';
import { Encouragement } from '../model/Encouragement';

// 数据存储管理类（简化版，使用内存存储）
export class StorageManager {
  private static instance: StorageManager;
  
  // 存储键名
  private static readonly STORAGE_KEYS = {
    MEMOS: 'fun_memo_memos',
    MOOD_RECORDS: 'fun_memo_mood_records',
    ACHIEVEMENTS: 'fun_memo_achievements',
    ENCOURAGEMENTS: 'fun_memo_encouragements',
    SETTINGS: 'fun_memo_settings',
    LAST_ENCOURAGEMENT_DATE: 'fun_memo_last_encouragement_date',
    STREAK_COUNT: 'fun_memo_streak_count',
    LAST_MEMO_DATE: 'fun_memo_last_memo_date'
  };

  // 内存存储
  private memoryStorage: Map<string, string> = new Map();

  private constructor() {
    this.initializeDefaultData();
  }

  // 获取单例实例
  public static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
    }
    return StorageManager.instance;
  }

  // 保存数据到存储
  private saveToStorage(key: string, data: any): void {
    try {
      const jsonString = JSON.stringify(data);
      this.memoryStorage.set(key, jsonString);
    } catch (error) {
      console.error(`保存数据到 ${key} 失败:`, error);
    }
  }

  // 从存储加载数据
  private loadFromStorage<T>(key: string, defaultValue: T): T {
    try {
      const jsonString = this.memoryStorage.get(key);
      if (jsonString) {
        return JSON.parse(jsonString);
      }
    } catch (error) {
      console.error(`从 ${key} 加载数据失败:`, error);
    }
    return defaultValue;
  }

  // 备忘录相关操作
  public async saveMemos(memos: Memo[]): Promise<void> {
    this.saveToStorage(StorageManager.STORAGE_KEYS.MEMOS, memos);
  }

  public async loadMemos(): Promise<Memo[]> {
    const memos = this.loadFromStorage<Memo[]>(StorageManager.STORAGE_KEYS.MEMOS, []);
    // 将普通对象转换为Memo实例
    return memos.map(memo => new Memo(
      memo.id,
      memo.title,
      memo.content,
      memo.isCompleted,
      memo.priority,
      memo.mood,
      memo.tags || [],
      memo.createdAt,
      memo.updatedAt,
      memo.dueDate,
      memo.reminderTime,
      memo.color
    ));
  }

  // 保存单个备忘录
  public async saveMemo(memo: Memo): Promise<void> {
    const memos = await this.loadMemos();
    const index = memos.findIndex(m => m.id === memo.id);
    if (index >= 0) {
      memos[index] = memo;
    } else {
      memos.push(memo);
    }
    await this.saveMemos(memos);
  }

  // 删除备忘录
  public async deleteMemo(id: string): Promise<void> {
    const memos = await this.loadMemos();
    const filteredMemos = memos.filter(memo => memo.id !== id);
    await this.saveMemos(filteredMemos);
  }

  // 获取单个备忘录
  public async getMemo(id: string): Promise<Memo | undefined> {
    const memos = await this.loadMemos();
    return memos.find(memo => memo.id === id);
  }

  // 获取所有备忘录
  public async getAllMemos(): Promise<Memo[]> {
    return await this.loadMemos();
  }

  // 获取统计数据
  public async getStats(): Promise<{
    totalMemos: number;
    completedMemos: number;
    pendingMemos: number;
    overdueMemos: number;
    highPriorityMemos: number;
    averageCompletionRate: number;
    streakCount: number;
    unlockedAchievements: number;
    totalAchievements: number;
    moodRecordsCount: number;
  }> {
    const memos = await this.loadMemos();
    const achievements = await this.loadAchievements();
    const moodRecords = await this.loadMoodRecords();
    
    const totalMemos = memos.length;
    const completedMemos = memos.filter(memo => memo.isCompleted).length;
    const pendingMemos = totalMemos - completedMemos;
    const overdueMemos = memos.filter(memo => memo.isOverdue()).length;
    const highPriorityMemos = memos.filter(memo => memo.priority === 3).length;
    const averageCompletionRate = totalMemos > 0 ? (completedMemos / totalMemos) * 100 : 0;
    const streakCount = await this.loadStreakCount();
    const unlockedAchievements = achievements.filter(a => a.isUnlocked).length;
    const totalAchievements = achievements.length;
    const moodRecordsCount = moodRecords.length;

    return {
      totalMemos,
      completedMemos,
      pendingMemos,
      overdueMemos,
      highPriorityMemos,
      averageCompletionRate,
      streakCount,
      unlockedAchievements,
      totalAchievements,
      moodRecordsCount
    };
  }

  // 心情记录相关操作
  public async saveMoodRecords(records: MoodRecord[]): Promise<void> {
    this.saveToStorage(StorageManager.STORAGE_KEYS.MOOD_RECORDS, records);
  }

  public async loadMoodRecords(): Promise<MoodRecord[]> {
    const records = this.loadFromStorage<MoodRecord[]>(StorageManager.STORAGE_KEYS.MOOD_RECORDS, []);
    // 将普通对象转换为MoodRecord实例
    return records.map(record => new MoodRecord(
      record.id,
      record.date,
      record.mood,
      record.moodLevel,
      record.memoId,
      record.note,
      record.createdAt
    ));
  }

  // 保存单个心情记录
  public async saveMoodRecord(record: MoodRecord): Promise<void> {
    const records = await this.loadMoodRecords();
    const index = records.findIndex(r => r.id === record.id);
    if (index >= 0) {
      records[index] = record;
    } else {
      records.push(record);
    }
    await this.saveMoodRecords(records);
  }

  // 根据日期获取心情记录
  public async getMoodRecordByDate(date: string): Promise<MoodRecord | undefined> {
    const records = await this.loadMoodRecords();
    return records.find(record => record.date === date);
  }

  // 成就相关操作
  public async saveAchievements(achievements: Achievement[]): Promise<void> {
    this.saveToStorage(StorageManager.STORAGE_KEYS.ACHIEVEMENTS, achievements);
  }

  public async loadAchievements(): Promise<Achievement[]> {
    const achievements = this.loadFromStorage<Achievement[]>(StorageManager.STORAGE_KEYS.ACHIEVEMENTS, []);
    // 将普通对象转换为Achievement实例
    return achievements.map(achievement => new Achievement(
      achievement.id,
      achievement.title,
      achievement.description,
      achievement.icon,
      achievement.type || '',
      achievement.requirement || 0,
      achievement.currentProgress || 0,
      achievement.isUnlocked || false,
      achievement.unlockedAt,
      achievement.rarity || 'common',
      achievement.category || 'memo'
    ));
  }

  // 获取所有成就
  public async getAchievements(): Promise<Achievement[]> {
    return await this.loadAchievements();
  }

  // 更新成就进度
  public async updateAchievementProgress(achievementId: string, progress: number): Promise<void> {
    const achievements = await this.loadAchievements();
    const achievement = achievements.find(a => a.id === achievementId);
    if (achievement) {
      achievement.currentProgress = progress;
      if (progress >= achievement.requirement && !achievement.isUnlocked) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = Date.now();
      }
      await this.saveAchievements(achievements);
    }
  }

  // 鼓励语相关操作
  public async saveEncouragements(encouragements: Encouragement[]): Promise<void> {
    this.saveToStorage(StorageManager.STORAGE_KEYS.ENCOURAGEMENTS, encouragements);
  }

  public async loadEncouragements(): Promise<Encouragement[]> {
    const encouragements = this.loadFromStorage<Encouragement[]>(StorageManager.STORAGE_KEYS.ENCOURAGEMENTS, []);
    // 将普通对象转换为Encouragement实例
    return encouragements.map(encouragement => new Encouragement(
      encouragement.id,
      encouragement.text,
      encouragement.category || 'daily',
      encouragement.mood || '😊',
      encouragement.usedCount || 0,
      encouragement.lastUsed
    ));
  }

  // 获取每日鼓励语
  public async getDailyEncouragement(): Promise<Encouragement | null> {
    const encouragements = await this.loadEncouragements();
    // 选择使用次数最少的鼓励语
    const sortedEncouragements = [...encouragements].sort((a, b) => a.usedCount - b.usedCount);
    if (sortedEncouragements.length > 0) {
      const encouragement = sortedEncouragements[0];
      encouragement.usedCount = (encouragement.usedCount || 0) + 1;
      encouragement.lastUsed = Date.now();
      await this.saveEncouragements(encouragements);
      return encouragement;
    }
    return null;
  }

  // 设置相关操作
  public async saveSettings(settings: any): Promise<void> {
    this.saveToStorage(StorageManager.STORAGE_KEYS.SETTINGS, settings);
  }

  public async loadSettings(): Promise<any> {
    return this.loadFromStorage(StorageManager.STORAGE_KEYS.SETTINGS, {
      theme: 'light',
      notificationEnabled: true,
      dailyReminderTime: '20:00',
      streakNotifications: true,
      achievementNotifications: true
    });
  }

  // 连续天数相关操作
  public async saveStreakCount(count: number): Promise<void> {
    this.saveToStorage(StorageManager.STORAGE_KEYS.STREAK_COUNT, count);
  }

  public async loadStreakCount(): Promise<number> {
    return this.loadFromStorage<number>(StorageManager.STORAGE_KEYS.STREAK_COUNT, 0);
  }

  // 最后备忘录日期相关操作
  public async saveLastMemoDate(date: Date): Promise<void> {
    this.saveToStorage(StorageManager.STORAGE_KEYS.LAST_MEMO_DATE, date.toISOString());
  }

  public async loadLastMemoDate(): Promise<Date | null> {
    const dateString = this.loadFromStorage<string>(StorageManager.STORAGE_KEYS.LAST_MEMO_DATE, '');
    return dateString ? new Date(dateString) : null;
  }

  // 最后鼓励日期相关操作
  public async saveLastEncouragementDate(date: Date): Promise<void> {
    this.saveToStorage(StorageManager.STORAGE_KEYS.LAST_ENCOURAGEMENT_DATE, date.toISOString());
  }

  public async loadLastEncouragementDate(): Promise<Date | null> {
    const dateString = this.loadFromStorage<string>(StorageManager.STORAGE_KEYS.LAST_ENCOURAGEMENT_DATE, '');
    return dateString ? new Date(dateString) : null;
  }

  // 初始化默认数据
  private async initializeDefaultData(): Promise<void> {
    // 初始化默认成就
    const defaultAchievements: Achievement[] = [
      new Achievement(
        'achievement_1',
        '首次记录',
        '创建第一个备忘录',
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
        'achievement_2',
        '坚持不懈',
        '连续记录7天',
        '🔥',
        'streak',
        7,
        0,
        false,
        undefined,
        'rare',
        'streak'
      ),
      new Achievement(
        'achievement_3',
        '任务达人',
        '完成10个备忘录',
        '✅',
        'completion',
        10,
        0,
        false,
        undefined,
        'rare',
        'memo'
      ),
      new Achievement(
        'achievement_4',
        '心情记录者',
        '记录10次心情',
        '😊',
        'mood_count',
        10,
        0,
        false,
        undefined,
        'common',
        'mood'
      ),
      new Achievement(
        'achievement_5',
        '完美主义者',
        '完成所有高优先级任务',
        '⭐',
        'priority_completion',
        5,
        0,
        false,
        undefined,
        'epic',
        'challenge'
      ),
      new Achievement(
        'achievement_6',
        '时间管理大师',
        '连续30天记录',
        '⏰',
        'long_streak',
        30,
        0,
        false,
        undefined,
        'legendary',
        'streak'
      )
    ];

    // 初始化默认鼓励语
    const defaultEncouragements: Encouragement[] = [
      new Encouragement('encouragement_1', '今天又是美好的一天！继续加油！', 'daily'),
      new Encouragement('encouragement_2', '你已经完成了今天的任务，真棒！', 'completion'),
      new Encouragement('encouragement_3', '坚持就是胜利，继续保持！', 'streak'),
      new Encouragement('encouragement_4', '恭喜你解锁了新成就！', 'achievement'),
      new Encouragement('encouragement_5', '你的努力正在改变一切！', 'motivation')
    ];

    // 检查是否已初始化
    const existingAchievements = await this.loadAchievements();
    if (existingAchievements.length === 0) {
      await this.saveAchievements(defaultAchievements);
    }

    const existingEncouragements = await this.loadEncouragements();
    if (existingEncouragements.length === 0) {
      await this.saveEncouragements(defaultEncouragements);
    }

    // 初始化默认设置
    const existingSettings = await this.loadSettings();
    if (!existingSettings.theme) {
      await this.saveSettings({
        theme: 'light',
        notificationEnabled: true,
        dailyReminderTime: '20:00',
        streakNotifications: true,
        achievementNotifications: true
      });
    }
  }

  // 清理所有数据（用于测试）
  public async clearAllData(): Promise<void> {
    try {
      this.memoryStorage.clear();
    } catch (error) {
      console.error('清理数据失败:', error);
    }
  }
}