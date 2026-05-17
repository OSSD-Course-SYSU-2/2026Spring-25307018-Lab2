/**
 * 颜色常量配置文件
 * 统一管理应用中的所有颜色，确保UI风格一致
 * 
 * 设计规范：
 * - 主色：淡紫 #B8A2F2
 * - 辅助：浅蓝 #82CFFF、暖黄 #FFD98E
 * - 中性：背景 #F8F9FF、卡片白 #FFFFFF、文字深灰 #333344
 */
export class Colors {
  // ==================== 主色调 ====================
  static readonly PRIMARY: string = '#B8A2F2';           // 淡紫 - 主色
  static readonly PRIMARY_LIGHT: string = '#E8E4FA';    // 淡紫浅色
  static readonly PRIMARY_DARK: string = '#9B7FE8';     // 淡紫深色
  
  // ==================== 辅助色 ====================
  static readonly SECONDARY: string = '#82CFFF';        // 浅蓝 - 辅助色1
  static readonly SECONDARY_LIGHT: string = '#E5F6FF';  // 浅蓝浅色
  static readonly ACCENT: string = '#FFD98E';           // 暖黄 - 辅助色2
  static readonly ACCENT_LIGHT: string = '#FFF8E8';     // 暖黄浅色
  
  // ==================== 中性色 ====================
  static readonly BACKGROUND: string = '#F8F9FF';       // 页面背景 - 奶白淡紫灰
  static readonly SURFACE: string = '#FFFFFF';          // 卡片背景 - 纯白
  static readonly SURFACE_VARIANT: string = '#F5F5FA';  // 次级卡片背景
  
  // ==================== 文本色 ====================
  static readonly TEXT_PRIMARY: string = '#333344';     // 主要文字 - 深灰
  static readonly TEXT_SECONDARY: string = '#666677';   // 次要文字
  static readonly TEXT_HINT: string = '#9999AA';        // 提示文字
  static readonly TEXT_ON_PRIMARY: string = '#FFFFFF';  // 主色上的文字
  
  // ==================== 状态色 ====================
  static readonly SUCCESS: string = '#7DD3A8';          // 成功 - 柔和绿
  static readonly WARNING: string = '#FFD98E';          // 警告 - 暖黄
  static readonly ERROR: string = '#FF8B8B';            // 错误 - 柔和红
  static readonly INFO: string = '#82CFFF';             // 信息 - 浅蓝
  
  // ==================== 边框和分割线 ====================
  static readonly BORDER: string = '#E8E8F0';           // 边框
  static readonly DIVIDER: string = '#F0F0F5';          // 分割线
  
  // ==================== 阴影 ====================
  static readonly SHADOW: string = '#00000015';         // 轻阴影 - 8%透明度
  static readonly SHADOW_DARK: string = '#00000025';    // 深阴影 - 15%透明度
  
  // ==================== 心情配色（每个情绪单独颜色）====================
  static readonly MOOD_HAPPY: string = '#FFB86C';       // 😊 开心 - 活力橙
  static readonly MOOD_LAUGH: string = '#FFD98E';       // 😄 大笑 - 暖黄
  static readonly MOOD_LOVE: string = '#FF9EB5';        // 😍 喜爱 - 甜蜜粉
  static readonly MOOD_CELEBRATE: string = '#B8A2F2';   // 🥳 庆祝 - 淡紫
  static readonly MOOD_COOL: string = '#82CFFF';        // 😎 酷 - 浅蓝
  static readonly MOOD_CALM: string = '#A8E6CF';        // 😌 平静 - 薄荷绿
  static readonly MOOD_NEUTRAL: string = '#C4C4D4';     // 😐 一般 - 中性灰
  static readonly MOOD_SAD: string = '#7BA3D8';         // 😔 沮丧 - 忧郁蓝
  static readonly MOOD_CRY: string = '#82CFFF';         // 😢 哭泣 - 浅蓝
  static readonly MOOD_ANGRY: string = '#FF8B8B';       // 😠 生气 - 柔和红
  static readonly MOOD_SLEEPY: string = '#C4A8E8';      // 😴 困倦 - 梦幻紫
  static readonly MOOD_THINK: string = '#A8D8E8';       // 🤔 思考 - 清新蓝
  
  // 心情颜色映射
  static readonly MOOD_COLORS: Record<string, string> = {
    '😊': Colors.MOOD_HAPPY,
    '😄': Colors.MOOD_LAUGH,
    '😍': Colors.MOOD_LOVE,
    '🥳': Colors.MOOD_CELEBRATE,
    '😎': Colors.MOOD_COOL,
    '😌': Colors.MOOD_CALM,
    '😐': Colors.MOOD_NEUTRAL,
    '😔': Colors.MOOD_SAD,
    '😢': Colors.MOOD_CRY,
    '😠': Colors.MOOD_ANGRY,
    '😴': Colors.MOOD_SLEEPY,
    '🤔': Colors.MOOD_THINK
  };
  
  // 心情背景色映射（更柔和）
  static readonly MOOD_BACKGROUNDS: Record<string, string> = {
    '😊': '#FFF5E8',
    '😄': '#FFF8E8',
    '😍': '#FFF0F3',
    '🥳': '#F5F0FF',
    '😎': '#E8F5FF',
    '😌': '#E8FFF5',
    '😐': '#F5F5F8',
    '😔': '#E8F0FA',
    '😢': '#E8F5FF',
    '😠': '#FFF0F0',
    '😴': '#F5E8FF',
    '🤔': '#E8F8FA'
  };
  
