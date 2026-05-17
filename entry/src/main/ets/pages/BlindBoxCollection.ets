/**
 * 盲盒卡片收藏页面
 */
import { BlindBoxReward, Rarity, RewardType } from '../model/BlindBox';
import { Colors } from '../constants/Colors';
import { StorageManager } from '../utils/StorageManager';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

// 类型选项接口
interface TypeOption {
  key: string;
  name: string;
  icon: string;
}

@Entry
@Component
struct BlindBoxCollectionPage {
  @State private rewards: BlindBoxReward[] = [];
  @State private selectedType: string = 'all';
  @State private isLoading: boolean = true;
  
  // 【新增】动画状态
  @State private pageOpacity: number = 0;
  
  private storageManager: StorageManager = StorageManager.getInstance();
  
  // 奖励类型选项
  private typeOptions: TypeOption[] = [
    { key: 'all', name: '全部', icon: '🎁' },
    { key: 'story_fragment', name: '剧情碎片', icon: '📜' },
    { key: 'emoticon', name: '表情包', icon: '😺' },
    { key: 'border', name: '边框', icon: '⬛' },
    { key: 'sprite_skin', name: '精灵皮肤', icon: '🦆' },
    { key: 'ai_reply', name: 'AI回复', icon: '💪' },
    { key: 'hidden_task', name: '隐藏任务', icon: '📅' }
  ];
  
  async aboutToAppear(): Promise<void> {
    await this.loadRewards();
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }
  
  // 页面每次显示时刷新数据
  async onPageShow(): Promise<void> {
    await this.loadRewards();
  }
  
