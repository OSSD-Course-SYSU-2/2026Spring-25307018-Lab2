import { Colors } from '../constants/Colors';
import { AIService } from '../services/AIService';
import { StorageManager } from '../utils/StorageManager';
import { Memo } from '../model/Memo';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct AIPage {
  @State private prompt: string = '';
  @State private generatedTitle: string = '';
  @State private generatedContent: string = '';
  @State private isGenerating: boolean = false;
  @State private isAnalyzing: boolean = false;
  @State private analysisResult: string = '';
  @State private selectedMood: string = '😊';
  @State private selectedPriority: number = 2;
  
  // 【新增】动画状态
  @State private pageOpacity: number = 0;
  @State private generateBtnScale: number = 1;
  
  // 心情选项
  private moods: string[] = ['😊', '😄', '😍', '🥳', '😎', '😌', '😐', '😔', '😢', '😠', '😴', '🤔'];
  
  // 示例提示词
  private examplePrompts: string[] = [
    '写一份购物清单',
    '制定学习计划',
    '记录工作会议要点',
    '旅行计划安排',
    '健身锻炼计划',
    '读书笔记摘要',
    '项目进度总结',
    '创意灵感记录'
  ];

  private storageManager: StorageManager = StorageManager.getInstance();

  aboutToAppear() {
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }

  // AI生成笔记
  async generateMemo(): Promise<void> {
    if (!this.prompt.trim()) {
      prompt.showToast({ message: '请输入提示词', duration: 2000 });
      return;
    }

    this.isGenerating = true;
    try {
      const result = await AIService.generateMemo(this.prompt);
      this.generatedTitle = result.title;
      this.generatedContent = result.content;
      prompt.showToast({ message: '生成成功', duration: 1500 });
    } catch (error) {
      console.error('生成失败:', error);
      prompt.showToast({ message: '生成失败，请重试', duration: 2000 });
    } finally {
      this.isGenerating = false;
    }
  }

  // 分析心情趋势
  async analyzeMoodTrend(): Promise<void> {
    this.isAnalyzing = true;
    try {
      const memos: Memo[] = await this.storageManager.getMemos();
      this.analysisResult = await AIService.analyzeMoodTrend(memos);
      prompt.showToast({ message: '分析完成', duration: 1500 });
    } catch (error) {
      console.error('分析失败:', error);
      prompt.showToast({ message: '分析失败，请重试', duration: 2000 });
    } finally {
      this.isAnalyzing = false;
    }
  }

  // 保存生成的笔记
  async saveGeneratedMemo(): Promise<void> {
    if (!this.generatedContent.trim()) {
      prompt.showToast({ message: '请先生成内容', duration: 2000 });
      return;
    }

    const memo = new Memo(
      `memo_${Date.now()}`,
      this.generatedTitle || 'AI生成的笔记',
      this.generatedContent,
      false,
      this.selectedPriority,
      this.selectedMood,
      [], // AI会生成标签
      Date.now(),
      Date.now()
    );

    try {
      // 获取AI建议的标签
      const suggestedTags = await AIService.suggestTags(this.generatedContent);
      memo.tags = suggestedTags;
      
      await this.storageManager.saveMemo(memo);
      prompt.showToast({ message: '保存成功', duration: 1500 });
      
      // 清空内容
      this.generatedTitle = '';
      this.generatedContent = '';
      this.prompt = '';
    } catch (error) {
      console.error('保存失败:', error);
      prompt.showToast({ message: '保存失败', duration: 2000 });
    }
  }

  // 使用示例提示词
  useExamplePrompt(promptText: string): void {
    this.prompt = promptText;
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
        
        Text('AI助手')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('分析')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.analyzeMoodTrend())
          .enabled(!this.isAnalyzing)
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Colors.SURFACE)
      .shadow({ radius: 4, color: Colors.SHADOW })

      Scroll() {
        Column({ space: 16 }) {
          // AI生成区域
          Column() {
            Text('🤖 AI智能生成')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.TEXT_PRIMARY)
              .margin({ bottom: 12 })
            
            // 提示词输入
            Column() {
              Text('输入提示词')
                .fontSize(14)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ bottom: 8 })
              
              TextInput({ placeholder: '例如：写一份购物清单...', text: this.prompt })
                .placeholderColor(Colors.TEXT_HINT)
                .placeholderFont({ size: 14 })
                .onChange((value: string) => {
                  this.prompt = value;
                })
                .fontSize(14)
                .fontColor(Colors.TEXT_PRIMARY)
                .backgroundColor('#F5F5FA')
                .border({ width: 1, color: Colors.BORDER, radius: 14 })
                .padding(14)
            }
            .width('100%')
            
            // 示例提示词
            Column() {
              Text('示例提示词')
                .fontSize(12)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ bottom: 8 })
              
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.examplePrompts, (example: string) => {
                  Button(example)
                    .fontSize(12)
                    .fontColor(Colors.PRIMARY)
                    .backgroundColor(Colors.PRIMARY_LIGHT)
                    .borderRadius(14)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => this.useExamplePrompt(example))
                })
              }
            }
            .width('100%')
            .margin({ top: 12 })
            
            // 生成按钮
            Button('生成笔记', { type: ButtonType.Capsule })
              .fontSize(15)
              .fontColor(Colors.TEXT_ON_PRIMARY)
              .linearGradient({
                angle: 135,
                colors: [[Colors.PRIMARY, 0], [Colors.PRIMARY_DARK, 1]]
              })
              .width('100%')
              .height(48)
              .borderRadius(16)
              .margin({ top: 16 })
              .onClick(() => this.generateMemo())
              .enabled(!this.isGenerating && this.prompt.trim().length > 0)
            
            if (this.isGenerating) {
              Row({ space: 8 }) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .color(Colors.PRIMARY)
                Text('AI正在生成中...')
                  .fontSize(12)
                  .fontColor(Colors.TEXT_SECONDARY)
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .margin({ top: 8 })
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
          .margin({ top: 16, left: 16, right: 16 })

          // 生成结果
          if (this.generatedContent) {
            Column() {
              Row() {
                Text('✨ 生成结果')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .layoutWeight(1)
              }
              .margin({ bottom: 12 })
              
              // 标题
              if (this.generatedTitle) {
                Text(this.generatedTitle)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .margin({ bottom: 8 })
              }
              
              // 内容
              Text(this.generatedContent)
                .fontSize(14)
                .fontColor(Colors.TEXT_PRIMARY)
                .lineHeight(20)
                .textAlign(TextAlign.Start)
                .margin({ bottom: 16 })
              
              // 心情和优先级选择
              Column({ space: 12 }) {
                Text('选择心情和优先级')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                
                // 心情选择
                Scroll() {
                  Row({ space: 12 }) {
                    ForEach(this.moods, (mood: string) => {
                      Column() {
                        Text(mood)
                          .fontSize(20)
                        Text(this.getMoodDescription(mood))
                          .fontSize(10)
                          .fontColor(this.selectedMood === mood ? Colors.TEXT_ON_PRIMARY : Colors.TEXT_SECONDARY)
                          .margin({ top: 4 })
                      }
                      .padding(12)
                      .backgroundColor(this.selectedMood === mood ? Colors.MOOD_COLORS[mood] : Colors.SURFACE_VARIANT)
                      .borderRadius(12)
                      .border({ 
                        width: this.selectedMood === mood ? 2 : 1, 
                        color: this.selectedMood === mood ? Colors.PRIMARY : Colors.BORDER 
                      })
                      .onClick(() => {
                        this.selectedMood = mood;
                      })
                    })
                  }
                  .padding({ left: 4, right: 4 })
                }
                .scrollBar(BarState.Off)
                .scrollable(ScrollDirection.Horizontal)
                
                // 优先级选择
                Row({ space: 12 }) {
                  ForEach([1, 2, 3], (priority: number) => {
                    Column() {
                      Text(['低', '中', '高'][priority - 1])
                        .fontSize(14)
                        .fontColor(this.selectedPriority === priority ? Colors.TEXT_ON_PRIMARY : Colors.TEXT_PRIMARY)
                      
                      Text(['⭐', '⭐⭐', '⭐⭐⭐'][priority - 1])
                        .fontSize(16)
                        .margin({ top: 4 })
                    }
                    .padding(16)
                    .backgroundColor(this.selectedPriority === priority ? Colors.PRIORITY_COLORS[priority] : Colors.SURFACE_VARIANT)
                    .borderRadius(12)
                    .border({ 
                      width: this.selectedPriority === priority ? 2 : 1, 
                      color: this.selectedPriority === priority ? Colors.PRIORITY_COLORS[priority] : Colors.BORDER 
                    })
                    .onClick(() => {
                      this.selectedPriority = priority;
                    })
                  })
                }
                .justifyContent(FlexAlign.SpaceEvenly)
              }
              .margin({ top: 16 })
              
              // 保存按钮
              Button('保存到笔记', { type: ButtonType.Capsule })
                .fontSize(14)
                .fontColor(Colors.TEXT_ON_PRIMARY)
                .backgroundColor(Colors.SECONDARY)
                .width('100%')
                .height(40)
                .margin({ top: 16 })
                .onClick(() => this.saveGeneratedMemo())
            }
            .padding(20)
            .backgroundColor(Colors.SURFACE)
            .borderRadius(16)
            .shadow({ radius: 8, color: Colors.SHADOW })
            .margin({ left: 16, right: 16 })
          }

          // 【新增】记忆寻宝快捷入口
          Column() {
            Row() {
              Text('🗺️ 记忆寻宝')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .layoutWeight(1)
              
              Button('开始寻宝')
                .fontSize(12)
                .fontColor(Colors.TEXT_ON_PRIMARY)
                .backgroundColor(Colors.SECONDARY)
                .borderRadius(12)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .onClick(() => router.pushUrl({ url: 'pages/TreasureHuntPage' }))
            }
            .width('100%')
            .margin({ bottom: 12 })
            
            Text('从历史笔记中寻找宝藏，获得星球碎片和抽奖机会！')
              .fontSize(14)
              .fontColor(Colors.TEXT_SECONDARY)
              .margin({ bottom: 12 })
            
            Row({ space: 8 }) {
              Text('✨ 奖励碎片')
                .fontSize(12)
                .fontColor(Colors.PRIMARY)
              
              Text('🎁 抽奖机会')
                .fontSize(12)
                .fontColor(Colors.SECONDARY)
              
              Text('🏆 解锁成就')
                .fontSize(12)
                .fontColor(Colors.ACCENT)
            }
          }
          .padding(20)
          .backgroundColor(Colors.SURFACE)
          .borderRadius(16)
          .shadow({ radius: 8, color: Colors.SHADOW })
          .margin({ left: 16, right: 16 })

          // 心情分析
          Column() {
            Row() {
              Text('📊 心情分析')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .layoutWeight(1)
              
              Button('开始分析')
                .fontSize(12)
                .fontColor(Colors.PRIMARY)
                .backgroundColor(Colors.PRIMARY_LIGHT)
                .borderRadius(12)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .onClick(() => this.analyzeMoodTrend())
                .enabled(!this.isAnalyzing)
            }
            .margin({ bottom: 12 })
            
            if (this.isAnalyzing) {
              Row({ space: 8 }) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .color(Colors.PRIMARY)
                Text('正在分析心情趋势...')
                  .fontSize(12)
                  .fontColor(Colors.TEXT_SECONDARY)
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .padding(20)
            } else if (this.analysisResult) {
              Text(this.analysisResult)
                .fontSize(14)
                .fontColor(Colors.TEXT_PRIMARY)
                .lineHeight(20)
                .textAlign(TextAlign.Start)
                .padding(16)
                .backgroundColor(Colors.SURFACE_VARIANT)
                .borderRadius(8)
            } else {
              Text('点击"开始分析"按钮，AI将分析您的心情记录趋势并提供建议')
                .fontSize(14)
                .fontColor(Colors.TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .padding(20)
            }
          }
          .padding(20)
          .backgroundColor(Colors.SURFACE)
          .borderRadius(16)
          .shadow({ radius: 8, color: Colors.SHADOW })
          .margin({ left: 16, right: 16 })

          // AI功能说明
          Column() {
            Text('💡 AI功能说明')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.TEXT_PRIMARY)
              .margin({ bottom: 12 })
            
            Column({ space: 8 }) {
              Row({ space: 8 }) {
                Text('•')
                  .fontSize(14)
                  .fontColor(Colors.PRIMARY)
                Text('智能生成：根据提示词自动生成结构化的笔记内容')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .layoutWeight(1)
              }
              
              Row({ space: 8 }) {
                Text('•')
                  .fontSize(14)
                  .fontColor(Colors.PRIMARY)
                Text('智能润色：优化现有笔记内容，使其更加清晰有条理')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .layoutWeight(1)
              }
              
              Row({ space: 8 }) {
                Text('•')
                  .fontSize(14)
                  .fontColor(Colors.PRIMARY)
                Text('心情分析：分析您的心情记录趋势，提供个性化建议')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .layoutWeight(1)
              }
              
              Row({ space: 8 }) {
                Text('•')
                  .fontSize(14)
                  .fontColor(Colors.PRIMARY)
                Text('标签建议：自动为笔记推荐合适的标签')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .layoutWeight(1)
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
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BACKGROUND)
  }
}