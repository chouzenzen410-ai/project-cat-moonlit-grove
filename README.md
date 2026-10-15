# Project CAT: Moonlit Grove / 月影森林

**可运行的 Godot 4.5.2 单机 2D 像素动作垂直切片 · v0.1 · 2026-10-15**

你扮演披着青色围巾的小猫 Miso，守护森林月井，击败侵蚀林地的月蚀鹿灵。本版本是一个有完整首尾的战斗竞技场演示，重点展示动作反馈和可继续开发的代码结构；并非完整商业 RPG。

## 立即试玩

**Windows 免安装包**：完整解压 `ProjectCAT-Windows-Portable.zip`，双击 `StartGame.cmd`。离线可玩，无需安装 Godot、Python、.NET 或下载素材。包内使用未修改的官方 Godot 4.5.2 Windows 引擎运行 PCK；这是便携启动方案，不是经签名的商店发行版。

**源码包**：解压 `ProjectCAT-Source.zip`，用 Godot **4.5.2 标准版**导入 `ProjectCAT/project.godot`，等待首次资源导入，按 **F6/F5** 运行主场景/项目。无需 C# 或插件。其他 4.x 版本尚未验证，建议直接使用 4.5.2。官方免费引擎：https://godotengine.org/download/archive/4.5.2-stable/

窗口初始为 1280×720，逻辑画布 640×360，最近邻像素采样与整数缩放。建议使用键盘；鼠标提供攻击和菜单辅助，不实现鼠标瞄准。

## 操作

| 按键 | 行为 |
| --- | --- |
| Enter | 从标题开始；结算后返回标题 |
| WASD / 方向键 | 八方向移动；移动方向决定爪击方向 |
| J / 鼠标左键 | 爪击；连续按下组成三段连击，第三段更强 |
| Space | 沿移动方向翻滚；静止时沿朝向翻滚 |
| K / 鼠标右键 | 月能满时发动圆形月刃爆发 |
| 1 / 2 / 3 | 战间三选一祝福；也可点击选项 |
| Esc | 暂停 / 继续 |
| R | 暂停或结算时重新开始（回标题） |
| M | 切换音乐和音效静音 |

粉色条为生命，绿色为体力，蓝色为月能。翻滚消耗 32 体力，持续 0.24 秒，提供 0.28 秒无敌。爪击有 0.18 秒输入缓冲，连击窗口 0.65 秒；第三击伤害为基础的 1.8 倍。受伤后短暂无敌，防止弹幕瞬间叠伤。月刃需要 100 月能；命中、拾取和翻滚穿过弹丸均能积累月能。

## 垂直切片验收范围

- 一座可自由走位的月井林地竞技场，有岩石和树干碰撞、纵深排序、像素植被、遗迹、萤火、水纹、月光和轻微前景漂叶。
- 三轮遭遇战，共 15 只普通敌人。每轮结束三选一强化：爪击伤害、生命上限或移速/月能，并回复生命；敌人掉落可吸附的恢复光点。
- 三类敌人：蘑菇史莱姆的近身蓄力扑击、月蛾的保持距离三发弹射、荆棘野猪的直线长距离冲锋。它们有预警、攻击和恢复空隙。
- 最终 Boss「月蚀鹿灵」：环形旋转弹幕、锁定落点冲击、蓄力冲锋。50% 生命触发觉醒，转换期间无敌并清场，第二阶段弹幕更密且落点攻击增加外围区域。
- 三段爪击、打退、轻重命中停顿、镜头震动、闪白、伤害数字、翻滚残影、范围爆发、受伤反馈。
- 标题、HUD、强化选择、暂停、失败、胜利、重新开始、最快通关时间持久化。
- 原创生成的循环背景音乐和五种合成音效。主观音色与混音仍待玩家试听反馈。

目标首玩约 3–8 分钟，**不是已测量的玩家平均时长**。本版没有任务、背包、装备树、对话、地图探索、手柄或联网。升级构成轻量 RPG 成长层。