  // 加载盲盒奖励
  async loadRewards(): Promise<void> {
    this.isLoading = true;
    try {
      this.rewards = await this.storageManager.getBlindBoxRewards();
      console.info('[BlindBoxCollection] 加载盲盒奖励数量:', this.rewards.length);
    } catch (error) {
      console.error('[BlindBoxCollection] 加载失败:', error);
      prompt.showToast({ message: '加载数据失败', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }
  
  // 获取筛选后的奖励
  getFilteredRewards(): BlindBoxReward[] {
    if (this.selectedType === 'all') {
      return this.rewards;
    }
    return this.rewards.filter((r: BlindBoxReward): boolean => r.type === this.selectedType);
  }
  
  // 获取稀有度颜色
  getRarityColor(rarity: Rarity): string {
    switch (rarity) {
      case Rarity.COMMON:
        return '#9E9E9E';
      case Rarity.RARE:
        return '#2196F3';
      case Rarity.EPIC:
        return '#9C27B0';
      case Rarity.LEGENDARY:
        return '#FF9800';
      default:
        return '#9E9E9E';
    }
  }
  
  // 获取稀有度背景色
  getRarityBgColor(rarity: Rarity): string {
    switch (rarity) {
      case Rarity.COMMON:
        return '#F5F5F5';
      case Rarity.RARE:
        return '#E3F2FD';
      case Rarity.EPIC:
        return '#F3E5F5';
      case Rarity.LEGENDARY:
        return '#FFF3E0';
      default:
        return '#F5F5F5';
    }
  }
  
  // 获取稀有度名称
  getRarityName(rarity: Rarity): string {
    switch (rarity) {
      case Rarity.COMMON:
        return '普通';
      case Rarity.RARE:
        return '稀有';
      case Rarity.EPIC:
        return '史诗';
      case Rarity.LEGENDARY:
        return '传说';
      default:
        return '普通';
    }
  }
  
  // 获取类型名称
  getTypeName(type: RewardType): string {
    switch (type) {
      case RewardType.STORY_FRAGMENT:
        return '剧情碎片';
      case RewardType.EMOTICON:
        return '表情包';
      case RewardType.BORDER:
        return '边框';
      case RewardType.SPRITE_SKIN:
        return '精灵皮肤';
      case RewardType.AI_REPLY:
        return 'AI回复';
      case RewardType.HIDDEN_TASK:
        return '隐藏任务';
      default:
        return '未知';
    }
  }
  
  // 格式化日期
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}/${date.getDate()} ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Row({ space: 8 }) {
            Text('←')
              .fontSize(20)
              .fontColor(Color.White)
            Text('返回')
              .fontSize(16)
              .fontColor(Color.White)
          }
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())
        
        Blank()
        
        Text('🎁 盲盒收藏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Blank()
        
        Row()
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .linearGradient({
        angle: 90,
        colors: [['#667EEA', 0], ['#764BA2', 1]]
      })
      
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Colors.PRIMARY)
          Text('加载中...')
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.rewards.length === 0) {
        // 空状态
        Column() {
          Text('🎁')
            .fontSize(64)
          Text('还没有盲盒卡片')
            .fontSize(18)
            .fontColor(Colors.TEXT_PRIMARY)
            .margin({ top: 16 })
          Text('写笔记有机会获得盲盒奖励哦！')
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .margin({ top: 8 })
          Button('去写笔记')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(24)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .margin({ top: 24 })
            .onClick(() => router.pushUrl({ url: 'pages/CreateMemo' }))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 类型筛选
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.typeOptions, (option: TypeOption) => {
              Button() {
                Row({ space: 4 }) {
                  Text(option.icon)
                    .fontSize(14)
                  Text(option.name)
                    .fontSize(12)
                    .fontColor(this.selectedType === option.key ? Color.White : Colors.TEXT_PRIMARY)
                }
              }
              .backgroundColor(this.selectedType === option.key ? Colors.PRIMARY : Colors.SURFACE_VARIANT)
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .border({ width: 1, color: this.selectedType === option.key ? Colors.PRIMARY : Colors.BORDER })
              .onClick(() => {
                this.selectedType = option.key;
              })
            })
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .width('100%')
        
        // 统计信息
        Row() {
          Text(`共 ${this.rewards.length} 件收藏`)
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
          
          Blank()
          
          // 稀有度统计
          Row({ space: 12 }) {
            Text(`传说 ${this.rewards.filter(r => r.rarity === Rarity.LEGENDARY).length}`)
              .fontSize(12)
              .fontColor('#FF9800')
            Text(`史诗 ${this.rewards.filter(r => r.rarity === Rarity.EPIC).length}`)
              .fontSize(12)
              .fontColor('#9C27B0')
            Text(`稀有 ${this.rewards.filter(r => r.rarity === Rarity.RARE).length}`)
              .fontSize(12)
              .fontColor('#2196F3')
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(Colors.SURFACE_VARIANT)
        
        // 卡片列表
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.getFilteredRewards().reverse(), (reward: BlindBoxReward) => {
              // 卡片
              Column() {
                Row() {
                  // 图标
                  Column() {
                    Text(reward.icon)
                      .fontSize(36)
                  }
                  .width(64)
                  .height(64)
                  .backgroundColor(this.getRarityBgColor(reward.rarity))
                  .borderRadius(16)
                  .justifyContent(FlexAlign.Center)
                  
                  // 信息
                  Column({ space: 4 }) {
                    Row({ space: 8 }) {
                      Text(reward.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Colors.TEXT_PRIMARY)
                      
                      // 稀有度标签
                      Text(this.getRarityName(reward.rarity))
                        .fontSize(10)
                        .fontColor(Color.White)
                        .backgroundColor(this.getRarityColor(reward.rarity))
                        .borderRadius(4)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    }
                    
                    Text(reward.description)
                      .fontSize(12)
                      .fontColor(Colors.TEXT_SECONDARY)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    
                    Row({ space: 8 }) {
                      Text(this.getTypeName(reward.type))
                        .fontSize(10)
                        .fontColor(Colors.TEXT_HINT)
                      
                      Text('•')
                        .fontSize(10)
                        .fontColor(Colors.TEXT_HINT)
                      
                      Text(this.formatDate(reward.unlockedAt))
                        .fontSize(10)
                        .fontColor(Colors.TEXT_HINT)
                    }
                    .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Colors.SURFACE)
                .borderRadius(16)
                .border({ width: 2, color: this.getRarityColor(reward.rarity) })
              }
              .margin({ left: 16, right: 16 })
            })
          }
          .padding({ top: 12, bottom: 24 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BACKGROUND)
  }
}
