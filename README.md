趣味备忘录
 
📝 项目简介
 
本项目是基于HarmonyOS ArkTS开发的全功能趣味备忘录应用，融合笔记记录、心情管理、数据可视化统计、AI智能助手、记忆寻宝趣味玩法于一体，兼顾实用性与趣味性，既可以满足日常记事、情绪记录需求，又通过游戏化玩法提升使用趣味性，适合日常学习、生活记录与情绪复盘。
 
✨ 核心功能
 
🏠 首页主页
 
- 展示当日日期、天气信息，温馨欢迎界面
- 快速数据统计：总笔记数、已完成数量、今日记录数量
- 快捷心情记录入口，一键记录当下情绪
- 最近笔记预览，快速查看历史记录内容

<img width="160" height="342" alt="image" src="https://github.com/user-attachments/assets/e438bb84-3f4b-49a2-b37f-719687466df8" /><img width="160" height="342" alt="c911656c104782e62d3202384b62ea11" src="https://github.com/user-attachments/assets/1bed0330-77e9-4f75-92a5-a497db0ccf57" />


📓 新建笔记
 
- 支持自定义笔记标题、正文内容，适配多种记录场景
- 多类心情表情标记，可视化记录当日情绪
- 低/中/高三级优先级设置，区分笔记重要程度
- 时间胶囊专属功能，支持笔记定时封存
- 自定义标签分类管理，可自主添加标签，实现笔记精细化整理

<img width="160" height="342" alt="image" src="https://github.com/user-attachments/assets/356c5dc2-caa8-4d26-a6f9-d1a2f03e8400" /><img width="" height="342" alt="image" src="https://github.com/user-attachments/assets/ec6d2e59-f149-4fcb-aed1-57b206b8109f" />

 
📊 统计中心
 
- 数据概览：汇总笔记总量、连续打卡天数、心情记录数据
- 笔记星球：可视化展示笔记完成进度
- 寻宝战绩：统计寻宝次数、寻宝成功率、碎片获取数量
- 情绪可视化图表：生成心情分布柱状图、心情占比分析图，直观复盘情绪变化
- 成就图鉴：解锁打卡、记录类专属成就，激励长期使用
- 盲盒收藏：收集寻宝获得的专属藏品，丰富使用乐趣

<img width="160" height="342" alt="d8e1887c13a594b1beb9d657f01ee8ee" src="https://github.com/user-attachments/assets/5569b516-6ca2-4dc5-8ec3-e81af1785c51" /><img width="160" height="342" alt="image" src="https://github.com/user-attachments/assets/dd143212-aa48-4229-96bf-4cc08dbd040c" /><img width="160" height="342" alt="2a31fe70257fbffa6224ad0d69321efd" src="https://github.com/user-attachments/assets/d6ed0a79-be8b-4cf3-8921-6360e1fdc6ed" /><img width="160" height="342" alt="183363d8835132efbf1c85d75f39c02e" src="https://github.com/user-attachments/assets/116df13c-883a-48a5-97b6-ee66b39fba40" />



🤖 AI助手
 
- AI智能生成：根据提示词自动生成购物清单、学习计划、会议要点等结构化内容
- AI文案润色：优化笔记内容，让行文更通顺规整
- 心情分析：解析历史心情数据，生成情绪趋势并给出个性化建议
- 智能标签推荐：根据笔记内容自动匹配适配标签
- 记忆寻宝：基于历史笔记开启寻宝玩法，获取星球碎片、盲盒抽奖机会

<img width="160" height="342" alt="88e8ca60c2c7976e145001ba38c66518" src="https://github.com/user-attachments/assets/0b99fce7-b962-4bdc-8896-2cf45c8d078e" />

 
🎮 记忆寻宝趣味玩法/笔记星球
 
- 结合个人笔记数据的轻量化互动小游戏
- 寻宝可获取星球碎片、盲盒抽奖机会
- 游戏数据同步至统计中心，形成完整成长体系
- 笔记星球里可根据笔记心情生成不同颜色碎块
- 笔记星球碎片点击即可进入对应笔记

<img width="160" height="342" alt="1a31e32dd9c1b5ae51524a12ba37d8e3" src="https://github.com/user-attachments/assets/92bf5790-dd4d-4707-a21d-2844f93e767a" /><img width="160" height="342" alt="8409df1bb289a213bec0a28220b81d70" src="https://github.com/user-attachments/assets/d02ca912-e3b9-4afa-84da-b88effda3db3" /><img width="160" height="342" alt="image" src="https://github.com/user-attachments/assets/a501e61a-a830-4734-b9a6-5556d5d47033" /><img width="160" height="342" alt="屏幕截图 2026-05-18 233549" src="https://github.com/user-attachments/assets/b80738dc-6ed4-46d1-9ad2-d5796167fc50" />



 
🛠️ 技术栈
 
- 开发框架：HarmonyOS ArkTS
- 开发工具：DevEco Studio
- 本地存储：HarmonyOS Preferences 持久化存储
- UI架构：声明式组件化开发，分层解耦设计
- 数据可视化：原生图表组件实现情绪数据可视化展示
 
📂 项目目录结构
 
├── entry                 # 应用主业务模块

│   └── src/main/ets      # 核心源码目录

│       ├── pages         # 所有功能页面

│       ├── utils         # 工具类、业务管理器

│       ├── model         # 数据实体、接口类型定义

│       └── common        # 公共常量、通用工具方法

├── hvigor                # 项目编译构建配置

├── oh_modules            # 项目依赖依赖包

├── build-profile.json5   # 工程构建配置文件

└── README.md             # 项目说明文档
 
 
🚀 运行教程
 
1. 环境准备：安装DevEco Studio，完成HarmonyOS开发环境配置

2. 克隆本项目到本地

3. 使用DevEco Studio打开项目，等待自动同步依赖

4. 连接鸿蒙模拟器或真机设备

5. 点击运行按钮，编译安装后即可体验全部功能

 
💡 项目亮点
 
1. 功能集成度高，一站式满足记事、情绪管理、数据复盘、AI辅助、休闲互动需求

2. 数据可视化展示，直观清晰查看个人记录与情绪变化

3. 游戏化寻宝设计，打破传统备忘录枯燥感，提升用户粘性

4. AI赋能办公学习，大幅提升笔记整理、内容创作效率

5. 本地数据持久化存储，保障个人笔记数据安全

6. 界面简洁清爽，操作逻辑简单，上手门槛低
 
📌 后续优化方向
 
- 新增云端同步功能，实现多设备数据互通
- 新增语音转文字记录，丰富笔记录入方式
- 拓展更多寻宝玩法与盲盒藏品，完善成就体系
- 支持笔记导出、分享功能，方便内容分享
