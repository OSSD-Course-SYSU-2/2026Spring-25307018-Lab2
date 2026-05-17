/**
 * 【笔记星球建造系统】星球管理器
 * 管理星球碎片的生成、存储和查询
 */
import { PlanetFragment, PlanetProgress, FragmentColor, FragmentSize } from '../model/PlanetFragment';
import { Memo } from '../model/Memo';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

// 阶段奖励接口
interface StageReward {
  clues: number;
  blindBoxDraws: number;
}

export class PlanetManager {
  private static instance: PlanetManager;
  private preferencesStore: preferences.Preferences | null = null;
  
  private readonly STORE_NAME: string = 'planet_store';
  private readonly FRAGMENTS_KEY: string = 'planet_fragments';
  private readonly PROGRESS_KEY: string = 'planet_progress';
  private initPromise: Promise<void> | null = null;
  
  private constructor() {}
  
  static getInstance(): PlanetManager {
    if (!PlanetManager.instance) {
      PlanetManager.instance = new PlanetManager();
    }
    return PlanetManager.instance;
  }
  
  // 初始化存储
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.preferencesStore) {
      return;
    }
    
    if (this.initPromise) {
      return this.initPromise;
    }
    
    this.initPromise = this.doInit(context);
    return this.initPromise;
  }
  
  private async doInit(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, this.STORE_NAME);
      console.info('[PlanetManager] 初始化成功');
    } catch (error) {
      console.error('[PlanetManager] 初始化失败:', error);
      this.initPromise = null;
      throw new Error('Failed to initialize PlanetManager');
    }
  }
  
  private async ensureInitializedAsync(): Promise<void> {
    if (this.preferencesStore) {
      return;
    }
    if (this.initPromise) {
      await this.initPromise;
      return;
    }
    throw new Error('PlanetManager not initialized. Call init() first.');
  }
  
  // ==================== 碎片生成 ====================
  
  /**
   * 为笔记生成星球碎片
   * 每保存一条笔记自动产出1块星球碎片
   */
  createFragmentForMemo(memo: Memo): PlanetFragment {
    const color = PlanetFragment.getColorFromMood(memo.mood);
    const size = PlanetFragment.getSizeFromPriority(memo.priority);
    const pattern = PlanetFragment.getPatternFromTags(memo.tags);
    const starIntensity = PlanetFragment.calculateStarIntensity(memo.priority);
    
    const fragment = new PlanetFragment(
      PlanetFragment.generateId(),
      memo.id,
      color,
      size,
      pattern,
      starIntensity,
      Date.now()
    );
    
    console.info('[PlanetManager] 为笔记生成碎片:', memo.id, '颜色:', color, '大小:', size);
    return fragment;
  }
  
  /**
   * 批量生成碎片（用于初始化）
   */
  createFragmentsForMemos(memos: Memo[]): PlanetFragment[] {
    return memos.map((memo: Memo): PlanetFragment => this.createFragmentForMemo(memo));
  }
  
  // ==================== 碎片存储 ====================
  
  /**
   * 保存单个碎片
   */
  async saveFragment(fragment: PlanetFragment): Promise<void> {
    const fragments = await this.getFragments();
    fragments.push(fragment);
    await this.saveFragments(fragments);
    
    // 更新进度
    await this.updateProgress(fragments);
    
    console.info('[PlanetManager] 碎片已保存:', fragment.id);
  }
  
  /**
   * 批量保存碎片
   */
  async saveFragments(fragments: PlanetFragment[]): Promise<void> {
    await this.ensureInitializedAsync();
    
    try {
      const jsonStr = JSON.stringify(fragments.map((f: PlanetFragment): ESObject => f.toJson()));
      this.preferencesStore!.putSync(this.FRAGMENTS_KEY, jsonStr);
      await this.preferencesStore!.flush();
      console.info('[PlanetManager] 碎片批量保存成功，数量:', fragments.length);
    } catch (error) {
      console.error('[PlanetManager] 保存碎片失败:', error);
    }
  }
  
  /**
   * 获取所有碎片
   */
  async getFragments(): Promise<PlanetFragment[]> {
    await this.ensureInitializedAsync();
    
    try {
      const jsonStr: string = this.preferencesStore!.getSync(this.FRAGMENTS_KEY, '[]') as string;
      const fragmentsArray: ESObject[] = JSON.parse(jsonStr) as ESObject[];
      return fragmentsArray.map((json: ESObject): PlanetFragment => PlanetFragment.fromJson(json));
    } catch (error) {
      console.error('[PlanetManager] 获取碎片失败:', error);
      return [];
    }
  }
  
  /**
   * 根据笔记ID获取碎片
   */
  async getFragmentByMemoId(memoId: string): Promise<PlanetFragment | null> {
    const fragments = await this.getFragments();
    const found = fragments.find((f: PlanetFragment): boolean => f.memoId === memoId);
    return found || null;
  }
  
  /**
   * 删除碎片（当笔记被删除时）
   */
  async deleteFragment(memoId: string): Promise<void> {
    const fragments = await this.getFragments();
    const filtered = fragments.filter((f: PlanetFragment): boolean => f.memoId !== memoId);
    await this.saveFragments(filtered);
    await this.updateProgress(filtered);
    console.info('[PlanetManager] 碎片已删除:', memoId);
  }
  
  // ==================== 进度管理 ====================
  
  /**
   * 获取星球进度
   */
  async getProgress(): Promise<PlanetProgress> {
    await this.ensureInitializedAsync();
    
    try {
      const jsonStr: string = this.preferencesStore!.getSync(this.PROGRESS_KEY, '') as string;
      if (!jsonStr) {
        return new PlanetProgress();
      }
      const json: ESObject = JSON.parse(jsonStr) as ESObject;
      return PlanetProgress.fromJson(json);
    } catch (error) {
      console.error('[PlanetManager] 获取进度失败:', error);
      return new PlanetProgress();
    }
  }
  
  /**
   * 更新星球进度
   */
  async updateProgress(fragments: PlanetFragment[]): Promise<PlanetProgress> {
    await this.ensureInitializedAsync();
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStart = today.getTime();
    
    const totalFragments = fragments.length;
    const todayFragments = fragments.filter((f: PlanetFragment): boolean => f.createdAt >= todayStart).length;
    
    // 计算完成度（假设100个碎片为完整星球）
    const completionPercent = Math.min(100, Math.round((totalFragments / 100) * 100));
    
    const progress = new PlanetProgress(
      totalFragments,
      todayFragments,
      '😊', // 平均心情需要单独计算
      completionPercent,
      Date.now()
    );
    
    try {
      const jsonStr = JSON.stringify(progress.toJson());
      this.preferencesStore!.putSync(this.PROGRESS_KEY, jsonStr);
      await this.preferencesStore!.flush();
    } catch (error) {
      console.error('[PlanetManager] 保存进度失败:', error);
    }
    
    return progress;
  }
  
  // ==================== 统计查询 ====================
  
  /**
   * 按颜色统计碎片
   */
  async getFragmentsByColor(): Promise<Map<FragmentColor, number>> {
    const fragments = await this.getFragments();
    const colorMap = new Map<FragmentColor, number>();
    
    for (const fragment of fragments) {
      const count = colorMap.get(fragment.color) || 0;
      colorMap.set(fragment.color, count + 1);
    }
    
    return colorMap;
  }
  
  /**
   * 按大小统计碎片
   */
  async getFragmentsBySize(): Promise<Map<FragmentSize, number>> {
    const fragments = await this.getFragments();
    const sizeMap = new Map<FragmentSize, number>();
    
    for (const fragment of fragments) {
      const count = sizeMap.get(fragment.size) || 0;
      sizeMap.set(fragment.size, count + 1);
    }
    
    return sizeMap;
  }
  
  /**
   * 获取今日碎片数
   */
  async getTodayFragmentCount(): Promise<number> {
    const fragments = await this.getFragments();
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStart = today.getTime();
    
    return fragments.filter((f: PlanetFragment): boolean => f.createdAt >= todayStart).length;
  }
  
  /**
   * 计算星球阶段（用于解锁奖励）
   * 每10个碎片为一个阶段
   */
  async getPlanetStage(): Promise<number> {
    const fragments = await this.getFragments();
    return Math.floor(fragments.length / 10) + 1;
  }
  
  /**
   * 检查是否解锁新阶段
   */
  async checkStageUnlock(previousStage: number): Promise<boolean> {
    const currentStage = await this.getPlanetStage();
    return currentStage > previousStage;
  }
  
  // ==================== 奖励相关 ====================
  
  /**
   * 获取阶段奖励
   * 星球阶段解锁仅奖励寻宝线索、盲盒抽奖次数
   */
  getStageReward(stage: number): StageReward {
    // 每个阶段奖励：1条寻宝线索 + 2次盲盒抽奖
    const reward: StageReward = {
      clues: stage,
      blindBoxDraws: stage * 2
    };
    return reward;
  }
  
  /**
   * 计算可用碎片数（用于兑换寻宝提示）
   */
  async getAvailableFragments(): Promise<number> {
    const fragments = await this.getFragments();
    return fragments.length;
  }
  
  /**
   * 消耗碎片（用于兑换精准提示）
   */
  async consumeFragments(count: number): Promise<boolean> {
    const available = await this.getAvailableFragments();
    if (available < count) {
      return false;
    }
    
    // 标记碎片为已消耗（实际实现中可以移除碎片或添加消耗标记）
    // 这里简化处理：移除最早的碎片
    const fragments = await this.getFragments();
    const remaining = fragments.slice(count);
    await this.saveFragments(remaining);
    
    console.info('[PlanetManager] 消耗碎片:', count, '剩余:', remaining.length);
    return true;
  }
}
