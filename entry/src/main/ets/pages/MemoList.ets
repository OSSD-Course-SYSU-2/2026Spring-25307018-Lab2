import { StorageManager } from '../utils/StorageManager';
import { Memo } from '../model/Memo';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct MemoList {
  @State private memos: Memo[] = [];
  @State private filteredMemos: Memo[] = [];
  @State private searchText: string = '';
  @State private filterStatus: string = 'all'; // all, completed, pending
  @State private filterPriority: number = 0; // 0: all, 1: low, 2: medium, 3: high
  @State private isLoading: boolean = true;
  @State private showAddDialog: boolean = false;
  @State private newMemoTitle: string = '';
  @State private newMemoContent: string = '';
  @State private newMemoPriority: number = 2;
  @State private newMemoMood: string = '😊';
  
  // 【新增】动画状态
  @State private pageOpacity: number = 0;

  private storageManager: StorageManager = StorageManager.getInstance();

  aboutToAppear() {
    this.loadMemos();
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }

  // 页面每次显示时刷新数据
  onPageShow() {
    this.loadMemos();
  }

  async loadMemos(): Promise<void> {
    this.isLoading = true;
    try {
      this.memos = await this.storageManager.getMemos();
      this.applyFilters();
    } catch (error) {
      console.error('加载备忘录失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  applyFilters() {
    let filtered = [...this.memos];

    // 搜索过滤
    if (this.searchText.trim()) {
      const keyword = this.searchText.toLowerCase();
      filtered = filtered.filter(memo =>
        memo.title.toLowerCase().includes(keyword) ||
        memo.content.toLowerCase().includes(keyword) ||
        memo.tags.some(tag => tag.toLowerCase().includes(keyword))
      );
    }

    // 状态过滤
    if (this.filterStatus === 'completed') {
      filtered = filtered.filter(memo => memo.isCompleted);
    } else if (this.filterStatus === 'pending') {
      filtered = filtered.filter(memo => !memo.isCompleted);
    }

    // 优先级过滤
    if (this.filterPriority > 0) {
      filtered = filtered.filter(memo => memo.priority === this.filterPriority);
    }

    // 按创建时间排序（最新的在前）
    filtered.sort((a, b) => b.createdAt - a.createdAt);
    
    this.filteredMemos = filtered;
  }

  async toggleMemoCompletion(memo: Memo) {
    memo.isCompleted = !memo.isCompleted;
    memo.updatedAt = Date.now();
    await this.storageManager.saveMemo(memo);
    await this.loadMemos();
    
    prompt.showToast({
      message: memo.isCompleted ? '备忘录已完成！' : '备忘录标记为未完成',
      duration: 1500
    });
  }

  async deleteMemo(memo: Memo) {
    // 显示确认对话框
    AlertDialog.show({
      title: '删除备忘录',
      message: `确定要删除"${memo.title}"吗？`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        backgroundColor: $r('app.color.error'),
        action: async () => {
          await this.storageManager.deleteMemo(memo.id);
          await this.loadMemos();
          prompt.showToast({
            message: '备忘录已删除',
            duration: 1500
          });
        }
      }
    });
  }

  navigateToDetail(memo?: Memo) {
    if (memo) {
      router.pushUrl({
        url: 'pages/MemoDetail',
        params: { memoId: memo.id }
      });
    } else {
      router.pushUrl({
        url: 'pages/MemoDetail'
      });
    }
  }

  async addNewMemo() {
    if (!this.newMemoTitle.trim()) {
      prompt.showToast({
        message: '请输入标题',
        duration: 1500
      });
      return;
    }

    const memo = new Memo(
      '',
      this.newMemoTitle.trim(),
      this.newMemoContent.trim(),
      false,
      this.newMemoPriority,
      this.newMemoMood,
      [],
      Date.now(),
      Date.now()
    );

    await this.storageManager.saveMemo(memo);
    
    // 重置表单
    this.newMemoTitle = '';
    this.newMemoContent = '';
    this.newMemoPriority = 2;
    this.newMemoMood = '😊';
    this.showAddDialog = false;
    
    await this.loadMemos();
    
    prompt.showToast({
      message: '备忘录已添加',
      duration: 1500
    });
  }

  build() {
    Column({ space: 0 }) {
      // 应用栏
      Row() {
        Button('返回')
          .fontSize($r('app.float.font_size_medium'))
          .fontColor($r('app.color.primary_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
          .margin({ left: $r('app.float.padding_small') })
        
        Text($r('app.string.memo_list_title'))
          .fontSize($r('app.float.font_size_xlarge'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button($r('app.string.add_memo'))
          .fontSize($r('app.float.font_size_medium'))
          .fontColor($r('app.color.primary_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.navigateToDetail())
          .margin({ right: $r('app.float.padding_small') })
      }
      .width('100%')
      .height(56)
      .backgroundColor($r('app.color.surface'))
      .shadow({ radius: $r('app.float.appbar_elevation'), color: $r('app.color.shadow') })

      // 搜索和过滤栏
      Column({ space: $r('app.float.padding_small') }) {
        // 搜索框
        TextInput({ placeholder: $r('app.string.search_hint'), text: this.searchText })
          .placeholderColor($r('app.color.text_hint'))
          .placeholderFont({ size: $r('app.float.font_size_medium') })
          .textAlign(TextAlign.Start)
          .fontSize($r('app.float.font_size_medium'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.surface'))
          .borderRadius($r('app.float.border_radius_medium'))
          .padding({ left: $r('app.float.padding_medium'), right: $r('app.float.padding_medium') })
          .height($r('app.float.input_height'))
          .onChange((value: string) => {
            this.searchText = value;
            this.applyFilters();
          })

        // 过滤选项
        Row({ space: 4 }) {
          // 状态过滤
          Row({ space: 4 }) {
            ForEach(['all', 'pending', 'completed'], (status: string) => {
              Button(this.getStatusText(status))
                .fontSize(10)
                .fontColor(this.filterStatus === status ? Color.White : $r('app.color.text_primary'))
                .backgroundColor(this.filterStatus === status ? $r('app.color.primary_color') : $r('app.color.surface'))
                .borderRadius($r('app.float.border_radius_medium'))
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .onClick(() => {
                  this.filterStatus = status;
                  this.applyFilters();
                })
            })
          }
          .layoutWeight(1)

          // 优先级过滤
          Row({ space: 4 }) {
            ForEach([0, 1, 2, 3], (priority: number) => {
              Button(this.getPriorityText(priority))
                .fontSize(10)
                .fontColor(this.filterPriority === priority ? Color.White : $r('app.color.text_primary'))
                .backgroundColor(this.filterPriority === priority ? $r('app.color.secondary_color') : $r('app.color.surface'))
                .borderRadius($r('app.float.border_radius_medium'))
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .onClick(() => {
                  this.filterPriority = priority;
                  this.applyFilters();
                })
            })
          }
        }
        .padding($r('app.float.padding_small'))
        .backgroundColor($r('app.color.background'))
      }
      .padding($r('app.float.padding_medium'))
      .backgroundColor($r('app.color.surface'))

      // 备忘录列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color($r('app.color.primary_color'))
          Text('加载中...')
            .fontSize($r('app.float.font_size_medium'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: $r('app.float.padding_medium') })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.filteredMemos.length === 0) {
        Column() {
          Text('📝')
            .fontSize(48)
            .margin({ bottom: $r('app.float.padding_large') })
          Text($r('app.string.no_memos'))
            .fontSize($r('app.float.font_size_medium'))
            .fontColor($r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: $r('app.float.padding_large') })
          Button('添加备忘录')
            .fontSize($r('app.float.font_size_medium'))
            .fontColor(Color.White)
            .backgroundColor('#007AFF')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .onClick(() => this.navigateToDetail())
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.filteredMemos, (memo: Memo) => {
            ListItem() {
              this.buildMemoItem(memo)
            }
          }, (memo: Memo) => memo.id)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: $r('app.color.divider') })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildMemoItem(memo: Memo) {
    Column({ space: $r('app.float.padding_small') }) {
      Row() {
        // 完成状态复选框
        Button(memo.isCompleted ? '✓' : '○')
          .fontSize($r('app.float.font_size_medium'))
          .fontColor(memo.isCompleted ? $r('app.color.success') : $r('app.color.text_hint'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.toggleMemoCompletion(memo))
        
        Column({ space: 4 }) {
          // 标题和优先级
          Row() {
            Text(memo.title || '无标题')
              .fontSize($r('app.float.font_size_large'))
              .fontWeight(FontWeight.Medium)
              .fontColor(memo.isCompleted ? $r('app.color.text_hint') : $r('app.color.text_primary'))
              .decoration({ type: memo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            
            if (memo.priority > 1) {
              Text(this.getPriorityText(memo.priority))
                .fontSize($r('app.float.font_size_small'))
                .fontColor(Color.White)
                .backgroundColor(this.getPriorityColor(memo.priority) as ResourceColor)
                .borderRadius(10)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            }
          }
          
          // 内容预览
          if (memo.content) {
            Text(memo.content)
              .fontSize($r('app.float.font_size_medium'))
              .fontColor($r('app.color.text_secondary'))
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          
          // 标签和心情
          Row() {
            // 心情表情
            Text(memo.mood)
              .fontSize(16)
              .margin({ right: $r('app.float.padding_small') })
            
            // 标签
            if (memo.tags && memo.tags.length > 0) {
              ForEach(memo.tags.slice(0, 3), (tag: string) => {
                Text(`#${tag}`)
                  .fontSize($r('app.float.font_size_small'))
                  .fontColor($r('app.color.secondary_color'))
                  .backgroundColor($r('app.color.secondary_light'))
                  .borderRadius(10)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ right: $r('app.float.padding_small') })
              })
            }
            
            Blank()
            
            // 日期
            Text(this.formatDate(memo.createdAt))
              .fontSize($r('app.float.font_size_small'))
              .fontColor($r('app.color.text_hint'))
          }
        }
        .layoutWeight(1)
        .margin({ left: $r('app.float.padding_small') })
        
        // 操作按钮
        Button('···')
          .fontSize($r('app.float.font_size_medium'))
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.showMemoActions(memo))
      }
      
      // 过期提醒
      if (memo.isOverdue()) {
        Row() {
          Text('⚠️')
            .fontSize(12)
            .margin({ right: 4 })
          Text('已过期')
            .fontSize($r('app.float.font_size_small'))
            .fontColor($r('app.color.error'))
        }
        .padding({ left: $r('app.float.padding_small'), right: $r('app.float.padding_small'), top: 2, bottom: 2 })
        .backgroundColor($r('app.color.error'))
        .opacity(0.1)
        .borderRadius(4)
        .margin({ top: $r('app.float.padding_small') })
      }
    }
    .padding($r('app.float.padding_medium'))
    .backgroundColor($r('app.color.surface'))
    .borderRadius($r('app.float.border_radius_medium'))
    .onClick(() => this.navigateToDetail(memo))
  }

  showMemoActions(memo: Memo) {
    ActionSheet.show({
      title: memo.title || '备忘录操作',
      message: '请选择操作',
      autoCancel: true,
      confirm: {
        value: '取消',
        action: () => {}
      },
      sheets: [
        {
          title: memo.isCompleted ? '标记为未完成' : '标记为完成',
          action: () => this.toggleMemoCompletion(memo)
        },
        {
          title: '编辑',
          action: () => this.navigateToDetail(memo)
        },
        {
          title: '删除',
          action: () => this.deleteMemo(memo)
        }
      ]
    });
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'all': return '全部';
      case 'pending': return '未完成';
      case 'completed': return '已完成';
      default: return '全部';
    }
  }

  getPriorityText(priority: number): string {
    switch (priority) {
      case 0: return '全部';
      case 1: return '低';
      case 2: return '中';
      case 3: return '高';
      default: return '全部';
    }
  }

  getPriorityColor(priority: number): string {
    switch (priority) {
      case 1: return '#52C41A'; // 低 - 绿色
      case 2: return '#FAAD14'; // 中 - 黄色
      case 3: return '#FF4D4F'; // 高 - 红色
      default: return '#FAAD14';
    }
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const memoDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    
    const diffTime = today.getTime() - memoDate.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) {
      return '今天';
    } else if (diffDays === 1) {
      return '昨天';
    } else if (diffDays < 7) {
      return `${diffDays}天前`;
    } else {
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    }
  }
}