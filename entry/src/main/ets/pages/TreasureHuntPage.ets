/**
 * 【记忆寻宝小游戏】寻宝游戏页面
 * 从历史笔记库随机抽取宝藏笔记，根据线索找到它
 */
import { Colors } from '../constants/Colors';
import { StorageManager } from '../utils/StorageManager';
import { TreasureHuntManager } from '../utils/TreasureHuntManager';
import { PlanetManager } from '../utils/PlanetManager';
import { TreasureHuntSession, TreasureClue, TreasureHuntStats, HuntStatus, ClueDifficulty } from '../model/TreasureHunt';
import { Memo } from '../model/Memo';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct TreasureHuntPage {
  @State private session: TreasureHuntSession | null = null;
  @State private stats: TreasureHuntStats = new TreasureHuntStats();
  @State private memos: Memo[] = [];
  @State private isLoading: boolean = true;
  @State private selectedMemoId: string = '';
  @State private availableFragments: number = 0;
  @State private showResult: boolean = false;
  @State private resultMessage: string = '';
  @State private resultSuccess: boolean = false;
  
  // 【新增】动画状态
  @State private pageOpacity: number = 0;
  
  private storageManager: StorageManager = StorageManager.getInstance();
  private treasureHuntManager: TreasureHuntManager = TreasureHuntManager.getInstance();
  private planetManager: PlanetManager = PlanetManager.getInstance();
  
  aboutToAppear() {
    this.loadData();
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }
  
  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      this.memos = await this.storageManager.getMemos();
      this.stats = await this.treasureHuntManager.getStats();
      this.availableFragments = await this.planetManager.getAvailableFragments();
      
      // 获取当前会话或开始新会话
      this.session = await this.treasureHuntManager.getCurrentSession();
      if (!this.session || this.session.status !== HuntStatus.PLAYING) {
        await this.startNewHunt();
      }
    } catch (error) {
      console.error('加载寻宝数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  async startNewHunt(): Promise<void> {
    if (this.memos.length === 0) {
      prompt.showToast({ message: '没有笔记可供寻宝，先去写几条笔记吧~', duration: 2000 });
      return;
    }
    
    this.session = await this.treasureHuntManager.startNewHunt();
    this.showResult = false;
    this.selectedMemoId = '';
    
    if (!this.session) {
      prompt.showToast({ message: '寻宝初始化失败', duration: 2000 });
    }
  }
  
  async revealClue(clue: TreasureClue): Promise<void> {
    if (clue.isRevealed) return;
    
    if (this.availableFragments < clue.cost) {
      prompt.showToast({ message: `碎片不足！需要${clue.cost}块碎片`, duration: 2000 });
      return;
    }
    
    const success = await this.treasureHuntManager.revealClue(clue.id);
    if (success) {
      this.availableFragments = await this.planetManager.getAvailableFragments();
      // 刷新会话
      this.session = await this.treasureHuntManager.getCurrentSession();
      prompt.showToast({ message: '线索已揭示！', duration: 1500 });
    }
  }
  
  async attemptFind(): Promise<void> {
    if (!this.selectedMemoId) {
      prompt.showToast({ message: '请选择一条笔记作为答案', duration: 2000 });
      return;
    }
    
    const result = await this.treasureHuntManager.attemptFind(this.selectedMemoId);
    
    this.resultSuccess = result.success;
    this.resultMessage = result.message;
    this.showResult = true;
    
    // 刷新统计
    this.stats = await this.treasureHuntManager.getStats();
    
    if (result.success && result.reward) {
      // 显示奖励
      prompt.showToast({
        message: `获得 ${result.reward.fragments} 碎片 + ${result.reward.blindBoxDraws} 次抽奖！`,
        duration: 3000
      });
    }
  }
  
  // 获取难度颜色
  getDifficultyColor(difficulty: ClueDifficulty): string {
    switch (difficulty) {
      case ClueDifficulty.EASY:
        return '#52C41A';
      case ClueDifficulty.MEDIUM:
        return '#FAAD14';
      case ClueDifficulty.HARD:
        return '#FF4D4F';
      default:
        return '#888888';
    }
  }
  
  // 获取难度文字
  getDifficultyText(difficulty: ClueDifficulty): string {
    switch (difficulty) {
      case ClueDifficulty.EASY:
        return '简单';
      case ClueDifficulty.MEDIUM:
        return '中等';
      case ClueDifficulty.HARD:
        return '困难';
      default:
        return '未知';
    }
  }
  
  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      Row() {
        Button('返回')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
          .margin({ left: 16 })
        
        Text('🗺️ 记忆寻宝')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('新寻宝')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.startNewHunt())
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Colors.SURFACE)
      .shadow({ radius: 4, color: Colors.SHADOW })
      
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color(Colors.PRIMARY)
            .width(48)
            .height(48)
          Text('寻宝准备中...')
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Colors.BACKGROUND)
      } else if (this.memos.length === 0) {
        // 无笔记提示
        Column() {
          Text('📭')
            .fontSize(64)
          Text('还没有笔记可以寻宝')
            .fontSize(16)
            .fontColor(Colors.TEXT_SECONDARY)
            .margin({ top: 16 })
          Button('去写笔记')
            .fontSize(14)
            .fontColor(Colors.TEXT_ON_PRIMARY)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(20)
            .margin({ top: 20 })
            .onClick(() => router.pushUrl({ url: 'pages/CreateMemo' }))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Colors.BACKGROUND)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 寻宝状态卡片
            if (this.session) {
              Column() {
                Row() {
                  Text('🎯 寻宝进行中')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Colors.TEXT_PRIMARY)
                    .layoutWeight(1)
                  
                  Text(`剩余机会: ${this.session.maxAttempts - this.session.attempts}`)
                    .fontSize(14)
                    .fontColor(Colors.WARNING)
                }
                .width('100%')
                .margin({ bottom: 16 })
                
                // 线索列表
                Text('📜 线索提示')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .margin({ bottom: 8 })
                
                Column({ space: 12 }) {
                  ForEach(this.session.clues, (clue: TreasureClue) => {
                    this.ClueBuilder(clue)
                  })
                }
              }
              .padding(20)
              .backgroundColor(Colors.SURFACE)
              .borderRadius(16)
              .shadow({ radius: 8, color: Colors.SHADOW })
              .margin({ top: 16, left: 16, right: 16 })
            }
            
            // 碎片余额
            Column() {
              Row() {
                Text('💎 可用碎片')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                
                Blank()
                
                Text(`${this.availableFragments} 块`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.PRIMARY)
              }
              .width('100%')
            }
            .padding(16)
            .backgroundColor(Colors.SURFACE)
            .borderRadius(12)
            .margin({ left: 16, right: 16 })
            
            // 笔记选择
            Column() {
              Text('🔍 选择你认为是宝藏的笔记')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ bottom: 12 })
              
              Column({ space: 8 }) {
                ForEach(this.memos.slice(0, 10), (memo: Memo) => {
                  this.MemoOptionBuilder(memo)
                })
              }
            }
            .padding(20)
            .backgroundColor(Colors.SURFACE)
            .borderRadius(16)
            .shadow({ radius: 8, color: Colors.SHADOW })
            .margin({ left: 16, right: 16 })
            
            // 确认按钮
            Button('确认寻宝', { type: ButtonType.Capsule })
              .fontSize(16)
              .fontColor(Colors.TEXT_ON_PRIMARY)
              .backgroundColor(Colors.PRIMARY)
              .width('90%')
              .height(48)
              .enabled(this.selectedMemoId !== '' && this.session?.status === HuntStatus.PLAYING)
              .onClick(() => this.attemptFind())
            
            // 结果显示
            if (this.showResult) {
              Column() {
                Text(this.resultSuccess ? '🎉' : '😢')
                  .fontSize(48)
                
                Text(this.resultMessage)
                  .fontSize(16)
                  .fontColor(this.resultSuccess ? Colors.SUCCESS : Colors.ERROR)
                  .margin({ top: 12 })
                  .textAlign(TextAlign.Center)
                
                if (this.resultSuccess && this.session?.reward) {
                  Column({ space: 8 }) {
                    Text('🎁 获得奖励')
                      .fontSize(14)
                      .fontColor(Colors.TEXT_SECONDARY)
                    
                    Row({ space: 16 }) {
                      Text(`✨ ${this.session.reward.fragments} 碎片`)
                        .fontSize(14)
                        .fontColor(Colors.PRIMARY)
                      
                      Text(`🎁 ${this.session.reward.blindBoxDraws} 次抽奖`)
                        .fontSize(14)
                        .fontColor(Colors.SECONDARY)
                    }
                    
                    if (this.session.reward.bonusReason) {
                      Text(this.session.reward.bonusReason)
                        .fontSize(12)
                        .fontColor(Colors.ACCENT)
                    }
                  }
                  .margin({ top: 16 })
                }
                
                Button(this.resultSuccess ? '再来一次' : '继续寻宝', { type: ButtonType.Capsule })
                  .fontSize(14)
                  .fontColor(Colors.TEXT_ON_PRIMARY)
                  .backgroundColor(Colors.SECONDARY)
                  .margin({ top: 20 })
                  .onClick(() => this.startNewHunt())
              }
              .padding(24)
              .backgroundColor(Colors.SURFACE)
              .borderRadius(16)
              .margin({ left: 16, right: 16 })
            }
            
            // 寻宝战绩
            Column() {
              Text('🏆 寻宝战绩')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ bottom: 16 })
              
              Row() {
                this.StatsItemBuilder('总次数', this.stats.totalHunts.toString())
                this.StatsItemBuilder('成功', this.stats.successfulHunts.toString())
                this.StatsItemBuilder('成功率', `${this.stats.getSuccessRate()}%`)
                this.StatsItemBuilder('碎片', this.stats.totalFragmentsEarned.toString())
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceEvenly)
            }
            .padding(20)
            .backgroundColor(Colors.SURFACE)
            .borderRadius(16)
            .shadow({ radius: 8, color: Colors.SHADOW })
            .margin({ left: 16, right: 16, bottom: 16 })
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BACKGROUND)
  }
  
  @Builder
  ClueBuilder(clue: TreasureClue): void {
    Column() {
      if (clue.isRevealed) {
        // 已揭示的线索
        Row() {
          Text(clue.content)
            .fontSize(14)
            .fontColor(Colors.TEXT_PRIMARY)
            .layoutWeight(1)
          
          Text(this.getDifficultyText(clue.difficulty))
            .fontSize(10)
            .fontColor(this.getDifficultyColor(clue.difficulty))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(Colors.SURFACE_VARIANT)
            .borderRadius(8)
        }
        .width('100%')
      } else {
        // 未揭示的线索
        Row() {
          Text('🔒 神秘线索')
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .layoutWeight(1)
          
          Button(`揭示 (${clue.cost}碎片)`)
            .fontSize(12)
            .fontColor(Colors.TEXT_ON_PRIMARY)
            .backgroundColor(this.availableFragments >= clue.cost ? Colors.PRIMARY : Colors.TEXT_HINT)
            .borderRadius(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .enabled(this.availableFragments >= clue.cost)
            .onClick(() => this.revealClue(clue))
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(clue.isRevealed ? Colors.PRIMARY_LIGHT : Colors.SURFACE_VARIANT)
    .borderRadius(8)
  }
  
  @Builder
  MemoOptionBuilder(memo: Memo): void {
    Row() {
      // 心情图标
      Text(memo.mood)
        .fontSize(20)
        .margin({ right: 12 })
      
      // 笔记信息
      Column({ space: 4 }) {
        Text(memo.title || '无标题')
          .fontSize(14)
          .fontColor(Colors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(memo.getSummary(30))
          .fontSize(12)
          .fontColor(Colors.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      // 选中状态
      if (this.selectedMemoId === memo.id) {
        Text('✓')
          .fontSize(16)
          .fontColor(Colors.PRIMARY)
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.selectedMemoId === memo.id ? Colors.PRIMARY_LIGHT : Colors.SURFACE_VARIANT)
    .borderRadius(8)
    .border({
      width: this.selectedMemoId === memo.id ? 2 : 1,
      color: this.selectedMemoId === memo.id ? Colors.PRIMARY : Colors.BORDER
    })
    .onClick(() => {
      this.selectedMemoId = memo.id;
    })
  }
  
  @Builder
  StatsItemBuilder(label: string, value: string): void {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.PRIMARY)
      
      Text(label)
        .fontSize(12)
        .fontColor(Colors.TEXT_SECONDARY)
    }
  }
}
