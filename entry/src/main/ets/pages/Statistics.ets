import { Colors } from '../constants/Colors';
import { StorageManager } from '../utils/StorageManager';
import { Statistics } from '../model/Statistics';
import { Memo } from '../model/Memo';
import { EggManager } from '../utils/EggManager';
import { Achievement, AchievementCategory } from '../model/Achievement';
import { BlindBoxReward, Rarity } from '../model/BlindBox';
// 【新增】星球和寻宝相关导入
import { PlanetManager } from '../utils/PlanetManager';
import { TreasureHuntManager } from '../utils/TreasureHuntManager';
import { TreasureHuntStats } from '../model/TreasureHunt';
import { PlanetProgress } from '../model/PlanetFragment';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

// 图表数据项接口
interface ChartDataItem {
  mood?: string;
  tag?: string;
  priority?: number;
  date?: string;
  count: number;
}

@Entry
@Component
struct StatisticsPage {
  @State private stats: Statistics = new Statistics();
  @State private isLoading: boolean = true;
  @State private selectedChart: string = 'mood'; // mood, tag, priority, trend
  @State private chartData: ChartDataItem[] = [];
  
  // 【新增】动画状态
  @State private pageOpacity: number = 0;
  @State private cardScale: number = 1;
  
  // 【新增】成就和盲盒相关
  @State private achievements: Achievement[] = [];
  @State private blindBoxRewards: BlindBoxReward[] = [];
  @State private showAchievements: boolean = false;
  
  // 【新增】星球和寻宝相关
  @State private planetProgress: PlanetProgress = new PlanetProgress();
  @State private treasureHuntStats: TreasureHuntStats = new TreasureHuntStats();
  
  private storageManager: StorageManager = StorageManager.getInstance();
  private eggManager: EggManager = EggManager.getInstance();
  // 【新增】星球和寻宝管理器
  private planetManager: PlanetManager = PlanetManager.getInstance();
  private treasureHuntManager: TreasureHuntManager = TreasureHuntManager.getInstance();

  aboutToAppear() {
    this.loadStats();
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }

  // 页面每次显示时刷新数据
  onPageShow() {
    this.loadStats();
  }

