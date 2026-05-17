import { Colors } from '../constants/Colors';
import { StorageManager } from '../utils/StorageManager';
import { Memo } from '../model/Memo';
import { AIService } from '../services/AIService';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct MemoDetailPage {
  @State private memo: Memo = new Memo();
  @State private isLoading: boolean = true;
  @State private isEditing: boolean = false;
  @State private editTitle: string = '';
  @State private editContent: string = '';
  @State private isPolishing: boolean = false;
  
  // 【新增】动画状态
  @State private pageOpacity: number = 0;
  
  private memoId: string = '';
  private storageManager: StorageManager = StorageManager.getInstance();

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.memoId) {
      this.memoId = params.memoId;
      this.loadMemo();
    }
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }

  // 页面每次显示时刷新数据
  onPageShow() {
    if (this.memoId) {
      this.loadMemo();
    }
  }

  async loadMemo(): Promise<void> {
    this.isLoading = true;
    try {
      const memos: Memo[] = await this.storageManager.getMemos();
      const foundMemo: Memo | undefined = memos.find((m: Memo): boolean => m.id === this.memoId);
      if (foundMemo) {
        this.memo = foundMemo;
        this.editTitle = foundMemo.title;
        this.editContent = foundMemo.content;
      } else {
        prompt.showToast({ message: '笔记不存在', duration: 2000 });
        router.back();
      }
    } catch (error) {
      console.error('加载笔记失败:', error);
      prompt.showToast({ message: '加载失败', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  // 切换编辑模式
  toggleEdit(): void {
    this.isEditing = !this.isEditing;
    if (!this.isEditing) {
      // 退出编辑模式时恢复原内容
      this.editTitle = this.memo.title;
      this.editContent = this.memo.content;
    }
  }

  // 保存编辑
  async saveEdit(): Promise<void> {
    if (!this.editTitle.trim() && !this.editContent.trim()) {
      prompt.showToast({ message: '标题和内容不能都为空', duration: 2000 });
      return;
    }

    try {
      this.memo.title = this.editTitle.trim() || '无标题';
      this.memo.content = this.editContent.trim() || '无内容';
      this.memo.updatedAt = Date.now();
      
      await this.storageManager.saveMemo(this.memo);
      this.isEditing = false;
      prompt.showToast({ message: '保存成功', duration: 1500 });
    } catch (error) {
      console.error('保存失败:', error);
      prompt.showToast({ message: '保存失败', duration: 2000 });
    }
  }

  // 删除笔记
  async deleteMemo(): Promise<void> {
    try {
      await this.storageManager.deleteMemo(this.memoId);
      prompt.showToast({ message: '删除成功', duration: 1500 });
      router.back();
    } catch (error) {
      console.error('删除失败:', error);
      prompt.showToast({ message: '删除失败', duration: 2000 });
    }
  }

  // 切换完成状态
  async toggleComplete(): Promise<void> {
    try {
      this.memo.isCompleted = !this.memo.isCompleted;
      this.memo.updatedAt = Date.now();
      await this.storageManager.saveMemo(this.memo);
      prompt.showToast({ 
        message: this.memo.isCompleted ? '标记为已完成' : '标记为未完成', 
        duration: 1500 
      });
    } catch (error) {
      console.error('更新状态失败:', error);
      prompt.showToast({ message: '操作失败', duration: 2000 });
    }
  }

  // AI润色
  async polishWithAI(): Promise<void> {
    if (!this.editContent.trim()) {
      prompt.showToast({ message: '请输入需要润色的内容', duration: 2000 });
      return;
    }

    this.isPolishing = true;
    try {
      this.editContent = await AIService.polishMemo(this.editContent);
      prompt.showToast({ message: 'AI润色完成', duration: 1500 });
    } catch (error) {
      console.error('AI润色失败:', error);
      prompt.showToast({ message: '润色失败，请重试', duration: 2000 });
    } finally {
      this.isPolishing = false;
    }
  }

  // 格式化日期
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    
    return `${year}年${month}月${day}日 ${hour}:${minute}`;
  }

  // 获取优先级标签
  getPriorityLabel(priority: number): string {
    const labels = ['低', '中', '高'];
    return labels[priority - 1] || '中';
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
          .fontColor(Colors.TEXT_SECONDARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
          .margin({ left: 16 })
        
        Text('笔记详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 编辑/保存按钮
        if (this.isEditing) {
          Button('保存')
            .fontSize(14)
            .fontColor(Colors.PRIMARY)
            .backgroundColor(Color.Transparent)
            .onClick(() => this.saveEdit())
            .margin({ right: 8 })
        }
        
        Button(this.isEditing ? '取消' : '编辑')
          .fontSize(14)
          .fontColor(this.isEditing ? Colors.ERROR : Colors.PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.toggleEdit())
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
            // 笔记卡片
            Column() {
              // 标题区域
              if (this.isEditing) {
                TextInput({ text: this.editTitle })
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .backgroundColor(Colors.SURFACE)
                  .border({ width: 1, color: Colors.BORDER, radius: 8 })
                  .padding(12)
                  .onChange((value: string) => {
                    this.editTitle = value;
                  })
              } else {
                Text(this.memo.title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .margin({ bottom: 8 })
              }

              // 元信息
              Row() {
                // 心情
                Column() {
                  Text(this.memo.mood)
                    .fontSize(16)
                }
                .padding(8)
                .backgroundColor(Colors.MOOD_BACKGROUNDS[this.memo.mood] || Colors.SURFACE_VARIANT)
                .borderRadius(8)
                .margin({ right: 8 })

                // 优先级
                Column() {
                  Text(`P${this.memo.priority}`)
                    .fontSize(12)
                    .fontColor(Colors.TEXT_ON_PRIMARY)
                }
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(Colors.PRIORITY_COLORS[this.memo.priority])
                .borderRadius(8)
                .margin({ right: 8 })

                // 完成状态
                if (this.memo.isCompleted) {
                  Column() {
                    Text('已完成')
                      .fontSize(12)
                      .fontColor(Colors.TEXT_ON_PRIMARY)
                  }
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(Colors.SUCCESS)
                  .borderRadius(8)
                }

                Blank()

                // 创建时间
                Text(this.formatDate(this.memo.createdAt))
                  .fontSize(12)
                  .fontColor(Colors.TEXT_SECONDARY)
              }
              .margin({ top: 12, bottom: 16 })

              Divider()
                .strokeWidth(1)
                .color(Colors.DIVIDER)
                .margin({ bottom: 16 })

              // 内容区域
              if (this.isEditing) {
                Column() {
                  TextArea({ text: this.editContent })
                    .fontSize(14)
                    .fontColor(Colors.TEXT_PRIMARY)
                    .backgroundColor(Colors.SURFACE)
                    .border({ width: 1, color: Colors.BORDER, radius: 8 })
                    .padding(12)
                    .height(300)
                    .onChange((value: string) => {
                      this.editContent = value;
                    })
                  
                  // AI润色按钮
                  Row({ space: 8 }) {
                    if (this.isPolishing) {
                      LoadingProgress()
                        .width(16)
                        .height(16)
                        .color(Colors.SECONDARY)
                      Text('润色中...')
                        .fontSize(12)
                        .fontColor(Colors.TEXT_SECONDARY)
                    } else {
                      Button('AI润色')
                        .fontSize(12)
                        .fontColor(Colors.SECONDARY)
                        .backgroundColor(Colors.SECONDARY_LIGHT)
                        .borderRadius(12)
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .onClick(() => this.polishWithAI())
                    }
                  }
                  .margin({ top: 12 })
                }
              } else {
                Text(this.memo.content)
                  .fontSize(14)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .lineHeight(20)
              }

              // 标签区域
              if (this.memo.tags.length > 0) {
                Divider()
                  .strokeWidth(1)
                  .color(Colors.DIVIDER)
                  .margin({ top: 16, bottom: 12 })

                Text('标签')
                  .fontSize(12)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .margin({ bottom: 8 })

                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.memo.tags, (tag: string) => {
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
                  })
                }
              }
            }
            .padding(20)
            .backgroundColor(Colors.SURFACE)
            .borderRadius(16)
            .shadow({ radius: 8, color: Colors.SHADOW })
            .margin({ top: 16, left: 16, right: 16 })

            // 操作按钮
            if (!this.isEditing) {
              Row({ space: 12 }) {
                Button('标记完成', { type: ButtonType.Capsule })
                  .fontSize(14)
                  .fontColor(this.memo.isCompleted ? Colors.TEXT_SECONDARY : Colors.TEXT_ON_PRIMARY)
                  .backgroundColor(this.memo.isCompleted ? Colors.SURFACE_VARIANT : Colors.SUCCESS)
                  .border({ 
                    width: 1, 
                    color: this.memo.isCompleted ? Colors.BORDER : Colors.SUCCESS,
                    radius: 24 
                  })
                  .layoutWeight(1)
                  .height(40)
                  .onClick(() => this.toggleComplete())
                
                Button('删除', { type: ButtonType.Capsule })
                  .fontSize(14)
                  .fontColor(Colors.TEXT_ON_PRIMARY)
                  .backgroundColor(Colors.ERROR)
                  .layoutWeight(1)
                  .height(40)
                  .onClick(() => this.deleteMemo())
              }
              .padding({ left: 16, right: 16 })
            }

            // 笔记信息卡片
            Column() {
              Text('📋 笔记信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ bottom: 16 })
              
              Row() {
                Column({ space: 8 }) {
                  this.buildInfoItem('创建时间', this.formatDate(this.memo.createdAt))
                  this.buildInfoItem('更新时间', this.formatDate(this.memo.updatedAt))
                }
                .layoutWeight(1)
                
                Column({ space: 8 }) {
                  this.buildInfoItem('心情', `${this.memo.mood} ${this.getMoodDescription(this.memo.mood)}`)
                  this.buildInfoItem('优先级', `P${this.memo.priority} ${this.getPriorityLabel(this.memo.priority)}`)
                }
                .layoutWeight(1)
              }
              
              Column({ space: 8 }) {
                if (this.memo.dueDate) {
                  this.buildInfoItem('截止日期', this.formatDate(this.memo.dueDate))
                }
                
                this.buildInfoItem('状态', this.memo.isCompleted ? '✅ 已完成' : '⏳ 进行中')
              }
              .margin({ top: 8 })
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
  buildInfoItem(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor(Colors.TEXT_SECONDARY)
        .width(80)
      
      Text(value)
        .fontSize(12)
        .fontColor(Colors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
  }
}