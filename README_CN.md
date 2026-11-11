# Taskbar Fluent Media Player Lyrics

[English](README.md) · **简体中文** · [Русский](README_RU.md)

一个用于 Windows 11 的 [Windhawk](https://windhawk.net/) 模组，将 Fluent 风格播放器、同步歌词和音频频谱直接放在任务栏上。本项目基于 [Salyts/Taskbar-Fluent-Media-Player](https://github.com/Salyts/Taskbar-Fluent-Media-Player)，增加真实逐字歌词，以及在每块显示器任务栏上显示完整播放器的能力。

当前源码版本：**`2.0`**。另见[完整功能列表](功能列表与播放器支持.md)与[技术说明](LYRICS.md)。

lyrics7：网易云原生 SMTC 缺少时间轴时，使用只读客户端播放时钟同步歌词。已验证网易云 3.1.41.205564 x64；无法识别或进度失效时隐藏歌词，其他版本可能需要适配。详见 [技术说明](LYRICS.md)。

## 1. 功能

| 类别 | 已实现的功能 |
|---|---|
| 任务栏播放器 | 封面、歌名、歌手、播放/暂停、上一首/下一首、前后跳转 5 秒、随机、循环和媒体会话切换；具体控制能力取决于播放器。 |
| Fluent 外观 | Acrylic、Mica/Mica Alt、封面模糊背景、纯色、渐变、明暗主题颜色，以及字体、图标、圆角、边距和位置设置。 |
| 完整多显示器播放器 | 在每个可用任务栏创建独立、完整的播放器，包括封面、文字、控制按钮、频谱，以及有歌词时的歌词区域；共享播放状态和设置。 |
| 独立歌词区域 | 保留原来的歌名、歌手，在旁边显示当前句与下一句；采用紧凑行距并整体垂直居中。 |
| 按条件显示 | **只有开启开关且当前歌曲已取得歌词时才显示**。获取中、未找到歌词、没有媒体或关闭开关时，隐藏整块区域并释放空间。 |
| 固定歌词布局 | 默认宽度 **260 DIP**，可设为 **80～1200 DIP**。高度和字号按所在任务栏高度及 DPI 调整。取得歌词后，切句、前奏和空白句都不会改变区域大小。 |
| 长句处理 | 当前句在范围内滚动：逐字歌词跟随演唱位置，普通 LRC 自动往返滚动；下一句过长时以省略号显示。 |
| 真实逐字高亮 | QQ QRC、网易云 YRC 和本地增强 LRC 使用真实时间；普通 LRC 仅逐行同步，**不均分、不模拟逐字时间**。高亮可以单独关闭。 |
| 歌词来源 | 本地文件优先，在线支持 QQ 音乐、网易云和 LRCLIB 回退；播放器和歌词来源不必属于同一服务。 |
| 时间同步 | 暂停/拖动定位、按播放速率外推、全局及各播放源 **±10000 毫秒**偏移，以及 Apple Music 整秒时间轴平滑。正值提前，负值延后。 |
| 播放源选择 | 独立开关、可调优先级、跳过禁用来源的手动切换，以及定期重新检查；自动模式优先正在播放的会话，默认浏览器最后。 |
| 匹配与获取 | 服务歌曲 ID 提示、多歌手匹配、切歌结果校验、最多 **64** 首成功结果的内存缓存，以及失败后每 **30 秒**重试。 |
| 原有操作 | 可配置鼠标动作、右键菜单、迷你播放器弹窗、歌名/歌手滚动，以及无媒体、全屏、空闲时自动隐藏。 |
| 音频频谱 | WASAPI 回环采集与 FFT，5 种形态、5 种颜色模式、6 种 EQ 预设，以及尺寸、位置、灵敏度设置。 |

## 2. 多显示器设置

先在 Windows 中启用需要显示播放器的各屏幕任务栏，再在 **Main Settings（主设置）** 中配置：

| 选项 | 行为 |
|---|---|
| 所有显示器显示完整相同样式播放器（`mirrorAllMonitors`） | 默认开启。在发现的每个任务栏上创建完整播放器，并非只复制歌词。 |
| Monitor（`monitor`） | 选择主实例所在屏幕；关闭多屏镜像时，选择单个播放器所在屏幕。编号可能与 Windows 显示设置不同。 |
| 副屏缺少定位锚点时（`mirrorMissingAnchor`） | 当指定的小组件等按钮不存在时，可定位到开始按钮旁并预留空间，或使用不预留空间的左边缘覆盖模式。明确选择的边缘位置仍按边缘方式处理。 |
| 副屏播放器水平偏移（`mirrorSecondaryOffsetX`） | 只调整副屏实例：正值向右，负值向左。 |

模组会定期发现副屏任务栏。各实例拥有独立的界面和渲染生命周期，共享媒体状态与设置；歌词按各自任务栏高度和 DPI 布局。**Mirror layout（镜像布局）**只是反转元素顺序，与多显示器镜像是两个不同选项。

## 3. 安装与更新

需要 **Windows 11**、Windhawk，以及此模组针对的标准任务栏实现。尚未验证 Windows 10、替代任务栏及所有 Windows 构建版本。

1. 安装 [Windhawk](https://windhawk.net/)。
2. 打开本仓库的 [`taskbar-fluent-media-player.wh.cpp`](taskbar-fluent-media-player.wh.cpp)，复制 **Raw 页面中的完整源码**。
3. 在 Windhawk 中新建本地模组，用此源码替换编辑器内容，保存/编译并启用。更新已有本地版本时，替换其源码并重新编译即可。
4. 同一时间只启用一个版本的此任务栏播放器。禁用上游商店版本或其他本地副本，避免重复挂钩任务栏。
5. 打开模组设置，调整位置和多屏选项，再播放音乐；开启“显示独立歌词区域”和在线获取，或配置本地歌词目录。

2.0 版使用独立的 Windhawk 模组 ID `taskbar-fluent-media-player-lyrics`。如果用过早期本地版，请复制或重新设置原配置，并在启用 2.0 前禁用旧版。

## 4. 歌词与播放源设置

### Main Settings → Text Area（文字区域）

| 设置 | 用途 |
|---|---|
| 显示独立歌词区域 | 总开关；同时要求当前歌曲已取得歌词。 |
| 歌词区域长度 | 默认 **260 DIP**，范围 **80～1200 DIP**。Windows 缩放为 150% 时，260 DIP 约为 390 个物理像素；高度无需手动设置。 |
| 逐字高亮（仅真实逐字时间） | 按真实时间高亮；关闭后保留逐行同步。 |
| 从 QQ 音乐、网易云及 LRCLIB 在线获取歌词 | 在线获取开关。 |
| 本地 UTF-8 LRC 歌词目录 | 也支持明文 QRC、YRC；只查找指定目录，不递归扫描。 |
| 歌词时间偏移 | 全局同步校准，与所选播放源偏移相加。 |

本地文件命名：`歌手 - 歌名.lrc`、`歌名 - 歌手.lrc` 或 `歌名.lrc`；`.qrc`、`.yrc` 使用同样规则。Windows 文件名中的非法字符替换为下划线。增强 LRC 必须有真实行内时间，例如：`[00:01.00]<00:01.00>你<00:01.40>好<00:02.00>`。没有结束标签的尾词不会被推测时长。

### Main Settings → Media Sources（播放源）

每个来源都有独立开关和偏移。自动模式先选择正在播放的会话，再比较优先级；保留手动选择。默认优先级从高到低为：

```text
qq,netease,kugou,spotify,apple,soda,foobar,other,browser
```

获取顺序：**本地文件优先**；网易云播放器使用 **网易云 → QQ 音乐 → LRCLIB**；其他来源使用 **QQ 音乐 → 网易云 → LRCLIB**。有真实逐字时间则高亮，只有逐行时间则逐行显示。全部来源都未找到时，隐藏整块歌词区域。

## 5. 播放器兼容性

模组通过 **Windows SMTC** 读取歌曲信息和进度。识别到软件名称，不代表可以补出软件没有提供的时间轴。

| 播放器 | 已接入的能力与使用条件 | 验证情况 |
|---|---|---|
| QQ 音乐 | 独立设置、QRC/LRC、数字歌曲 ID 提示。 | 已实测 Windows 客户端和歌词获取。 |
| 网易云音乐 | 独立设置、`NCM-数字ID` 直取、YRC/LRC。时间轴不完整时可能需要 [inflink-rs](https://github.com/apoint123/inflink-rs)，其客户端版本限制见项目说明。 | 已实测歌词搜索/ID 直取；不代表每个客户端版本都经过端到端实测。 |
| 酷狗 / MoeKoeMusic | 独立设置、跨源歌词；原生酷狗时间轴不完整时无法可靠同步。[MoeKoeMusic](https://github.com/MoeKoeMusic/MoeKoeMusic) 归入此来源。 | 本轮未实测各客户端版本。 |
| Spotify | 独立设置、SMTC 歌曲信息/时间轴、跨源歌词；不读取 Spotify 账号。 | 来源识别已做离线测试，客户端未实测。 |
| Apple Music / iTunes | 独立设置、整秒时间轴平滑、跨源歌词；需要客户端或配置实际提供 SMTC。 | 时间轴逻辑已做离线测试，客户端未实测。 |
| 汽水音乐 | 识别 SodaMusic、`com.soda.music` 和中文来源标识；需要可用 SMTC 数据。 | 来源识别已做离线测试，客户端未实测。 |
| foobar2000 | 需要 [foo_mediacontrol](https://github.com/ungive/foo_mediacontrol) 等组件上报歌曲和进度。 | 来源识别已做离线测试，客户端未实测。 |
| 浏览器 | Edge、Chrome、Firefox 等已识别浏览器；网页须提供可用歌名、歌手与进度，普通视频标题不保证匹配歌词。 | 已验证 Edge 媒体会话读取。 |
| 其他 SMTC 播放器 | 通用来源设置；取决于歌曲信息和时间轴上报是否可用。 | 不保证所有软件均兼容。 |

**不会自动安装第三方插件。** 是否有歌词和真实逐字时间，取决于具体歌曲和歌词来源，而不是仅取决于播放器名称。

## 6. 限制与排查

- **没有歌词区域：**检查总开关、播放源开关、歌曲信息、在线获取/本地文件及服务可用性。获取中或未找到歌词时隐藏区域是预期行为。
- **歌词不推进：**检查播放器是否提供可用时间轴；必要时配置配套插件。时间偏移无法修复缺失的时间轴。
- **匹配错误或时间偏差：**匹配会检查歌名、歌手集合及可用时长，但无法保证每种录音版本。可使用本地歌词；固定时间差可用全局/播放源偏移校准。
- **另一块屏幕没有播放器：**启用该屏幕的 Windows 任务栏及完整多屏镜像，检查缺少锚点时的回退方式和副屏偏移。
- **播放器重复或重叠：**禁用重复模组，检查位置、宽度和回退选项。

尚未实现：酷狗歌词源、KRC、音频内嵌歌词、翻译开关、磁盘缓存、保存逐曲偏移及歌词切句动画。**酷狗播放器接入与酷狗歌词源是不同功能。**

## 7. 网络与隐私

在线获取会向 QQ 音乐、网易云和/或 LRCLIB 发送歌曲信息或可用的服务歌曲 ID。不读取播放器账号或用户登录 Cookie。关闭在线获取后可以只使用本地文件。成功歌词仅在内存缓存，不写入磁盘；模组卸载时缓存丢失。

## 8. 源码与验证

- [`taskbar-fluent-media-player.wh.cpp`](taskbar-fluent-media-player.wh.cpp)：自包含 Windhawk 源码，内嵌 QRC 解码和有大小限制的 DEFLATE 解压；模组运行不需要外部 Node.js 或 .NET。
- [中文功能列表](功能列表与播放器支持.md)、[英文功能列表](Features-and-Player-Support.md)与[技术说明](LYRICS.md)。
- [`tests/lyrics-parser-tests.ps1`](tests/lyrics-parser-tests.ps1)：提取生产实现，测试歌词格式、加密、真实逐字时间、来源识别、优先级和 Apple 时间轴。需要在 Windows 上使用 Windhawk 自带编译器运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\lyrics-parser-tests.ps1
```

当前实现已通过源码/设置校验、编译及离线测试。QQ 实测取得过 48 行/309 个真实逐字片段；网易云搜索样本返回 98 行/579 个片段，ID 直取也已成功。这些结果不代表所有播放器版本均可用。本次仓库更新不包含开发机器专用安装脚本或生成的二进制文件。

## 9. 致谢与许可

- 上游播放器：[Salyts](https://github.com/Salyts/Taskbar-Fluent-Media-Player)；原始频谱工作来自 [GR0UD](https://github.com/GR0UD)，上游贡献者包括 [Eliasilyz](https://github.com/Eliasilyz)、[SpacEagle17](https://github.com/SpacEagle17)。
- Fork 维护、歌词及多屏增强：[momoca](https://github.com/momoca)。
- 歌词架构与 QQ 协议参考：[ANYNC/TaskbarLyrics](https://github.com/ANYNC/TaskbarLyrics)；QRC 密码实现保留 MIT 许可声明。
- 网易云协议/格式参考：[Lyricify Lyrics Helper](https://github.com/WXRIW/Lyricify-Lyrics-Helper)。
- 内嵌 DEFLATE 实现：[Mark Adler 的 puff](https://github.com/madler/zlib/tree/master/contrib/puff)，源码保留其许可。

保留上游 [MIT LICENSE](LICENSE)，内嵌第三方许可仍位于源码中。本 fork 的问题请提交到[本仓库 Issues](https://github.com/momoca/Taskbar-Fluent-Media-Player-Lyrics/issues)。
