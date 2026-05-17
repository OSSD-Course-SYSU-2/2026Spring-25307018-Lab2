/**
 * 【记忆寻宝小游戏】寻宝管理器
 * 管理寻宝会话、线索生成和奖励发放
 */
import { TreasureHuntSession, TreasureClue, TreasureReward, TreasureHuntStats, ClueDifficulty, HuntStatus } from '../model/TreasureHunt';
import { Memo } from '../model/Memo';
import { StorageManager } from './StorageManager';
import { PlanetManager } from './PlanetManager';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

// 寻宝结果接口
interface HuntResult {
  success: boolean;
  reward: TreasureReward | null;
  message: string;
}

export class TreasureHuntManager {
  private static instance: TreasureHuntManager;
  private storageManager: StorageManager = StorageManager.getInstance();
  private planetManager: PlanetManager = PlanetManager.getInstance();
  private preferencesStore: preferences.Preferences | null = null;
  
  private readonly STORE_NAME: string = 'treasure_hunt_store';
  private readonly SESSION_KEY: string = 'treasure_hunt_session';
  private readonly STATS_KEY: string = 'treasure_hunt_stats';
  private initPromise: Promise<void> | null = null;
  
  private constructor() {}
  
  static getInstance(): TreasureHuntManager {
    if (!TreasureHuntManager.instance) {
      TreasureHuntManager.instance = new TreasureHuntManager();
    }
    return TreasureHuntManager.instance;
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
      console.info('[TreasureHuntManager] 初始化成功');
    } catch (error) {
      console.error('[TreasureHuntManager] 初始化失败:', error);
      this.initPromise = null;
      throw new Error('Failed to initialize TreasureHuntManager');
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
    throw new Error('TreasureHuntManager not initialized. Call init() first.');
  }
  
  // ==================== 寻宝会话管理 ====================
  
  /**
   * 开始新的寻宝会话
   * 从历史笔记库随机抽取1条作为宝藏笔记
   */
  async startNewHunt(): Promise<TreasureHuntSession | null> {
    const memos = await this.storageManager.getMemos();
    
    if (memos.length === 0) {
      console.info('[TreasureHuntManager] 没有笔记可供寻宝');
      return null;
    }
    
    // 随机选择一条笔记作为宝藏
    const randomIndex = Math.floor(Math.random() * memos.length);
    const treasureMemo = memos[randomIndex];
    
    // 生成线索
    const clues = this.generateClues(treasureMemo);
    
    const session = new TreasureHuntSession(
      TreasureHuntSession.generateId(),
      treasureMemo.id,
      clues,
      HuntStatus.PLAYING
    );
    
    // 保存会话
    await this.saveSession(session);
    
    console.info('[TreasureHuntManager] 新寻宝会话已创建，宝藏笔记:', treasureMemo.id);
    return session;
  }
  
  /**
   * 获取当前寻宝会话
   */
  async getCurrentSession(): Promise<TreasureHuntSession | null> {
    await this.ensureInitializedAsync();
    
    try {
      const jsonStr: string = this.preferencesStore!.getSync(this.SESSION_KEY, '') as string;
      if (!jsonStr) return null;
      
      const json: ESObject = JSON.parse(jsonStr) as ESObject;
      const session = TreasureHuntSession.fromJson(json);
      
      // 检查是否已过期（超过1小时）
      if (Date.now() - session.startTime > 3600000) {
        session.status = HuntStatus.TIMEOUT;
        return session;
      }
      
      return session;
    } catch (error) {
      console.error('[TreasureHuntManager] 获取会话失败:', error);
      return null;
    }
  }
  
  /**
   * 保存寻宝会话
   */
  async saveSession(session: TreasureHuntSession): Promise<void> {
    await this.ensureInitializedAsync();
    
    try {
      const jsonStr = JSON.stringify(session.toJson());
      this.preferencesStore!.putSync(this.SESSION_KEY, jsonStr);
      await this.preferencesStore!.flush();
      console.info('[TreasureHuntManager] 会话已保存');
    } catch (error) {
      console.error('[TreasureHuntManager] 保存会话失败:', error);
    }
  }
  
