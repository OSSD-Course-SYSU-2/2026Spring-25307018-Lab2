import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { StorageManager } from '../utils/StorageManager';
import { EggManager } from '../utils/EggManager';
import { PlanetManager } from '../utils/PlanetManager';
import { TreasureHuntManager } from '../utils/TreasureHuntManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      
      // 初始化存储管理器
      const storageManager = StorageManager.getInstance();
      await storageManager.init(this.context);
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'StorageManager initialized');
      
      // 【新增】初始化彩蛋管理器
      const eggManager = EggManager.getInstance();
      await eggManager.init();
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'EggManager initialized');
      
      // 【新增】初始化星球管理器
      const planetManager = PlanetManager.getInstance();
      await planetManager.init(this.context);
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'PlanetManager initialized');
      
      // 【新增】初始化寻宝管理器
      const treasureHuntManager = TreasureHuntManager.getInstance();
      await treasureHuntManager.init(this.context);
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'TreasureHuntManager initialized');
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}