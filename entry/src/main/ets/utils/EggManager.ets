/**
 * 彩蛋管理器 - 最小化版本
 * 提供基础的彩蛋功能
 */
import { BlindBoxReward, Rarity, BlindBoxPool } from '../model/BlindBox';
import { TimeCapsule } from '../model/TimeCapsule';
import { Achievement, AchievementCondition, AchievementPool } from '../model/Achievement';
import { WeatherConfig, EmotionWeather } from '../model/EmotionWeather';
import { Memo } from '../model/Memo';
import { StorageManager } from './StorageManager';

export class EggManager {
  private static instance: EggManager;
  private storageManager: StorageManager = StorageManager.getInstance();
  
  private constructor() {}
  
  static getInstance(): EggManager {
    if (!EggManager.instance) {
      EggManager.instance = new EggManager();
    }
    return EggManager.instance;
  }
  
  // 初始化（空实现，兼容接口）
  async init(): Promise<void> {}
  
  // ==================== 盲盒相关 ====================
  
  // 抽取盲盒奖励
  drawBlindBoxReward(): BlindBoxReward {
    return BlindBoxPool.drawRandom();
  }
  
  // 保存盲盒奖励
  async saveBlindBoxReward(reward: BlindBoxReward): Promise<void> {
    await this.storageManager.saveBlindBoxReward(reward);
    console.info('[EggManager] 盲盒奖励已保存:', reward.name);
  }
  
  // 获取盲盒奖励列表
  async getBlindBoxRewards(): Promise<BlindBoxReward[]> {
    return await this.storageManager.getBlindBoxRewards();
  }
  
  // ==================== 时间胶囊相关 ====================
  
  // 创建时间胶囊
  createTimeCapsule(
    memoId: string,
    memoTitle: string,
    memoContent: string,
    unlockDate: number,
    mood: string,
    priority: number
  ): TimeCapsule {
    return new TimeCapsule(
      TimeCapsule.generateId(),
      memoId,
      memoTitle,
      memoContent,
      unlockDate,
      Date.now(),
      false,
      mood,
      priority
    );
  }
  
  // 保存时间胶囊
  async saveTimeCapsule(capsule: TimeCapsule): Promise<void> {
    console.info('[EggManager] 时间胶囊:', capsule.memoTitle);
  }
  
  // 解锁时间胶囊
  async unlockTimeCapsule(capsuleId: string): Promise<void> {
    console.info('[EggManager] 解锁时间胶囊:', capsuleId);
  }
  
  // 获取已到期的时间胶囊
  async getExpiredCapsules(): Promise<TimeCapsule[]> {
    return [];
  }
  
  // ==================== 成就相关 ====================
  
  // 获取成就列表
  async getAchievements(): Promise<Achievement[]> {
    return AchievementPool.getInitialAchievements();
  }
  
  // 保存成就
  async saveAchievements(achievements: Achievement[]): Promise<void> {}
  
  // 检查成就进度
  async checkAchievements(memo: Memo, allMemos: Memo[]): Promise<Achievement[]> {
    const achievements = await this.getAchievements();
    const newlyUnlocked: Achievement[] = [];
    const now = new Date();
    const hour = now.getHours();
    
    for (const achievement of achievements) {
      if (achievement.isUnlocked) continue;
      
      switch (achievement.condition) {
        case AchievementCondition.LATE_NIGHT:
          if (hour >= 0 && hour < 4) {
            achievement.progress++;
          }
          break;
        case AchievementCondition.EARLY_MORNING:
          if (hour >= 5 && hour < 7) {
            achievement.progress++;
          }
          break;
        case AchievementCondition.FIRST_NOTE:
          if (allMemos.length === 1) {
            achievement.progress = 1;
          }
          break;
        case AchievementCondition.HUNDRED_NOTES:
          achievement.progress = allMemos.length;
          break;
        case AchievementCondition.MOOD_COLLECTOR:
        case AchievementCondition.RAINBOW_MOOD:
          const uniqueMoods = new Set<string>();
          for (const m of allMemos) {
            uniqueMoods.add(m.mood);
          }
          achievement.progress = uniqueMoods.size;
          break;
        case AchievementCondition.FISHING_MASTER:
          let fishingCount = 0;
          for (const m of allMemos) {
            if (m.title.includes('摸鱼') || m.content.includes('摸鱼') ||
                m.title.includes('划水') || m.content.includes('划水')) {
              fishingCount++;
            }
          }
          achievement.progress = fishingCount;
          break;
      }
      
      if (achievement.progress >= achievement.targetProgress && !achievement.isUnlocked) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = Date.now();
        newlyUnlocked.push(achievement);
      }
    }
    
    return newlyUnlocked;
  }
  
  // 检查连续打卡成就
  async checkDailyWriterAchievement(allMemos: Memo[]): Promise<Achievement | null> {
    return null;
  }
  
  // 检查连续开心记录成就
  async checkContinuousHappyAchievement(allMemos: Memo[]): Promise<Achievement | null> {
    return null;
  }
  
  // ==================== 情绪天气相关 ====================
  
  // 计算今日天气
  calculateTodayWeather(todayMemos: Memo[]): EmotionWeather {
    if (todayMemos.length === 0) {
      return WeatherConfig.getDefaultWeather();
    }
    
    const moods: string[] = [];
    for (const m of todayMemos) {
      moods.push(m.mood);
    }
    const avgMood = WeatherConfig.calculateAverageMood(moods);
    return WeatherConfig.calculateWeather(avgMood);
  }
}