  // ==================== 优先级颜色 ====================
  static readonly PRIORITY_LOW: string = '#7DD3A8';     // 低 - 柔和绿
  static readonly PRIORITY_MEDIUM: string = '#FFD98E';  // 中 - 暖黄
  static readonly PRIORITY_HIGH: string = '#FF8B8B';    // 高 - 柔和红
  
  static readonly PRIORITY_COLORS: Record<number, string> = {
    1: Colors.PRIORITY_LOW,
    2: Colors.PRIORITY_MEDIUM,
    3: Colors.PRIORITY_HIGH
  };
  
  // ==================== 图表颜色 ====================
  static readonly CHART_COLORS: string[] = [
    '#B8A2F2',  // 淡紫
    '#82CFFF',  // 浅蓝
    '#FFD98E',  // 暖黄
    '#FF9EB5',  // 粉红
    '#7DD3A8',  // 薄荷绿
    '#FFB86C',  // 橙色
    '#C4A8E8',  // 梦幻紫
    '#A8D8E8'   // 清新蓝
  ];
  
  // ==================== 渐变色 ====================
  static readonly GRADIENT_PRIMARY: [string, string] = ['#B8A2F2', '#9B7FE8'];
  static readonly GRADIENT_SECONDARY: [string, string] = ['#82CFFF', '#5BB8FF'];
  static readonly GRADIENT_ACCENT: [string, string] = ['#FFD98E', '#FFC85C'];
  static readonly GRADIENT_CARD: [string, string] = ['#FFFFFF', '#F8F9FF'];
  static readonly GRADIENT_HEADER: [string, string] = ['#B8A2F2', '#82CFFF'];
}

/**
 * 通用样式常量
 * 统一卡片、圆角、阴影等样式
 */
export class Styles {
  // ==================== 圆角 ====================
  static readonly RADIUS_SM: number = 8;       // 小圆角
  static readonly RADIUS_MD: number = 12;      // 中圆角
  static readonly RADIUS_LG: number = 18;      // 大圆角（主要使用）
  static readonly RADIUS_XL: number = 24;      // 超大圆角
  static readonly RADIUS_FULL: number = 9999;  // 全圆角
  
  // ==================== 间距 ====================
  static readonly PADDING_SM: number = 8;
  static readonly PADDING_MD: number = 16;     // 统一内边距
  static readonly PADDING_LG: number = 24;
  static readonly PADDING_XL: number = 32;
  
  // ==================== 阴影 ====================
  static readonly SHADOW_SM: ShadowOptions = {
    radius: 6,
    color: Colors.SHADOW,
    offsetX: 0,
    offsetY: 2
  };
  
  static readonly SHADOW_MD: ShadowOptions = {
    radius: 12,
    color: Colors.SHADOW,
    offsetX: 0,
    offsetY: 4
  };
  
  static readonly SHADOW_LG: ShadowOptions = {
    radius: 20,
    color: Colors.SHADOW_DARK,
    offsetX: 0,
    offsetY: 8
  };
  
  // ==================== 动画时长 ====================
  static readonly DURATION_FAST: number = 150;
  static readonly DURATION_NORMAL: number = 300;
  static readonly DURATION_SLOW: number = 500;
}

/**
 * 阴影选项接口
 */
interface ShadowOptions {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

/**
 * 图标样式常量
 * 统一图标线条粗细、圆角风格，匹配治愈清新风格
 */
export class IconStyles {
  // ==================== 图标尺寸 ====================
  static readonly SIZE_XS: number = 14;      // 超小图标
  static readonly SIZE_SM: number = 18;      // 小图标
  static readonly SIZE_MD: number = 22;      // 中等图标（主要使用）
  static readonly SIZE_LG: number = 28;      // 大图标
  static readonly SIZE_XL: number = 36;      // 超大图标
  
  // ==================== 图标圆角 ====================
  static readonly RADIUS_SM: number = 10;    // 小圆角图标容器
  static readonly RADIUS_MD: number = 14;    // 中圆角图标容器
  static readonly RADIUS_LG: number = 18;    // 大圆角图标容器
  
  // ==================== 图标容器尺寸 ====================
  static readonly CONTAINER_SM: number = 32;  // 小图标容器
  static readonly CONTAINER_MD: number = 44;  // 中等图标容器
  static readonly CONTAINER_LG: number = 56;  // 大图标容器
  
  // ==================== 心情图标样式 ====================
  static readonly MOOD_SIZE: number = 26;           // 心情表情大小
  static readonly MOOD_CONTAINER: number = 48;      // 心情容器大小
  static readonly MOOD_RADIUS: number = 16;         // 心情容器圆角
  static readonly MOOD_SHADOW_RADIUS: number = 8;   // 心情阴影半径
  
  // ==================== 按钮图标样式 ====================
  static readonly BTN_ICON_SIZE: number = 22;       // 按钮内图标大小
  static readonly BTN_SIZE: number = 52;            // 圆形按钮大小
  static readonly BTN_RADIUS: number = 18;          // 按钮圆角
  
  // ==================== 统一图标字体粗细 ====================
  static readonly WEIGHT_NORMAL: FontWeight = FontWeight.Normal;
  static readonly WEIGHT_MEDIUM: FontWeight = FontWeight.Medium;
}