  async loadStats(): Promise<void> {
    this.isLoading = true;
    try {
      const memos: Memo[] = await this.storageManager.getMemos();
      this.stats = Statistics.fromMemos(memos);
      this.updateChartData();
      
      // 【新增】加载成就和盲盒数据
      this.achievements = await this.eggManager.getAchievements();
      this.blindBoxRewards = await this.eggManager.getBlindBoxRewards();
      
      // 【新增】加载星球和寻宝数据
      this.planetProgress = await this.planetManager.getProgress();
      this.treasureHuntStats = await this.treasureHuntManager.getStats();
    } catch (error) {
      console.error('加载统计数据失败:', error);
      prompt.showToast({ message: '加载数据失败', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  // 更新图表数据
  updateChartData(): void {
    switch (this.selectedChart) {
      case 'mood':
        this.chartData = this.stats.getMoodDistributionArray();
        break;
      case 'tag':
        this.chartData = this.stats.getTagDistributionArray();
        break;
      case 'priority':
        this.chartData = this.stats.getPriorityDistributionArray();
        break;
      case 'trend':
        this.chartData = this.stats.getDailyStatsArray();
        break;
    }
  }

  // 切换图表类型
  switchChart(type: string): void {
    this.selectedChart = type;
    this.updateChartData();
  }

  // 获取图表标题
  getChartTitle(): string {
    switch (this.selectedChart) {
      case 'mood': return '心情分布';
      case 'tag': return '标签分布';
      case 'priority': return '优先级分布';
      case 'trend': return '最近7天趋势';
      default: return '统计图表';
    }
  }

  // 获取图表描述
  getChartDescription(): string {
    switch (this.selectedChart) {
      case 'mood': return '显示不同心情的笔记数量分布';
      case 'tag': return '显示最常用的标签分布';
      case 'priority': return '显示不同优先级的笔记数量';
      case 'trend': return '显示最近7天的笔记创建趋势';
      default: return '';
    }
  }

  // 获取最大值的索引（用于图表高度计算）
  getMaxValue(): number {
    if (this.chartData.length === 0) return 0;
    return Math.max(...this.chartData.map((item: ChartDataItem) => item.count));
  }
  
  // 【新增】获取稀有度颜色
  private getRarityColor(rarity: Rarity): string {
    switch (rarity) {
      case Rarity.COMMON:
        return '#9E9E9E';
      case Rarity.RARE:
        return '#2196F3';
      case Rarity.EPIC:
        return '#9C27B0';
      case Rarity.LEGENDARY:
        return '#FFD700';
      default:
        return '#9E9E9E';
    }
  }
  
  // 【新增】获取稀有度背景颜色
  private getRarityBgColor(rarity: Rarity): string {
    switch (rarity) {
      case Rarity.COMMON:
        return '#F5F5F5';
      case Rarity.RARE:
        return '#E3F2FD';
      case Rarity.EPIC:
        return '#F3E5F5';
      case Rarity.LEGENDARY:
        return '#FFF8E1';
      default:
        return '#F5F5F5';
    }
  }

  // 获取心情描述
  getMoodDescription(mood: string): string {
    const descriptions: Record<string, string> = {
      '😊': '开心', '😄': '大笑', '😍': '喜爱', '🥳': '庆祝',
      '😎': '酷', '😌': '平静', '😐': '一般', '😔': '沮丧',
      '😢': '哭泣', '😠': '生气', '😴': '困倦', '🤔': '思考'
    };
    return descriptions[mood] || '未知心情';
  }

  build() {
    Column({ space: 0 }) {
      // 应用栏
      Row() {
        Button('返回')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
          .margin({ left: 16 })
        
        Text('统计中心')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('刷新')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.loadStats())
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Colors.SURFACE)
      .shadow({ radius: 4, color: Colors.SHADOW })

      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .color(Colors.PRIMARY)
          Text('加载中...')
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 概览卡片
            Column() {
              Text('📊 数据概览')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ bottom: 16 })
              
              Grid() {
                GridItem() {
                  this.buildStatCard('📝', '总笔记', this.stats.totalMemos.toString(), Colors.PRIMARY)
                }
                
                GridItem() {
                  this.buildStatCard('✅', '已完成', this.stats.completedMemos.toString(), Colors.SUCCESS)
                }
                
                GridItem() {
                  this.buildStatCard('📅', '今日', this.stats.todayMemos.toString(), Colors.ACCENT)
                }
                
                GridItem() {
                  this.buildStatCard('😊', '心情', this.stats.moodDistribution.size.toString(), Colors.SECONDARY)
                }
                
                GridItem() {
                  this.buildStatCard('🔥', '连续打卡', `${this.stats.streakDays}天`, Colors.WARNING)
                }
              }
              .columnsTemplate('1fr 1fr 1fr')
              .rowsTemplate('1fr 1fr')
              .columnsGap(12)
              .rowsGap(12)
              .height(224)
            }
            .width('100%')
            .padding(20)
            .linearGradient({
              angle: 135,
              colors: [['#FFFFFF', 0], ['#F8F9FF', 1]]
            })
            .borderRadius(18)
            .shadow({ radius: 12, color: Colors.SHADOW })
            .margin({ top: 16, left: 16, right: 16 })

            // 【新增】星球建造入口
            Column() {
              Row() {
                Text('🌟 笔记星球')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)
                
                Button('进入建造')
                  .fontSize(13)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(14)
                  .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                  .onClick(() => router.pushUrl({ url: 'pages/PlanetBuilder' }))
              }
              .width('100%')
              .margin({ bottom: 16 })
              
              Row() {
                Column({ space: 6 }) {
                  Text('碎片总数')
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.8)')
                  Text(this.planetProgress.totalFragments.toString())
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .layoutWeight(1)
                
                Column({ space: 6 }) {
                  Text('完整度')
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.8)')
                  Text(`${this.planetProgress.completionPercent}%`)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .layoutWeight(1)
                
                Column({ space: 6 }) {
                  Text('今日新增')
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.8)')
                  Text(this.planetProgress.todayFragments.toString())
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(20)
            .linearGradient({
              angle: 135,
              colors: [['#B8A2F2', 0], ['#82CFFF', 1]]
            })
            .borderRadius(18)
            .shadow({ radius: 16, color: '#B8A2F240' })
            .margin({ left: 16, right: 16 })

            // 【新增】寻宝战绩入口
            Column() {
              Row() {
                Text('🗺️ 寻宝战绩')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .layoutWeight(1)
                
                Button('开始寻宝')
                  .fontSize(13)
                  .fontColor(Colors.TEXT_ON_PRIMARY)
                  .linearGradient({
                    angle: 135,
                    colors: [[Colors.SECONDARY, 0], ['#5BB8FF', 1]]
                  })
                  .borderRadius(14)
                  .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                  .onClick(() => router.pushUrl({ url: 'pages/TreasureHuntPage' }))
              }
              .width('100%')
              .margin({ bottom: 16 })
              
              Row() {
                Column({ space: 6 }) {
                  Text('寻宝次数')
                    .fontSize(12)
                    .fontColor(Colors.TEXT_SECONDARY)
                  Text(this.treasureHuntStats.totalHunts.toString())
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Colors.SECONDARY)
                }
                .layoutWeight(1)
                
                Column({ space: 6 }) {
                  Text('成功率')
                    .fontSize(12)
                    .fontColor(Colors.TEXT_SECONDARY)
                  Text(`${this.treasureHuntStats.getSuccessRate()}%`)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Colors.SECONDARY)
                }
                .layoutWeight(1)
                
                Column({ space: 6 }) {
                  Text('获得碎片')
                    .fontSize(12)
                    .fontColor(Colors.TEXT_SECONDARY)
                  Text(this.treasureHuntStats.totalFragmentsEarned.toString())
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Colors.SECONDARY)
                }
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(20)
            .linearGradient({
              angle: 135,
              colors: [['#FFFFFF', 0], ['#E5F6FF', 1]]
            })
            .borderRadius(18)
            .shadow({ radius: 12, color: Colors.SHADOW })
            .margin({ left: 16, right: 16 })

            // 图表选择器
            Column() {
              Text('📈 可视化分析')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ bottom: 8 })

              Text(this.getChartDescription())
                .fontSize(12)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ bottom: 16 })
              
