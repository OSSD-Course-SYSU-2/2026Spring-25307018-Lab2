/**
 * 存储管理器
 * 使用Preferences API实现本地数据持久化
 */
import { Memo } from '../model/Memo';
import { BlindBoxReward } from '../model/BlindBox';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export class StorageManager {
  private static instance: StorageManager;
  private preferencesStore: preferences.Preferences | null = null;
  private readonly STORE_NAME: string = 'memo_store';
  private readonly MEMO_KEY: string = 'memos';
  private readonly BLIND_BOX_KEY: string = 'blind_box_rewards';
  private initPromise: Promise<void> | null = null;
  
  // 私有构造函数（单例模式）
  private constructor() {}
  
  // 获取单例实例
  static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
    }
    return StorageManager.instance;
  }
  
  // 初始化存储
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.preferencesStore) {
      return; // 已经初始化
    }
    
    if (this.initPromise) {
      return this.initPromise; // 正在初始化，等待完成
    }
    
    this.initPromise = this.doInit(context);
    return this.initPromise;
  }
  
  private async doInit(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, this.STORE_NAME);
      console.info('[StorageManager] 初始化成功');
    } catch (error) {
      console.error('[StorageManager] 初始化失败:', error);
      this.initPromise = null;
      throw new Error('Failed to initialize StorageManager');
    }
  }
  
  // 确保已初始化（异步等待）
  private async ensureInitializedAsync(): Promise<void> {
    if (this.preferencesStore) {
      return;
    }
    if (this.initPromise) {
      await this.initPromise;
      return;
    }
    throw new Error('StorageManager not initialized. Call init() first.');
  }
  
  // 确保已初始化（同步检查）
  private ensureInitialized(): void {
    if (!this.preferencesStore) {
      throw new Error('StorageManager not initialized. Call init() first.');
    }
  }
  
  // 获取所有备忘录
  async getMemos(): Promise<Memo[]> {
    await this.ensureInitializedAsync();
    
    try {
      const memosJson: string = this.preferencesStore!.getSync(this.MEMO_KEY, '[]') as string;
      console.info('[StorageManager] 读取到的JSON:', memosJson);
      const memosArray: ESObject[] = JSON.parse(memosJson) as ESObject[];
      const memos = memosArray.map((json: ESObject): Memo => Memo.fromJson(json));
      console.info('[StorageManager] 解析出的笔记数量:', memos.length);
      return memos;
    } catch (error) {
      console.error('[StorageManager] 获取笔记失败:', error);
      return [];
    }
  }
  
  // 保存备忘录（新增或更新）
  async saveMemo(memo: Memo): Promise<void> {
    await this.ensureInitializedAsync();
    
    try {
      const memos: Memo[] = await this.getMemos();
      const existingIndex: number = memos.findIndex((m: Memo): boolean => m.id === memo.id);
      
      if (existingIndex >= 0) {
        // 更新现有备忘录
        memos[existingIndex] = memo;
      } else {
        // 添加新备忘录
        memos.push(memo);
      }
      
      await this.saveMemos(memos);
      console.info('[StorageManager] 笔记保存成功:', memo.id);
    } catch (error) {
      console.error('[StorageManager] 保存笔记失败:', error);
      throw new Error('Failed to save memo');
    }
  }
  
  // 删除备忘录
  async deleteMemo(memoId: string): Promise<void> {
    await this.ensureInitializedAsync();
    
    try {
      const memos: Memo[] = await this.getMemos();
      const filteredMemos: Memo[] = memos.filter((m: Memo): boolean => m.id !== memoId);
      await this.saveMemos(filteredMemos);
      console.info('[StorageManager] 笔记删除成功:', memoId);
    } catch (error) {
      console.error('[StorageManager] 删除笔记失败:', error);
      throw new Error('Failed to delete memo');
    }
  }
  
  // 批量保存备忘录
  private async saveMemos(memos: Memo[]): Promise<void> {
    await this.ensureInitializedAsync();
    
    try {
      const memosJson: string = JSON.stringify(memos.map((m: Memo): ESObject => m.toJson()));
      this.preferencesStore!.putSync(this.MEMO_KEY, memosJson);
      // 【关键修复】必须调用flush()将数据持久化到存储文件
      await this.preferencesStore!.flush();
      console.info('Memos flushed to storage, count:', memos.length);
    } catch (error) {
      console.error('Failed to save memos:', error);
      throw new Error('Failed to save memos');
    }
  }
  
  // 根据ID获取备忘录
  async getMemoById(memoId: string): Promise<Memo | null> {
    const memos: Memo[] = await this.getMemos();
    const found: Memo | undefined = memos.find((m: Memo): boolean => m.id === memoId);
    return found || null;
  }
  
  // 搜索备忘录
  async searchMemos(keyword: string): Promise<Memo[]> {
    const memos: Memo[] = await this.getMemos();
    if (!keyword.trim()) return memos;
    
    return memos.filter((memo: Memo): boolean => memo.containsKeyword(keyword));
  }
  
  // 按心情筛选
  async getMemosByMood(mood: string): Promise<Memo[]> {
    const memos: Memo[] = await this.getMemos();
    return memos.filter((m: Memo): boolean => m.mood === mood);
  }
  
  // 按标签筛选
  async getMemosByTag(tag: string): Promise<Memo[]> {
    const memos: Memo[] = await this.getMemos();
    return memos.filter((m: Memo): boolean => m.tags.includes(tag));
  }
  
  // 按优先级筛选
  async getMemosByPriority(priority: number): Promise<Memo[]> {
    const memos: Memo[] = await this.getMemos();
    return memos.filter((m: Memo): boolean => m.priority === priority);
  }
  
  // 获取已完成的备忘录
  async getCompletedMemos(): Promise<Memo[]> {
    const memos: Memo[] = await this.getMemos();
    return memos.filter((m: Memo): boolean => m.isCompleted);
  }
  
  // 获取未完成的备忘录
  async getUncompletedMemos(): Promise<Memo[]> {
    const memos: Memo[] = await this.getMemos();
    return memos.filter((m: Memo): boolean => !m.isCompleted);
  }
  
  // 清空所有数据
  async clearAll(): Promise<void> {
    await this.ensureInitializedAsync();
    
    try {
      this.preferencesStore!.deleteSync(this.MEMO_KEY);
      // 【关键修复】必须调用flush()将删除操作持久化
      await this.preferencesStore!.flush();
      console.info('[StorageManager] 所有数据已清空');
    } catch (error) {
      console.error('[StorageManager] 清空数据失败:', error);
      throw new Error('Failed to clear memos');
    }
  }
  
  // 导出数据（用于备份）
  async exportData(): Promise<string> {
    const memos: Memo[] = await this.getMemos();
    return JSON.stringify(memos.map((m: Memo): ESObject => m.toJson()), null, 2);
  }
  
  // 导入数据（用于恢复）
  async importData(jsonData: string): Promise<void> {
    try {
      const memosArray: ESObject[] = JSON.parse(jsonData) as ESObject[];
      const memos: Memo[] = memosArray.map((json: ESObject): Memo => Memo.fromJson(json));
      await this.saveMemos(memos);
      console.info('Data imported successfully');
    } catch (error) {
      console.error('Failed to import data:', error);
      throw new Error('Failed to import data');
    }
  }
  
  // ==================== 盲盒奖励相关 ====================
  
  // 获取所有盲盒奖励
  async getBlindBoxRewards(): Promise<BlindBoxReward[]> {
    await this.ensureInitializedAsync();
    
    try {
      const jsonStr: string = this.preferencesStore!.getSync(this.BLIND_BOX_KEY, '[]') as string;
      console.info('[StorageManager] 盲盒奖励JSON:', jsonStr);
      const rewardsArray: ESObject[] = JSON.parse(jsonStr) as ESObject[];
      const rewards = rewardsArray.map((json: ESObject): BlindBoxReward => BlindBoxReward.fromJson(json));
      console.info('[StorageManager] 获取盲盒奖励数量:', rewards.length);
      return rewards;
    } catch (error) {
      console.error('[StorageManager] 获取盲盒奖励失败:', error);
      return [];
    }
  }
  
  // 保存盲盒奖励
  async saveBlindBoxReward(reward: BlindBoxReward): Promise<void> {
    await this.ensureInitializedAsync();
    
    try {
      const rewards: BlindBoxReward[] = await this.getBlindBoxRewards();
      console.info('[StorageManager] 当前盲盒奖励数量:', rewards.length);
      rewards.push(reward);
      console.info('[StorageManager] 添加后盲盒奖励数量:', rewards.length);
      const jsonStr: string = JSON.stringify(rewards.map((r: BlindBoxReward): ESObject => r.toJson()));
      console.info('[StorageManager] 保存的JSON长度:', jsonStr.length);
      this.preferencesStore!.putSync(this.BLIND_BOX_KEY, jsonStr);
      await this.preferencesStore!.flush();
      console.info('[StorageManager] 盲盒奖励保存成功:', reward.name);
    } catch (error) {
      console.error('[StorageManager] 保存盲盒奖励失败:', error);
    }
  }
}