  /**
   * 清除当前会话
   */
  async clearSession(): Promise<void> {
    await this.ensureInitializedAsync();
    
    try {
      this.preferencesStore!.deleteSync(this.SESSION_KEY);
      await this.preferencesStore!.flush();
    } catch (error) {
      console.error('[TreasureHuntManager] 清除会话失败:', error);
    }
  }
  
  // ==================== 线索生成 ====================
  
  /**
   * 根据笔记生成线索
   */
  private generateClues(memo: Memo): TreasureClue[] {
    const clues: TreasureClue[] = [];
    const clueId = `clue_${Date.now()}`;
    
    // 1. 心情线索（简单）
    const moodClue = this.generateMoodClue(memo, `${clueId}_mood`);
    clues.push(moodClue);
    
    // 2. 时间线索（中等）
    const timeClue = this.generateTimeClue(memo, `${clueId}_time`);
    clues.push(timeClue);
    
    // 3. 标签线索（中等）
    if (memo.tags.length > 0) {
      const tagClue = this.generateTagClue(memo, `${clueId}_tag`);
      clues.push(tagClue);
    }
    
    // 4. 优先级线索（困难）
    const priorityClue = this.generatePriorityClue(memo, `${clueId}_priority`);
    clues.push(priorityClue);
    
    // 5. 内容关键词线索（困难）
    const keywordClue = this.generateKeywordClue(memo, `${clueId}_keyword`);
    clues.push(keywordClue);
    
    return clues;
  }
  
  /**
   * 生成心情线索
   */
  private generateMoodClue(memo: Memo, id: string): TreasureClue {
    let moodDesc = '心情神秘莫测';
    
    switch (memo.mood) {
      case '😊':
        moodDesc = '写这条笔记时心情很愉快呢~';
        break;
      case '😄':
        moodDesc = '当时笑得很开心哦！';
        break;
      case '😍':
        moodDesc = '充满了喜爱之情~';
        break;
      case '🥳':
        moodDesc = '在庆祝什么好事呢！';
        break;
      case '😎':
        moodDesc = '酷酷的心情~';
        break;
      case '😌':
        moodDesc = '平静祥和的心态';
        break;
      case '😐':
        moodDesc = '心情比较平淡';
        break;
      case '😔':
        moodDesc = '有些沮丧的心情';
        break;
      case '😢':
        moodDesc = '当时有点难过';
        break;
      case '😠':
        moodDesc = '带着一点怒气';
        break;
      case '😴':
        moodDesc = '困困的感觉~';
        break;
      case '🤔':
        moodDesc = '在思考什么呢？';
        break;
      default:
        moodDesc = '心情神秘莫测';
    }
    
    const content = `💡 心情提示：${moodDesc}`;
    
    return new TreasureClue(
      id,
      content,
      ClueDifficulty.EASY,
      'mood',
      true  // 心情线索默认显示
    );
  }
  
  /**
   * 生成时间线索
   */
  private generateTimeClue(memo: Memo, id: string): TreasureClue {
    const date = new Date(memo.createdAt);
    const hour = date.getHours();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    
    let timeHint = '';
    if (hour >= 0 && hour < 6) {
      timeHint = '在深夜悄悄写下的~';
    } else if (hour >= 6 && hour < 12) {
      timeHint = '上午的阳光时刻';
    } else if (hour >= 12 && hour < 18) {
      timeHint = '午后的时光';
    } else {
      timeHint = '傍晚或夜晚记录的';
    }
    
    const content = `📅 时间提示：${month}月${day}日，${timeHint}`;
    
    return new TreasureClue(
      id,
      content,
      ClueDifficulty.MEDIUM,
      'time',
      false,
      1  // 需要1个碎片揭示
    );
  }
  