              // 图表类型选择
              Row({ space: 8 }) {
                this.buildChartTypeButton('心情分布', 'mood', '😊')
                this.buildChartTypeButton('标签分布', 'tag', '🏷️')
                this.buildChartTypeButton('优先级', 'priority', '⭐')
                this.buildChartTypeButton('趋势', 'trend', '📈')
              }
              .margin({ bottom: 20 })
              
              // 图表标题
              Text(this.getChartTitle())
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ bottom: 16 })
              
              // 图表区域
              if (this.chartData.length === 0) {
                Column() {
                  Text('📊')
                    .fontSize(48)
                    .margin({ bottom: 12 })
                  
                  Text('暂无数据')
                    .fontSize(14)
                    .fontColor(Colors.TEXT_SECONDARY)
                  
                  Text('开始记录笔记以查看统计图表')
                    .fontSize(12)
                    .fontColor(Colors.TEXT_HINT)
                    .margin({ top: 4 })
                }
                .width('100%')
                .padding(24)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              } else {
                // 图表容器
                Column({ space: 12 }) {
                  // 图表主体
                  Row({ space: 0 }) {
                    ForEach(this.chartData, (item: ChartDataItem, index: number) => {
                      this.buildChartBar(item, index)
                    })
                  }
                  .height(150)
                  .width('100%')
                  .alignItems(VerticalAlign.Bottom)
                  
                  // X轴标签
                  Row({ space: 0 }) {
                    ForEach(this.chartData, (item: ChartDataItem, index: number) => {
                      Column() {
                        if (this.selectedChart === 'mood') {
                          Text(item.mood || '')
                            .fontSize(10)
                            .fontColor(Colors.TEXT_SECONDARY)
                        } else if (this.selectedChart === 'tag') {
                          Text((item.tag || '').length > 4 ? (item.tag || '').substring(0, 4) + '...' : (item.tag || ''))
                            .fontSize(10)
                            .fontColor(Colors.TEXT_SECONDARY)
                        } else if (this.selectedChart === 'priority') {
                          Text(`P${item.priority || 0}`)
                            .fontSize(10)
                            .fontColor(Colors.TEXT_SECONDARY)
                        } else if (this.selectedChart === 'trend') {
                          Text(item.date || '')
                            .fontSize(10)
                            .fontColor(Colors.TEXT_SECONDARY)
                        }
                        
                        Text(item.count.toString())
                          .fontSize(10)
                          .fontColor(Colors.TEXT_PRIMARY)
                          .fontWeight(FontWeight.Medium)
                          .margin({ top: 2 })
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Center)
                    })
                  }
                  .margin({ top: 8 })
                }
              }
            }
            .width('100%')
            .padding(20)
            .linearGradient({
              angle: 135,
              colors: [['#FFFFFF', 0], ['#F8F9FF', 1]]
            })
            .borderRadius(18)
            .shadow({ radius: 12, color: Colors.SHADOW })
            .margin({ left: 16, right: 16 })

            // 心情分布详情
            Column() {
              Text('😊 心情分布详情')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ bottom: 16 })
              
              if (this.stats.moodDistribution.size === 0) {
                Text('暂无心情记录')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .padding(16)
              } else {
                Column({ space: 12 }) {
                  ForEach(this.stats.getMoodDistributionArray(), (item: ChartDataItem) => {
                    this.buildMoodDistributionItem(item.mood || '😊', item.count)
                  })
                }
              }
            }
            .width('100%')
            .padding(20)
            .linearGradient({
              angle: 135,
              colors: [['#FFFFFF', 0], ['#F8F9FF', 1]]
            })
            .borderRadius(18)
            .shadow({ radius: 12, color: Colors.SHADOW })
            .margin({ left: 16, right: 16 })

            // 【新增】成就图鉴
            Column() {
              Row() {
                Text('🏆 成就图鉴')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .layoutWeight(1)
                
                Text(`${this.achievements.filter(a => a.isUnlocked).length}/${this.achievements.length}`)
                  .fontSize(14)
                  .fontColor(Colors.PRIMARY)
                  .fontWeight(FontWeight.Medium)
              }
              .margin({ bottom: 16 })
              
              // 成就列表
              Grid() {
                ForEach(this.achievements, (achievement: Achievement) => {
                  GridItem() {
                    Column() {
                      Text(achievement.icon)
                        .fontSize(28)
                        .opacity(achievement.isUnlocked ? 1 : 0.3)
                      
                      Text(achievement.name)
                        .fontSize(10)
                        .fontColor(achievement.isUnlocked ? Colors.TEXT_PRIMARY : Colors.TEXT_SECONDARY)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ top: 4 })
                      
                      // 进度条
                      if (!achievement.isUnlocked && achievement.targetProgress > 1) {
                        Row() {
                          Column()
                            .height(3)
                            .width(`${achievement.getProgressPercent()}%`)
                            .backgroundColor(Colors.PRIMARY)
                            .borderRadius(2)
                        }
                        .width('100%')
                        .height(3)
                        .backgroundColor(Colors.SURFACE_VARIANT)
                        .borderRadius(2)
                        .margin({ top: 4 })
                      }
                    }
                    .width('100%')
                    .padding(8)
                    .backgroundColor(achievement.isUnlocked ? Colors.PRIMARY_LIGHT : Colors.SURFACE_VARIANT)
                    .borderRadius(12)
                    .border({ 
                      width: achievement.isUnlocked ? 2 : 1, 
                      color: achievement.isUnlocked ? Colors.PRIMARY : Colors.BORDER 
                    })
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .rowsGap(12)
              .columnsGap(12)
              .height(200)
            }
            .padding(20)
            .backgroundColor(Colors.SURFACE)
            .borderRadius(16)
            .shadow({ radius: 8, color: Colors.SHADOW })
            .margin({ left: 16, right: 16 })

            // 【新增】盲盒奖励展示
            if (this.blindBoxRewards.length > 0) {
              Column() {
                Row() {
                  Text('🎁 盲盒收藏')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Colors.TEXT_PRIMARY)
                    .layoutWeight(1)
                  
                  Text(`${this.blindBoxRewards.length}件`)
                    .fontSize(14)
                    .fontColor(Colors.PRIMARY)
                    .fontWeight(FontWeight.Medium)
                }
                .margin({ bottom: 16 })
                
                // 最近获得的奖励
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.blindBoxRewards.slice(-10).reverse(), (reward: BlindBoxReward) => {
                    Column() {
                      Text(reward.icon)
                        .fontSize(24)
                      Text(reward.name)
                        .fontSize(10)
                        .fontColor(Colors.TEXT_PRIMARY)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ top: 4 })
                    }
                    .padding(8)
                    .backgroundColor(this.getRarityBgColor(reward.rarity))
                    .borderRadius(12)
                    .border({ width: 1, color: this.getRarityColor(reward.rarity) })
                    .margin({ right: 8, bottom: 8 })
                  })
                }
              }
              .padding(20)
              .backgroundColor(Colors.SURFACE)
              .borderRadius(16)
              .shadow({ radius: 8, color: Colors.SHADOW })
              .margin({ left: 16, right: 16 })
            }

            // 标签分布详情
            Column() {
              Text('🏷️ 热门标签')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ bottom: 16 })
              
              if (this.stats.tagDistribution.size === 0) {
                Text('暂无标签')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .padding(16)
              } else {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.stats.getTagDistributionArray().slice(0, 10), (item: ChartDataItem) => {
                    this.buildTagItem(item.tag || '', item.count)
                  })
                }
              }
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
    .opacity(this.pageOpacity)  // 页面淡入动画
  }

  @Builder
  buildStatCard(icon: string, title: string, value: string, color: string): void {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(20)
      
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      
      Text(title)
        .fontSize(12)
        .fontColor(Colors.TEXT_SECONDARY)
    }
    .padding(16)
    .backgroundColor(Colors.SURFACE)
    .borderRadius(12)
    .border({ width: 1, color: Colors.BORDER })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height(100)
    .scale({ x: this.cardScale, y: this.cardScale })
    .onClick(() => {
      // 点击缩放动画
      animateTo(AnimationUtils.getScaleOptions(), () => {
        this.cardScale = AnimationUtils.SCALE_PRESSED;
      });
      setTimeout(() => {
        animateTo(AnimationUtils.getScaleOptions(), () => {
          this.cardScale = AnimationUtils.SCALE_NORMAL;
        });
      }, 100);
    })
  }

  @Builder
  buildChartTypeButton(text: string, type: string, icon: string) {
    Button() {
      Row({ space: 2 }) {
        Text(icon)
          .fontSize(12)
        Text(text)
          .fontSize(10)
      }
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(this.selectedChart === type ? Colors.PRIMARY : Colors.SURFACE_VARIANT)
    .borderRadius(16)
    .border({ width: 1, color: this.selectedChart === type ? Colors.PRIMARY : Colors.BORDER })
    .onClick(() => this.switchChart(type))
  }

  @Builder
  buildChartBar(item: ChartDataItem, index: number) {
    Column() {
      // 柱状图
      Column()
        .width(24)
        .height(`${(item.count / this.getMaxValue()) * 100}%`)
        .backgroundColor(Colors.CHART_COLORS[index % Colors.CHART_COLORS.length])
        .borderRadius({ topLeft: 4, topRight: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildMoodDistributionItem(mood: string, count: number) {
    Row() {
      // 心情图标
      Column() {
        Text(mood)
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor(Colors.MOOD_BACKGROUNDS[mood] || Colors.SURFACE_VARIANT)
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 12 })

      // 内容区域
      Column({ space: 4 }) {
        Row() {
          Text(this.getMoodDescription(mood))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.TEXT_PRIMARY)
            .layoutWeight(1)
          
          Text(`${count} 条`)
            .fontSize(12)
            .fontColor(Colors.TEXT_SECONDARY)
        }
        
        // 进度条
        Row() {
          Column()
            .height(8)
            .backgroundColor(Colors.MOOD_COLORS[mood] || Colors.PRIMARY)
            .borderRadius(4)
            .width(`${this.stats.totalMemos > 0 ? Math.round((count / this.stats.totalMemos) * 100) : 0}%`)
        }
        .width('100%')
        .height(8)
        .backgroundColor(Colors.SURFACE_VARIANT)
        .borderRadius(4)
        .margin({ top: 4 })
        
        Row() {
          Text(`${this.stats.totalMemos > 0 ? Math.round((count / this.stats.totalMemos) * 100) : 0}%`)
            .fontSize(10)
            .fontColor(Colors.TEXT_SECONDARY)
          
          Blank()
          
          Text(`${this.stats.totalMemos > 0 ? Math.round((count / this.stats.totalMemos) * 100) : 0}%`)
            .fontSize(10)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
        }
      }
      .layoutWeight(1)
    }
    .padding(12)
    .backgroundColor(Colors.SURFACE)
    .borderRadius(12)
    .border({ width: 1, color: Colors.BORDER })
  }

  @Builder
  buildTagItem(tag: string, count: number) {
    Row({ space: 6 }) {
      Text(`#${tag}`)
        .fontSize(12)
        .fontColor(Colors.PRIMARY)
      
      Text(count.toString())
        .fontSize(10)
        .fontColor(Colors.TEXT_SECONDARY)
        .backgroundColor(Colors.SURFACE_VARIANT)
        .borderRadius(8)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor(Colors.PRIMARY_LIGHT)
    .borderRadius(16)
    .border({ width: 1, color: Colors.PRIMARY })
  }
}