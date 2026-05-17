import { Colors } from '../constants/Colors';
import { StorageManager } from '../utils/StorageManager';
import { Memo } from '../model/Memo';
import { AIService } from '../services/AIService';
import { EggManager } from '../utils/EggManager';
import { BlindBoxPool, BlindBoxReward } from '../model/BlindBox';
import { TimeCapsule } from '../model/TimeCapsule';
import { Achievement } from '../model/Achievement';
import { BlindBoxDialog } from '../components/BlindBoxDialog';
import { AchievementUnlockDialog } from '../components/AchievementUnlockDialog';
// 【新增】星球管理器导入
import { PlanetManager } from '../utils/PlanetManager';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct CreateMemoPage {
  @State private title: string = '';
  @State private content: string = '';
  @State private selectedMood: string = '😊';
  @State private selectedPriority: number = 2; // 1-低, 2-中, 3-高
  @State private tags: string[] = [];
  @State private tagInput: string = '';
  @State private isGenerating: boolean = false;
  @State private isPolishing: boolean = false;
  
  // 【新增】动画状态
  @State private pageOpacity: number = 0;
  @State private saveBtnScale: number = 1;
  @State private moodScale: number = 1;  // 心情点击动效
  
  // 【新增】时间胶囊相关
  @State private isTimeCapsule: boolean = false;
  @State private unlockYear: number = new Date().getFullYear();
  @State private unlockMonth: number = new Date().getMonth() + 1;
  @State private unlockDay: number = new Date().getDate() + 1;
  
  // 【新增】盲盒和成就弹窗
  @State private blindBoxReward: BlindBoxReward | null = null;
  @State private unlockedAchievement: Achievement | null = null;
  
  // 心情选项
  private moods: string[] = ['😊', '😄', '😍', '🥳', '😎', '😌', '😐', '😔', '😢', '😠', '😴', '🤔'];
  
  // 标签建议
  private suggestedTags: string[] = ['工作', '学习', '生活', '购物', '健康', '旅行', '想法', '灵感', '任务', '计划'];
  
  private storageManager: StorageManager = StorageManager.getInstance();
  private eggManager: EggManager = EggManager.getInstance();
  // 【新增】星球管理器
  private planetManager: PlanetManager = PlanetManager.getInstance();
  
  // 盲盒弹窗控制器
  private blindBoxDialogController: CustomDialogController = new CustomDialogController({
    builder: BlindBoxDialog({
      reward: this.blindBoxReward,
      onClaim: () => {
        this.blindBoxReward = null;
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });
  
  // 成就弹窗控制器
  private achievementDialogController: CustomDialogController = new CustomDialogController({
    builder: AchievementUnlockDialog({
      achievement: this.unlockedAchievement,
      onConfirm: () => {
        this.unlockedAchievement = null;
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }

  // 保存备忘录
  async saveMemo(): Promise<void> {
    if (!this.title.trim() && !this.content.trim()) {
      prompt.showToast({ message: '请输入标题或内容', duration: 2000 });
      return;
    }

    const memo = new Memo(
      `memo_${Date.now()}`,
      this.title.trim() || '无标题',
      this.content.trim() || '无内容',
      false,
      this.selectedPriority,
      this.selectedMood,
      this.tags,
      Date.now(),
      Date.now()
    );

    try {
      await this.storageManager.saveMemo(memo);
      
      // 【新增】如果是时间胶囊，保存到时间胶囊列表
      if (this.isTimeCapsule) {
        const unlockDate = new Date(this.unlockYear, this.unlockMonth - 1, this.unlockDay).getTime();
        const capsule = new TimeCapsule(
          TimeCapsule.generateId(),
          memo.id,
          memo.title,
          memo.content,
          unlockDate,
          Date.now(),
          false,
          memo.mood,
          memo.priority
        );
        await this.eggManager.saveTimeCapsule(capsule);
        prompt.showToast({ message: '时间胶囊已封存！', duration: 2000 });
      } else {
        prompt.showToast({ message: '保存成功', duration: 1500 });
      }
      
      // 【新增】触发盲盒抽奖
      const reward = BlindBoxPool.drawRandom();
      await this.eggManager.saveBlindBoxReward(reward);
      this.blindBoxReward = reward;
      this.blindBoxDialogController.open();
      
      // 【新增】检查成就
      const allMemos = await this.storageManager.getMemos();
      const newAchievements = await this.eggManager.checkAchievements(memo, allMemos);
      if (newAchievements.length > 0) {
        this.unlockedAchievement = newAchievements[0];
        setTimeout(() => {
          this.achievementDialogController.open();
        }, 2000);
      }
      
      // 检查连续打卡成就
      await this.eggManager.checkDailyWriterAchievement(allMemos);
      await this.eggManager.checkContinuousHappyAchievement(allMemos);
      
      // 【新增】生成星球碎片 - 每保存一条笔记自动产出1块星球碎片
      const fragment = this.planetManager.createFragmentForMemo(memo);
      await this.planetManager.saveFragment(fragment);
      console.info('[CreateMemo] 星球碎片已生成:', fragment.id);
      
      // 保存成功后返回
      setTimeout(() => {
        router.back();
      }, 1500);
    } catch (error) {
      console.error('保存失败:', error);
      prompt.showToast({ message: '保存失败', duration: 2000 });
    }
  }

  // 添加标签
  addTag(): void {
    const tag = this.tagInput.trim();
    if (tag && !this.tags.includes(tag)) {
      this.tags.push(tag);
      this.tagInput = '';
    }
  }

  // 移除标签
  removeTag(index: number): void {
    this.tags.splice(index, 1);
  }

  // AI生成内容
  async generateWithAI(): Promise<void> {
    if (!this.title.trim()) {
      prompt.showToast({ message: '请输入主题或关键词', duration: 2000 });
      return;
    }

    this.isGenerating = true;
    try {
      const result = await AIService.generateMemo(this.title);
      this.content = result.content;
      if (!this.title.startsWith('AI生成:')) {
        this.title = `AI生成: ${this.title}`;
      }
      prompt.showToast({ message: 'AI生成完成', duration: 1500 });
    } catch (error) {
      console.error('AI生成失败:', error);
      prompt.showToast({ message: '生成失败，请重试', duration: 2000 });
    } finally {
      this.isGenerating = false;
    }
  }

  // AI润色内容
  async polishWithAI(): Promise<void> {
    if (!this.content.trim()) {
      prompt.showToast({ message: '请输入需要润色的内容', duration: 2000 });
      return;
    }

    this.isPolishing = true;
    try {
      this.content = await AIService.polishMemo(this.content);
      prompt.showToast({ message: 'AI润色完成', duration: 1500 });
    } catch (error) {
      console.error('AI润色失败:', error);
      prompt.showToast({ message: '润色失败，请重试', duration: 2000 });
    } finally {
      this.isPolishing = false;
    }
  }

  // 获取标签建议
  async getTagSuggestions(): Promise<void> {
    if (!this.content.trim()) return;
    
    try {
      const suggestions = await AIService.suggestTags(this.content);
      // 添加建议的标签（不重复）
      suggestions.forEach(tag => {
        if (!this.tags.includes(tag)) {
          this.tags.push(tag);
        }
      });
    } catch (error) {
      console.error('获取标签建议失败:', error);
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

  // 获取优先级描述
  getPriorityDescription(priority: number): string {
    const descriptions: Record<number, string> = {
      1: '低优先级',
      2: '中优先级',
      3: '高优先级'
    };
    return descriptions[priority] || '中优先级';
  }

  build() {
    Column({ space: 0 }) {
      // 应用栏
      Row() {
        Button('取消')
          .fontSize(14)
          .fontColor(Colors.TEXT_SECONDARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
          .margin({ left: 16 })
        
        Text('新建笔记')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('保存')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.saveMemo())
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Colors.SURFACE)
      .shadow({ radius: 4, color: Colors.SHADOW })

      Scroll() {
        Column({ space: 20 }) {
          // 标题输入
          Column() {
            Text('标题')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.TEXT_PRIMARY)
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '请输入标题（可选）', text: this.title })
              .fontSize(16)
              .fontColor(Colors.TEXT_PRIMARY)
              .backgroundColor('#F5F5FA')
              .borderRadius(14)
              .border({ width: 1, color: Colors.BORDER })
              .padding(14)
              .onChange((value: string) => {
                this.title = value;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })

          // 内容输入
          Column() {
            Row() {
              Text('内容')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .layoutWeight(1)
              
              // AI功能按钮
              Row({ space: 8 }) {
                if (this.isGenerating) {
                  LoadingProgress()
                    .width(16)
                    .height(16)
                    .color(Colors.PRIMARY)
                } else {
                  Button('AI生成')
                    .fontSize(12)
                    .fontColor(Colors.PRIMARY)
                    .backgroundColor(Colors.PRIMARY_LIGHT)
                    .borderRadius(12)
                    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                    .onClick(() => this.generateWithAI())
                }
                
                if (this.isPolishing) {
                  LoadingProgress()
                    .width(16)
                    .height(16)
                    .color(Colors.SECONDARY)
                } else {
                  Button('AI润色')
                    .fontSize(12)
                    .fontColor(Colors.SECONDARY)
                    .backgroundColor(Colors.SECONDARY_LIGHT)
                    .borderRadius(12)
                    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                    .onClick(() => this.polishWithAI())
                }
              }
            }
            .margin({ bottom: 8 })
            
            TextArea({ placeholder: '请输入内容...', text: this.content })
              .fontSize(14)
              .fontColor(Colors.TEXT_PRIMARY)
              .backgroundColor('#F5F5FA')
              .border({ width: 1, color: Colors.BORDER, radius: 14 })
              .padding(14)
              .height(200)
              .onChange((value: string) => {
                this.content = value;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 心情选择
          Column() {
            Text('心情')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.TEXT_PRIMARY)
              .margin({ bottom: 8 })
            
            Scroll() {
              Row({ space: 10 }) {
                ForEach(this.moods, (mood: string) => {
                  Column() {
                    Text(mood)
                      .fontSize(26)
                    Text(this.getMoodDescription(mood))
                      .fontSize(10)
                      .fontColor(this.selectedMood === mood ? '#FFFFFF' : Colors.TEXT_SECONDARY)
                      .margin({ top: 4 })
                  }
                  .padding(14)
                  .linearGradient({
                    angle: 135,
                    colors: this.selectedMood === mood 
                      ? [[Colors.MOOD_COLORS[mood], 0], [Colors.MOOD_COLORS[mood] + 'CC', 1]]
                      : [[Colors.MOOD_BACKGROUNDS[mood] || '#F5F5FA', 0], ['#FFFFFF', 1]]
                  })
                  .borderRadius(16)
                  .shadow({ radius: this.selectedMood === mood ? 8 : 4, color: this.selectedMood === mood ? Colors.MOOD_COLORS[mood] + '40' : Colors.SHADOW })
                  .scale({ x: this.moodScale, y: this.moodScale })
                  .onClick(() => {
                    // 点击缩放动画
                    animateTo(AnimationUtils.getScaleOptions(), () => {
                      this.moodScale = AnimationUtils.SCALE_PRESSED;
                    });
                    setTimeout(() => {
                      animateTo(AnimationUtils.getScaleOptions(), () => {
                        this.moodScale = AnimationUtils.SCALE_NORMAL;
                      });
                    }, 100);
                    this.selectedMood = mood;
                  })
                })
              }
              .padding({ left: 4, right: 4 })
            }
            .scrollBar(BarState.Off)
            .scrollable(ScrollDirection.Horizontal)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 优先级选择
          Column() {
            Text('优先级')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.TEXT_PRIMARY)
              .margin({ bottom: 8 })
            
            Row({ space: 12 }) {
              ForEach([1, 2, 3], (priority: number) => {
                Column() {
                  Text(['低', '中', '高'][priority - 1])
                    .fontSize(14)
                    .fontColor(this.selectedPriority === priority ? '#FFFFFF' : Colors.TEXT_PRIMARY)
                  
                  Text(['⭐', '⭐⭐', '⭐⭐⭐'][priority - 1])
                    .fontSize(16)
                    .margin({ top: 4 })
                }
                .width(100)
                .padding(16)
                .linearGradient({
                  angle: 135,
                  colors: this.selectedPriority === priority 
                    ? [[Colors.PRIORITY_COLORS[priority], 0], [Colors.PRIORITY_COLORS[priority] + 'CC', 1]]
                    : [['#FFFFFF', 0], ['#F5F5FA', 1]]
                })
                .borderRadius(16)
                .shadow({ radius: this.selectedPriority === priority ? 8 : 4, color: this.selectedPriority === priority ? Colors.PRIORITY_COLORS[priority] + '40' : Colors.SHADOW })
                .onClick(() => {
                  this.selectedPriority = priority;
                })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 【重新设计】时间胶囊组件
          Column() {
            // 开关行
            Row() {
              Text('⏰ 时间胶囊')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              
              Blank()
              
              Toggle({ type: ToggleType.Switch, isOn: this.isTimeCapsule })
                .selectedColor('#FFD700')
                .onChange((isOn: boolean) => {
                  this.isTimeCapsule = isOn;
                })
            }
            .width('100%')
            .padding(16)
            .linearGradient({
              angle: 90,
              colors: [['#667EEA', 0], ['#764BA2', 1]]
            })
            .borderRadius(12)
            
            // 日期选择区域（使用 visibility 控制）
            Column() {
              Text('📅 选择解锁日期')
                .fontSize(14)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ bottom: 16 })
              
              // 年月日选择器
              Row({ space: 6 }) {
                // 年份
                Column() {
                  Text('年')
                    .fontSize(10)
                    .fontColor(Colors.TEXT_SECONDARY)
                  
                  Row({ space: 4 }) {
                    Button({ type: ButtonType.Normal }) {
                      Text('◀')
                        .fontSize(12)
                        .fontColor(Color.White)
                    }
                    .backgroundColor(Colors.PRIMARY)
                    .width(32)
                    .height(28)
                    .borderRadius(6)
                    .onClick(() => {
                      const minYear = new Date().getFullYear();
                      if (this.unlockYear > minYear) {
                        this.unlockYear = this.unlockYear - 1;
                      }
                    })
                    
                    Text(this.unlockYear.toString())
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Colors.PRIMARY)
                      .width(48)
                      .textAlign(TextAlign.Center)
                    
                    Button({ type: ButtonType.Normal }) {
                      Text('▶')
                        .fontSize(12)
                        .fontColor(Color.White)
                    }
                    .backgroundColor(Colors.PRIMARY)
                    .width(32)
                    .height(28)
                    .borderRadius(6)
                    .onClick(() => {
                      if (this.unlockYear < 2030) {
                        this.unlockYear = this.unlockYear + 1;
                      }
                    })
                  }
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                
                // 月份
                Column() {
                  Text('月')
                    .fontSize(10)
                    .fontColor(Colors.TEXT_SECONDARY)
                  
                  Row({ space: 4 }) {
                    Button({ type: ButtonType.Normal }) {
                      Text('◀')
                        .fontSize(12)
                        .fontColor(Color.White)
                    }
                    .backgroundColor(Colors.PRIMARY)
                    .width(32)
                    .height(28)
                    .borderRadius(6)
                    .onClick(() => {
                      if (this.unlockMonth > 1) {
                        this.unlockMonth = this.unlockMonth - 1;
                      }
                    })
                    
                    Text(this.unlockMonth.toString())
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Colors.PRIMARY)
                      .width(32)
                      .textAlign(TextAlign.Center)
                    
                    Button({ type: ButtonType.Normal }) {
                      Text('▶')
                        .fontSize(12)
                        .fontColor(Color.White)
                    }
                    .backgroundColor(Colors.PRIMARY)
                    .width(32)
                    .height(28)
                    .borderRadius(6)
                    .onClick(() => {
                      if (this.unlockMonth < 12) {
                        this.unlockMonth = this.unlockMonth + 1;
                      }
                    })
                  }
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                
                // 日期
                Column() {
                  Text('日')
                    .fontSize(10)
                    .fontColor(Colors.TEXT_SECONDARY)
                  
                  Row({ space: 4 }) {
                    Button({ type: ButtonType.Normal }) {
                      Text('◀')
                        .fontSize(12)
                        .fontColor(Color.White)
                    }
                    .backgroundColor(Colors.PRIMARY)
                    .width(32)
                    .height(28)
                    .borderRadius(6)
                    .onClick(() => {
                      if (this.unlockDay > 1) {
                        this.unlockDay = this.unlockDay - 1;
                      }
                    })
                    
                    Text(this.unlockDay.toString())
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Colors.PRIMARY)
                      .width(32)
                      .textAlign(TextAlign.Center)
                    
                    Button({ type: ButtonType.Normal }) {
                      Text('▶')
                        .fontSize(12)
                        .fontColor(Color.White)
                    }
                    .backgroundColor(Colors.PRIMARY)
                    .width(32)
                    .height(28)
                    .borderRadius(6)
                    .onClick(() => {
                      if (this.unlockDay < 31) {
                        this.unlockDay = this.unlockDay + 1;
                      }
                    })
                  }
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
              }
              .width('100%')
              
              // 提示信息
              Row() {
                Text('📦 ')
                  .fontSize(14)
                Text(`将在 ${this.unlockYear}年${this.unlockMonth}月${this.unlockDay}日 解锁此笔记`)
                  .fontSize(13)
                  .fontColor(Colors.TEXT_SECONDARY)
              }
              .margin({ top: 16 })
              .padding(12)
              .backgroundColor(Colors.PRIMARY_LIGHT)
              .borderRadius(8)
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F5F5F5')
            .borderRadius(12)
            .margin({ top: 8 })
            .visibility(this.isTimeCapsule ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .backgroundColor(Colors.SURFACE)
          .borderRadius(16)
          .border({ width: 2, color: this.isTimeCapsule ? Colors.PRIMARY : Colors.BORDER })
          .margin({ left: 16, right: 16 })
          .padding({ bottom: this.isTimeCapsule ? 16 : 0 })

          // 标签管理
          Column() {
            Row() {
              Text('标签')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .layoutWeight(1)
              
              Button('智能推荐')
                .fontSize(12)
                .fontColor(Colors.ACCENT)
                .backgroundColor(Colors.ACCENT_LIGHT)
                .borderRadius(12)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .onClick(() => this.getTagSuggestions())
            }
            .margin({ bottom: 8 })
            
            // 标签输入
            Row({ space: 8 }) {
              TextInput({ 
                placeholder: '输入标签后按回车', 
                text: this.tagInput 
              })
                .fontSize(14)
                .fontColor(Colors.TEXT_PRIMARY)
                .backgroundColor(Colors.SURFACE)
                .borderRadius(8)
                .border({ width: 1, color: Colors.BORDER })
                .padding(8)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.tagInput = value;
                })
                .onSubmit(() => this.addTag())
              
              Button('添加')
                .fontSize(12)
                .fontColor(Colors.PRIMARY)
                .backgroundColor(Colors.PRIMARY_LIGHT)
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onClick(() => this.addTag())
            }
            .margin({ bottom: 12 })
            
            // 标签建议
            Text('建议标签：')
              .fontSize(12)
              .fontColor(Colors.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.suggestedTags, (tag: string) => {
                Row({ space: 4 }) {
                  Text(`#${tag}`)
                    .fontSize(12)
                    .fontColor(Colors.PRIMARY)
                }
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(Colors.PRIMARY_LIGHT)
                .borderRadius(12)
                .border({ width: 1, color: Colors.PRIMARY })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  if (!this.tags.includes(tag)) {
                    this.tags.push(tag);
                  }
                })
              })
            }
            .margin({ bottom: 12 })
            
            // 已选标签
            if (this.tags.length > 0) {
              Text('已选标签：')
                .fontSize(12)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ bottom: 8 })
              
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.tags, (tag: string, index: number) => {
                  Row({ space: 4 }) {
                    Text(`#${tag}`)
                      .fontSize(12)
                      .fontColor(Colors.PRIMARY)
                    
                    Text('×')
                      .fontSize(10)
                      .fontColor(Colors.ERROR)
                      .onClick(() => this.removeTag(index))
                  }
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(Colors.PRIMARY_LIGHT)
                  .borderRadius(12)
                  .border({ width: 1, color: Colors.PRIMARY })
                  .margin({ right: 8, bottom: 8 })
                })
              }
            }
          }
          .padding({ left: 16, right: 16 })

          // 保存按钮
          Button('保存笔记', { type: ButtonType.Capsule })
            .fontSize(16)
            .fontColor(Colors.TEXT_ON_PRIMARY)
            .backgroundColor(Colors.PRIMARY)
            .width('90%')
            .height(48)
            .margin({ top: 24, bottom: 40 })
            .onClick(() => this.saveMemo())
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BACKGROUND)
  }
}