  /**
   * 生成标签线索
   */
  private generateTagClue(memo: Memo, id: string): TreasureClue {
    const tag = memo.tags[0];
    const content = `🏷️ 标签提示：这条笔记和"${tag}"相关`;
    
    return new TreasureClue(
      id,
      content,
      ClueDifficulty.MEDIUM,
      'tag',
      false,
      2  // 需要2个碎片揭示
    );
  }
  
  /**
   * 生成优先级线索
   */
  private generatePriorityClue(memo: Memo, id: string): TreasureClue {
    let priorityName = '中';
    let priorityEmoji = '⭐⭐';
    
    if (memo.priority === 1) {
      priorityName = '低';
      priorityEmoji = '⭐';
    } else if (memo.priority === 3) {
      priorityName = '高';
      priorityEmoji = '⭐⭐⭐';
    }
    
    const content = `⚡ 优先级提示：${priorityEmoji} ${priorityName}优先级`;
    
    return new TreasureClue(
      id,
      content,
      ClueDifficulty.HARD,
      'priority',
      false,
      3  // 需要3个碎片揭示
    );
  }
  
  /**
   * 生成关键词线索
   */
  private generateKeywordClue(memo: Memo, id: string): TreasureClue {
    // 从标题或内容中提取关键词
    const text = memo.title + ' ' + memo.content;
    const words = text.split(/[\s,，。！？、]+/).filter((w: string): boolean => w.length >= 2);
    
    let keyword = '';
    if (words.length > 0) {
      // 随机选择一个词作为关键词提示
      const randomWord = words[Math.floor(Math.random() * words.length)];
      keyword = randomWord.substring(0, Math.min(3, randomWord.length));
    }
    
    const content = keyword ? 
      `🔍 关键词提示：包含"${keyword}"...` : 
      '🔍 关键词提示：内容很神秘~';
    
    return new TreasureClue(
      id,
      content,
      ClueDifficulty.HARD,
      'keyword',
      false,
      4  // 需要4个碎片揭示
    );
  }
  
  // ==================== 寻宝操作 ====================
  
  /**
   * 揭示线索（消耗碎片）
   */
  async revealClue(clueId: string): Promise<boolean> {
    const session = await this.getCurrentSession();
    if (!session) return false;
    
    const clue = session.clues.find((c: TreasureClue): boolean => c.id === clueId);
    if (!clue || clue.isRevealed) return false;
    
    // 检查碎片是否足够
    const available = await this.planetManager.getAvailableFragments();
    if (available < clue.cost) {
      console.info('[TreasureHuntManager] 碎片不足，无法揭示线索');
      return false;
    }
    
    // 消耗碎片
    const consumed = await this.planetManager.consumeFragments(clue.cost);
    if (!consumed) return false;
    
    // 揭示线索
    clue.isRevealed = true;
    session.fragmentsUsed += clue.cost;
    
    await this.saveSession(session);
    return true;
  }
  
  /**
   * 尝试找到宝藏
   */
  async attemptFind(memoId: string): Promise<HuntResult> {
    const session = await this.getCurrentSession();
    if (!session) {
      const result: HuntResult = { success: false, reward: null, message: '没有进行中的寻宝' };
      return result;
    }
    
    session.attempts++;
    
    if (memoId === session.treasureMemoId) {
      // 找到了！
      session.status = HuntStatus.FOUND;
      session.endTime = Date.now();
      
      // 计算奖励
      const treasureMemo = await this.storageManager.getMemoById(session.treasureMemoId);
      const reward = await this.calculateReward(treasureMemo, session);
      session.reward = reward;
      
      await this.saveSession(session);
      
      // 更新统计
      await this.updateStats(session, true);
      
      const result: HuntResult = { success: true, reward, message: '🎉 恭喜！你找到了宝藏笔记！' };
      return result;
    } else {
      // 没找到
      if (session.attempts >= session.maxAttempts) {
        session.status = HuntStatus.FAILED;
        session.endTime = Date.now();
        await this.saveSession(session);
        await this.updateStats(session, false);
        const result: HuntResult = { success: false, reward: null, message: '😢 很遗憾，寻宝失败了...' };
        return result;
      }
      
      await this.saveSession(session);
      const result: HuntResult = { 
        success: false, 
        reward: null, 
        message: `不对哦~还有${session.maxAttempts - session.attempts}次机会` 
      };
      return result;
    }
  }
  
