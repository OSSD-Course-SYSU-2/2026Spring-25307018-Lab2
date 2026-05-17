// 应用常量定义
export class Constants {
  // 应用信息
  static readonly APP_NAME = '趣味备忘录';
  static readonly APP_VERSION = '1.0.0';
  
  // 颜色常量
  static readonly COLORS = {
    PRIMARY: '#4CAF50',
    PRIMARY_DARK: '#388E3C',
    PRIMARY_LIGHT: '#C8E6C9',
    SECONDARY: '#2196F3',
    SECONDARY_DARK: '#1976D2',
    SECONDARY_LIGHT: '#BBDEFB',
    ACCENT: '#FF9800',
    TEXT_PRIMARY: '#212121',
    TEXT_SECONDARY: '#757575',
    TEXT_HINT: '#BDBDBD',
    BACKGROUND: '#F5F5F5',
    SURFACE: '#FFFFFF',
    ERROR: '#F44336',
    SUCCESS: '#4CAF50',
    WARNING: '#FF9800',
    INFO: '#2196F3',
    DIVIDER: '#E0E0E0',
    SHADOW: '#000000'
  };
  
  // 心情颜色映射
  static readonly MOOD_COLORS: Record<string, string> = {
    '😊': '#FFEB3B', // 开心 - 黄色
    '😄': '#4CAF50', // 大笑 - 绿色
    '😍': '#E91E63', // 喜爱 - 粉色
    '🥳': '#9C27B0', // 庆祝 - 紫色
    '😎': '#2196F3', // 酷 - 蓝色
    '😌': '#009688', // 平静 - 青色
    '😐': '#9E9E9E', // 一般 - 灰色
    '😔': '#607D8B', // 沮丧 - 蓝灰色
    '😢': '#3F51B5', // 哭泣 - 深蓝色
    '😠': '#F44336', // 生气 - 红色
    '😴': '#795548', // 困倦 - 棕色
    '🤔': '#FF9800'  // 思考 - 橙色
  };
  
  // 心情描述
  static readonly MOOD_DESCRIPTIONS: Record<string, string> = {
    '😊': '开心',
    '😄': '大笑',
    '😍': '喜爱',
    '🥳': '庆祝',
    '😎': '酷',
    '😌': '平静',
    '😐': '一般',
    '😔': '沮丧',
    '😢': '哭泣',
    '😠': '生气',
    '😴': '困倦',
    '🤔': '思考'
  };
  
  // 优先级选项
  static readonly PRIORITIES = [
    { value: 1, label: '低', color: '#4CAF50' },
    { value: 2, label: '中', color: '#FF9800' },
    { value: 3, label: '高', color: '#F44336' }
  ];
  
  // 标签颜色
  static readonly TAG_COLORS = [
    '#FF5252', '#FF4081', '#E040FB', '#7C4DFF', '#536DFE',
    '#448AFF', '#40C4FF', '#18FFFF', '#64FFDA', '#69F0AE',
    '#B2FF59', '#EEFF41', '#FFFF00', '#FFD740', '#FFAB40',
    '#FF6E40', '#FF3D00', '#795548', '#9E9E9E', '#607D8B'
  ];
  
  // 默认标签
  static readonly DEFAULT_TAGS = [
    '工作', '学习', '生活', '购物', '健康',
    '娱乐', '家庭', '朋友', '旅行', '运动',
    '美食', '电影', '读书', '音乐', '游戏',
    '重要', '紧急', '计划', '想法', '提醒'
  ];
  
  // 页面路由
  static readonly ROUTES = {
    INDEX: 'pages/Index',
    MEMO_LIST: 'pages/MemoList',
    MEMO_DETAIL: 'pages/MemoDetail',
    STATS: 'pages/StatsPage'
  };
  
  // 本地存储键名
  static readonly STORAGE_KEYS = {
    MEMOS: 'fun_memo_memos',
    MOOD_RECORDS: 'fun_memo_mood_records',
    ACHIEVEMENTS: 'fun_memo_achievements',
    ENCOURAGEMENTS: 'fun_memo_encouragements',
    SETTINGS: 'fun_memo_settings',
    LAST_ENCOURAGEMENT_DATE: 'fun_memo_last_encouragement_date',
    STREAK_COUNT: 'fun_memo_streak_count',
    LAST_MEMO_DATE: 'fun_memo_last_memo_date'
  };
  
  // 成就类型
  static readonly ACHIEVEMENT_TYPES = {
    MEMO_COUNT: 'memo_count',
    COMPLETED_MEMOS: 'completed_memos',
    HIGH_PRIORITY: 'high_priority',
    TAG_VARIETY: 'tag_variety',
    MOOD_DAYS: 'mood_days',
    MOOD_VARIETY: 'mood_variety',
    MEMO_STREAK: 'memo_streak',
    EARLY_MEMO: 'early_memo'
  };
  
  // 成就稀有度
  static readonly ACHIEVEMENT_RARITIES = {
    COMMON: 'common',
    RARE: 'rare',
    EPIC: 'epic',
    LEGENDARY: 'legendary'
  };
  
  // 成就分类
  static readonly ACHIEVEMENT_CATEGORIES = {
    MEMO: 'memo',
    MOOD: 'mood',
    STREAK: 'streak',
    CHALLENGE: 'challenge'
  };
  
  // 鼓励语分类
  static readonly ENCOURAGEMENT_CATEGORIES = {
    DAILY: 'daily',
    ACHIEVEMENT: 'achievement',
    MOTIVATION: 'motivation',
    FUNNY: 'funny',
    MOOD: 'mood'
  };
  
  // 日期格式
  static readonly DATE_FORMATS = {
    DISPLAY: 'YYYY年MM月DD日',
    DISPLAY_WITH_TIME: 'YYYY年MM月DD日 HH:mm',
    STORAGE: 'YYYY-MM-DD',
    STORAGE_WITH_TIME: 'YYYY-MM-DD HH:mm:ss'
  };
  
  // 页面标题
  static readonly PAGE_TITLES = {
    HOME: '首页',
    MEMO_LIST: '我的备忘录',
    MEMO_DETAIL: '备忘录详情',
    STATS: '统计',
    SETTINGS: '设置'
  };
  
  // 图标
  static readonly ICONS = {
    ADD: '➕',
    EDIT: '✏️',
    DELETE: '🗑️',
    COMPLETE: '✅',
    INCOMPLETE: '⭕',
    BACK: '⬅️',
    SAVE: '💾',
    CANCEL: '❌',
    SEARCH: '🔍',
    FILTER: '⚙️',
    SETTINGS: '⚙️',
    STATS: '📊',
    MOOD: '😊',
    ENCOURAGEMENT: '💬',
    ACHIEVEMENT: '🏆',
    STAR: '⭐',
    HEART: '❤️',
    CHECK: '✓',
    CLOCK: '⏰',
    CALENDAR: '📅',
    TAG: '🏷️',
    PRIORITY: '⚠️',
    SHARE: '📤',
    EXPORT: '📥',
    IMPORT: '📤',
    REFRESH: '🔄',
    INFO: 'ℹ️',
    HELP: '❓',
    ABOUT: 'ℹ️'
  };
  
  // 动画持续时间
  static readonly ANIMATION_DURATIONS = {
    FAST: 150,
    NORMAL: 300,
    SLOW: 500
  };
  
  // 默认设置
  static readonly DEFAULT_SETTINGS = {
    theme: 'light',
    language: 'zh-CN',
    notificationEnabled: true,
    reminderTime: '09:00',
    vibrationEnabled: true,
    soundEnabled: true,
    autoBackup: false,
    backupFrequency: 'daily'
  };
}