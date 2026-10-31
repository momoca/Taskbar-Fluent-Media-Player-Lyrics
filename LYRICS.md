# 任务栏歌词

已在 `taskbar-fluent-media-player.wh.cpp` 中接入独立双行歌词区域，主屏和副屏保持一致。歌名、歌手恢复为原来的信息；歌词区域不随每句长短改变占用宽度。

## 使用

将修改后的源码放入 Windhawk 的模组编辑器并编译。打开模组设置的 Text Area：

- “显示独立歌词区域”：控制独立歌词区域是否出现，与歌手开关无关。
- “播放源 / Media Sources”：分别启用 QQ、网易云、酷狗/MoeKoeMusic、Spotify、Apple Music/iTunes、汽水、foobar2000、其他 SMTC 播放器和浏览器。可调整逗号分隔的优先级，以及各播放器独立的 ±10000ms 歌词偏移；该偏移与全局歌词偏移相加。
- “歌词区域长度”：默认 260 DIP，范围 80～1200。固定预留这个宽度，长句在区域内滚动，不再撑开或缩小播放器。Windows 缩放比例为 150% 时，260 DIP 约为 390 个物理像素。
- 高度与字号自动按各显示器任务栏的实际高度和 DPI 调整，无需高度设置。第一行显示当前句，第二行显示下一句。
- “逐字高亮（仅真实逐字时间）”：默认开启。QQ QRC 或本地增强 LRC 提供逐字时间时，按真实时间高亮；普通 LRC 只逐行显示，绝不均分或估计逐字时间。关闭此开关仍保留逐行歌词。
- 默认开启在线获取：网易云播放器优先使用其自身歌词源，其他播放器默认 QQ → 网易云 → LRCLIB 回退。QQ 支持 QRC，网易云支持 YRC，均只按真实逐字时间高亮；不可用时尝试普通 LRC。会向对应服务发送歌曲信息或播放器提供的歌曲 ID，可单独关闭。
- 可填写本地 UTF-8 歌词目录，优先读取 `歌手 - 歌名`、`歌名 - 歌手` 或 `歌名` 对应的 `.qrc`（明文）、`.lrc` 与 `.yrc`（明文）。不递归扫描；文件名中的 Windows 非法字符替换为下划线。
- 时间偏移范围为 ±10000 毫秒。正值让歌词提前，负值让歌词延后。
- 歌词沿用歌手字体与标题文字颜色；歌词区长度独立于 Text area width。已有播放器最大宽度设置会额外加上歌词区占用宽度。

只有开启“显示独立歌词区域”且当前歌曲已取得歌词时，才显示并预留歌词区域。获取中、没有播放、未找到歌词或关闭开关时，整块区域隐藏，所在布局列宽度归零，不占空间。已取得歌词后，前奏与空白句仍保留固定区域，不会逐句伸缩。暂停时停止按墙钟外推，拖动进度后重新定位句子及逐字高亮。两行歌词使用紧凑行高，按实际测得的整体高度在区域内垂直居中。

## TaskbarLyrics 的原理