  /**
   * 计算奖励
   * 成功找到宝藏笔记，仅奖励星球碎片、盲盒抽奖次数
   */
  private async calculateReward(memo: Memo | null, session: TreasureHuntSession): Promise<TreasureReward> {
    let fragments = 1;
    let blindBoxDraws = 1;
    let bonusReason = '';
    
    if (memo) {
      // 检查是否是凌晨笔记（夜猫子成就）
      const hour = new Date(memo.createdAt).getHours();
      if (hour >= 0 && hour < 5) {
        fragments += 1;
        blindBoxDraws += 1;
        bonusReason = '🌙 夜猫子加成！';
      }
      
      // 检查是否是高优先级笔记（奖励翻倍）
      if (memo.priority === 3) {
        fragments *= 2;
        blindBoxDraws *= 2;
        bonusReason += '⚡ 高优先级翻倍！';
      }
    }
    
    // 根据尝试次数调整奖励
    if (session.attempts === 1) {
      fragments += 1;
      bonusReason += '🎯 一次命中加成！';
    }
    
    return new TreasureReward(fragments, blindBoxDraws, bonusReason);
  }
  
  // ==================== 统计管理 ====================
  
  /**
   * 获取寻宝统计
   */
  async getStats(): Promise<TreasureHuntStats> {
    await this.ensureInitializedAsync();
    
    try {
      const jsonStr: string = this.preferencesStore!.getSync(this.STATS_KEY, '') as string;
      if (!jsonStr) return new TreasureHuntStats();
      
      const json: ESObject = JSON.parse(jsonStr) as ESObject;
      return TreasureHuntStats.fromJson(json);
    } catch (error) {
      console.error('[TreasureHuntManager] 获取统计失败:', error);
      return new TreasureHuntStats();
    }
  }
  
  /**
   * 更新寻宝统计
   */
  private async updateStats(session: TreasureHuntSession, success: boolean): Promise<void> {
    await this.ensureInitializedAsync();
    
    const stats = await this.getStats();
    
    stats.totalHunts++;
    if (success) {
      stats.successfulHunts++;
      if (session.reward) {
        stats.totalFragmentsEarned += session.reward.fragments;
        stats.totalBlindBoxDraws += session.reward.blindBoxDraws;
      }
    } else {
      stats.failedHunts++;
    }
    
    stats.lastHuntTime = Date.now();
    
    try {
      const jsonStr = JSON.stringify(stats.toJson());
      this.preferencesStore!.putSync(this.STATS_KEY, jsonStr);
      await this.preferencesStore!.flush();
    } catch (error) {
      console.error('[TreasureHuntManager] 保存统计失败:', error);
    }
  }
  
  /**
   * 检查夜猫子成就
   */
  async checkNightOwlAchievement(memo: Memo): Promise<boolean> {
    const hour = new Date(memo.createdAt).getHours();
    if (hour >= 0 && hour < 5) {
      const stats = await this.getStats();
      stats.nightOwlFinds++;
      
      await this.ensureInitializedAsync();
      const jsonStr = JSON.stringify(stats.toJson());
      this.preferencesStore!.putSync(this.STATS_KEY, jsonStr);
      await this.preferencesStore!.flush();
      
      return true;
    }
    return false;
  }
}