## 已验证与未验证

已在 Windows / AMD Radeon OpenGL Compatibility / Godot 4.5.2 上执行真实引擎资源导入、脚本加载、窗口渲染和截图检查。25 项交互集成断言全部通过，另有自动战斗遍历三轮与 Boss 并抵达胜利。详细结果见 `verification/VALIDATION.md` 和日志。

自动通关工具会给角色无敌并自动靠近敌人，用于检查流程和错误；**不能证明难度合理、人工无伤通关或实际玩家手感优秀**。正常模式不启用这些功能。

尚未验证：你设备上的表现、长时间游玩稳定性、主观打击感/混音/平衡、其他系统和 Godot 版本。UI 当前使用英文以保证内置字体可直接显示；本说明为中文。没有制作单独 Linux/macOS/Web 导出包。

本机引擎会输出 `Failed to read the root certificate store` 环境诊断，随后使用内置证书；游戏不访问网络。最终集成检查没有 GDScript、资源加载或资源泄漏错误。

## 结构与后续开发

```text
project.godot          项目设置和显式输入映射
scenes/               主场景、玩家、敌人、弹丸的可复用场景
scripts/game.gd       场景组合、波次、成长、结算、存档和摄像机
scripts/player.gd     移动、翻滚、连击、输入缓冲、月刃与受伤
scripts/enemy.gd      三类敌人状态机及双阶段 Boss 调度
scripts/projectile.gd 弹丸运动、伤害与翻滚穿弹奖励
scripts/forest.gd     确定性林地构图和障碍碰撞
scripts/fx.gd         粒子、斩弧、伤害数字和冲击环
scripts/atmosphere.gd 月光、暗角和漂叶
scripts/audio.gd      12 声道池、音乐循环和退出清理
scripts/hud.gd        HUD 与完整菜单
assets/               所有 PNG 精灵图集和 WAV 音频
tests/                可运行的引擎集成测试
tools/                美术/音频资源再生成器（可选开发工具）
verification/         实机截图、测试记录和范围说明
DEVLOG.md             当前完成状态、决策和后续工作切入点
```

无需运行资源生成器即可玩。若要重新生成素材，开发工具需要 Python + Pillow；该工具的随机种子固定。战斗数值在 player/enemy 脚本顶部和状态机内，波次配方在 `game.gd::next_wave()`。可先从修改这些数值开始迭代。

最快通关记录写到 Godot 的 `user://progress.cfg`（Windows 一般位于 `%APPDATA%/Godot/app_userdata/Project CAT- Moonlit Grove/`）。只存通关纪录，不保存进行中的波次。

## 复现验证 / 构建

在项目目录执行（`godot` 替换为本机 Godot 4.5.2 路径）：

```text
godot --headless --editor --import --quit --path .
godot --headless --path . tests/integration.tscn
godot --headless --path . -- --smoke
godot --path . -- --capture
godot --headless --path . --export-pack "Windows Desktop" MoonlitGrove.pck
```

`--capture` 需要图形环境，会运行专用截图序列并写入 `verification/`；`--smoke` 约 45 秒后退出，成功返回 0。两者都是开发验证参数，正常启动不需要。

## 许可

本项目代码、程序化像素素材和合成音频按 `LICENSE` 的 MIT 条款提供；没有使用付费素材、网络下载的图片/音乐或第三方游戏角色。

Godot 引擎是独立第三方依赖，版权与 MIT 许可见 https://godotengine.org/license/ 。便携包附 `GODOT_LICENSES.txt`，包含引擎和第三方组件许可。内置字体由 Godot 提供，随引擎许可记录一起分发。

你负责实际玩法测试即可：优先反馈“哪种攻击来不及读懂、翻滚是否顺手、第三段是否值得打完、Boss 是否拖沓”。我可以据这些结果继续承担主要编程和调参。