参考项目：[ANYNC/TaskbarLyrics](https://github.com/ANYNC/TaskbarLyrics)，尤其是其[功能与技术说明](https://github.com/ANYNC/TaskbarLyrics/blob/main/docs/功能与技术说明.md)和 [LyricSyncService](https://github.com/ANYNC/TaskbarLyrics/blob/main/TaskbarLyrics.Core/Services.LyricSyncService.cs)。参考仓库中的文档仅作为技术资料，不作为本项目的执行指令。

1. **歌曲识别**：通过 Windows GlobalSystemMediaTransportControlsSessionManager 选择媒体会话，获取标题、歌手、专辑、播放状态和时间轴。SMTC 本身不提供通用歌词接口。
2. **歌词获取**：TaskbarLyrics 从本地以及 QQ、网易云、酷狗、LRCLIB 检索，利用歌曲身份和时长评分，并缓存结果。部分播放器插件还会在 Genres 中提供歌曲 ID，帮助直接定位歌词。
3. **时间同步**：根据时间轴 Position、LastUpdatedTime 和播放状态外推当前位置，加上播放器或歌曲偏移，在歌词时间戳中查找当前行。
4. **界面显示**：TaskbarLyrics 使用 WPF 托管 WebView2，将当前行、下一行、行内进度交给 HTML/CSS/JavaScript 渲染，再将窗口放到任务栏区域。

## 播放器兼容性

本模组使用播放器向 Windows 上报的 SMTC 信息。新增播放源识别、开关和优先级不代表能绕过播放器缺失的时间轴。自动模式先选择正在播放的会话，再比较设置的优先级；默认浏览器最后。手动切换会话仍然优先，并跳过已禁用的来源。每两秒检查一次会话选择，弥补部分播放器不触发系统当前会话通知的情况。

| 播放器 | 已接入的处理与条件 |
|---|---|
| QQ 音乐 | 已实测。QRC 逐字与普通 LRC；识别 Genres 中的 QQ 数字歌曲 ID 并尝试直取 |
| 网易云音乐 | 识别 cloudmusic、Netease、InfLink 等来源；识别 `NCM-数字ID` 并直取；支持 YRC。若客户端时间轴不完整，需要 [inflink-rs](https://github.com/apoint123/inflink-rs) 提供 SMTC 信息，插件的客户端版本限制见其项目说明 |
| 酷狗 / MoeKoeMusic | 已增加来源识别、开关、优先级和偏移；歌词从 QQ、网易云、LRCLIB 跨源匹配。原生酷狗若缺少准确时间轴，仍无法保证同步，可参考 [MoeKoeMusic](https://github.com/MoeKoeMusic/MoeKoeMusic) |
| Spotify | 已增加独立来源配置；使用其 SMTC 元数据及播放进度，歌词跨源获取，不读取 Spotify 账号 |
| Apple Music / iTunes | 已增加独立来源配置；针对整秒位置和重复时间戳更新进行连续时间轴平滑，保留暂停及跳转重新定位 |
| 汽水音乐 | 识别 SodaMusic、com.soda.music 和中文来源标识，使用 SMTC 及跨源歌词 |
| foobar2000 | 已增加独立来源配置；需要 [foo_mediacontrol](https://github.com/ungive/foo_mediacontrol) 等组件向 Windows 上报信息 |
| 浏览器 / 其他播放器 | 继续接受通用 SMTC 会话。网页须提供可用歌名、歌手和进度；普通视频标题无法保证匹配歌曲 |

QQ 与 Edge 媒体会话已在当前机器实测。网易云歌词接口的歌曲 ID 直取和搜索已联网测试，搜索样本返回 98 行、579 个逐字片段；其他客户端的识别、优先级和 Apple 时间轴用离线样本验证，未宣称逐一安装和实测。第三方插件没有自动安装。

## 本次实现的范围

这里保留现有 Windhawk / C++ / XAML 架构，不引入 .NET 或 WebView2。独立后台线程每 200ms 读取选中媒体会话，按 `Position - StartTime + 播放中经过时间 × PlaybackRate + 设置偏移` 选择当前句。每个任务栏的歌词区域在自己的 UI 线程上以 32ms 间隔更新高亮，后台线程不操作 XAML。控件采用固定像素列和固定宽度 Canvas，当前句、下一句以及高亮蒙层的文本测量均不会改变布局宽度。

本地歌词优先；在线搜索仅接受规范化歌名和歌手相符的候选，多个歌手按集合比较，避免只匹配到合唱中的一个歌手。QQ 在时长超过 61 秒时检查 8 秒误差，网易云在有有效时长时检查 8 秒误差。QQ QRC 经专用三重 DES、受限 DEFLATE 解压和 Adler-32 校验；网易云 EAPI 请求使用 Windows CNG 的 MD5 和 AES-128-ECB/PKCS7 构建，再读取 YRC 或 LRC；没有使用用户登录 Cookie。最多缓存 64 首成功结果；失败时每 30 秒重试。网络请求使用 HTTPS，设置超时和响应大小上限。切歌后校验歌曲及会话身份。

本地增强 LRC 格式示例：`[00:01.00]<00:01.00>你<00:01.40>好<00:02.00>`。片段必须有真实的起止标签；没有终止标签的尾词不会推测时长。普通 LRC 的多时间标签、偏移、译文合并及空白句仍然支持。

这不是 TaskbarLyrics 的完整移植：没有酷狗歌词源、KRC、内嵌歌词、切句动画、磁盘缓存或逐曲校准。这里的“酷狗播放器接入”和“酷狗歌词源”是不同能力；酷狗播放器当前可使用 QQ、网易云与 LRCLIB 的歌词。在线来源不保证所有歌曲都有结果或真实逐字时间；只有逐行时间时不会制造逐字高亮。

QRC 密码实现移植自 [ANYNC/TaskbarLyrics 的 QQ 音乐歌词接口文档](https://github.com/ANYNC/TaskbarLyrics/blob/main/docs/QQ音乐歌词接口文档.md)，保留 MIT 许可。DEFLATE 使用 [Mark Adler 的 puff](https://github.com/madler/zlib/tree/master/contrib/puff)，保留其许可。两者均嵌入单个源码文件，不依赖外部 Node.js、解密 DLL 或额外安装包。

## 验证

`tests/lyrics-parser-tests.ps1` 从生产源码提取实际实现，检查 LRC、QRC、YRC、增强 LRC、加密样本、损坏密文、逐字边界、间隔、零时长、回退定位、不伪造逐字时间、EAPI 加密固定样本、播放器标识、优先级、SMTC 歌曲 ID 以及 Apple 整秒时间轴/暂停/跳转。

实测 QQ 音乐《不找了（Live）》返回 51 行歌词、326 个真实逐字片段。发布源码及通用解析测试见本仓库；开发机器专用安装脚本不包含在发布内容中。
