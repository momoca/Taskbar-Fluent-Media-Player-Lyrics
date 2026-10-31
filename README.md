# Taskbar Fluent Media Player Lyrics

**English** · [简体中文](README_CN.md) · [Русский](README_RU.md)

A Windows 11 [Windhawk](https://windhawk.net/) mod that places a Fluent-style media player, synchronized lyrics, and an audio visualizer directly on the taskbar. This fork extends [Salyts/Taskbar-Fluent-Media-Player](https://github.com/Salyts/Taskbar-Fluent-Media-Player) with genuine word-timed lyrics and a complete player on every monitor’s taskbar.

Current source version: **`1.6.0-full-mirror-v3-lyrics6`**. See the [complete feature list](Features-and-Player-Support.md) and [technical notes](LYRICS.md).

## 1. Features

| Area | What is included |
|---|---|
| Taskbar player | Album art, title, artist, play/pause, previous/next, ±5-second seeking, shuffle, repeat, and media-session switching; controls depend on the selected player. |
| Fluent appearance | Acrylic, Mica/Mica Alt, album-art blur, solid colors, gradients, light/dark colors, configurable fonts, icons, corners, margins, and placement. |
| Full multi-monitor player | A separate, fully styled player on each available taskbar, including album art, text, controls, visualization, and the lyrics area when lyrics are available. Playback and settings are shared. |
| Separate lyrics area | Current and next lines beside the original title/artist; compact spacing and vertical centering. |
| Conditional visibility | Visible **only when enabled and lyrics have been retrieved for the current track**. Fetching, no lyrics, no media, or a disabled switch hides the entire area and releases its space. |
| Stable lyrics layout | Width defaults to **260 DIP**, adjustable from **80–1200 DIP**. Height and font size follow the local taskbar height and DPI. Once lyrics are available, line changes, intros, and blank lines do not resize the area. |
| Long-line handling | Current lyrics scroll within their bounds. Word-timed lyrics follow the singing position; ordinary LRC scrolls back and forth. Long next-line previews use an ellipsis. |
| Genuine word highlighting | QQ QRC, NetEase YRC, and local enhanced LRC use real timing. Ordinary LRC stays line-synchronized: **no estimated or evenly distributed word timing**. Highlighting has its own switch. |
| Lyrics providers | Local files first; QQ Music, NetEase, and LRCLIB online fallback. Player and lyrics provider do not have to be the same service. |
| Synchronization | Pause/seek handling, playback-rate extrapolation, global and per-source offsets of **±10,000 ms**, and Apple Music whole-second timeline smoothing. Positive offsets advance lyrics; negative offsets delay them. |
| Source selection | Independent source switches, configurable priority, manual switching that skips disabled sources, and a periodic selection check. Playing sessions take precedence; browsers are last by default. |
| Matching and retrieval | Service track-ID hints, multi-artist matching, track-change validation, a bounded in-memory cache of **64** successful results, and retries every **30 seconds** after failed retrieval. |
| Existing controls | Customizable mouse actions, context menus, a mini-player popup, title/artist scrolling, and configurable no-media/fullscreen/idle hiding. |
| Audio visualizer | WASAPI loopback + FFT, five shapes, five color modes, six EQ presets, and size/position/sensitivity controls. |

## 2. Multi-monitor setup

Enable Windows taskbars on the displays where you want a player, then use these options under **Main Settings**:

| Option | Behavior |
|---|---|
| Show identical full player on all monitors (`mirrorAllMonitors`) | Enabled by default. Creates a complete player on each discovered taskbar, not just a copy of the lyrics. |
| Monitor (`monitor`) | Selects the primary instance. With multi-monitor mirroring disabled, selects the display for the single player. Numbering may differ from Windows Display Settings. |
| Secondary taskbar missing anchor fallback (`mirrorMissingAnchor`) | If the requested Widgets or other anchor is absent, use a Start-adjacent position that reserves space, or a left-edge overlay that does not. Explicit edge placements keep their edge behavior. |
| Secondary player horizontal offset (`mirrorSecondaryOffsetX`) | Adjusts secondary instances only: positive moves right, negative moves left. |

Secondary taskbars are rediscovered periodically. Each instance has its own UI and rendering lifecycle while sharing media state and settings. Lyrics use each taskbar’s height and DPI. **Mirror layout** reverses element order; it is a different option from mirroring across monitors.

## 3. Installation and updates

Requires **Windows 11**, Windhawk, and the standard taskbar implementation targeted by the mod. Windows 10, replacement taskbars, and every Windows build have not been validated.

1. Install [Windhawk](https://windhawk.net/).
2. Open this repository’s [`taskbar-fluent-media-player.wh.cpp`](taskbar-fluent-media-player.wh.cpp) and copy the **complete raw source**.
3. In Windhawk, create a new local mod, replace its editor contents with this source, then save/compile and enable it. To update an existing local copy, replace its source and compile again.
4. Keep only one version of this taskbar player enabled. Disable the upstream/gallery version or another local copy to avoid duplicate taskbar hooks.
5. Open the mod settings, configure placement and monitors, then play music. Enable **Show separate lyrics area** and online retrieval, or choose a local lyrics directory.

**The upstream Windhawk gallery entry installs the upstream mod, not this fork.** Use the source in this repository for these lyrics and full multi-monitor additions. The source retains the original mod ID for compatibility; the displayed name and documentation identify this fork.

## 4. Lyrics and media-source settings

### Main Settings → Text Area

| Setting | Purpose |
|---|---|
| Show separate lyrics area | Master switch; the area also requires lyrics for the current track. |
| Lyrics area width | Default **260 DIP**; range **80–1200 DIP**. At 150% Windows scaling, 260 DIP is approximately 390 physical pixels. No manual height setting is needed. |
| Highlight real word timing | Enable genuine word-timing highlighting; disabling it preserves line-synchronized lyrics. |
| Fetch lyrics from QQ Music, Netease and LRCLIB | Online retrieval switch. |
| Local UTF-8 LRC folder | Also accepts plain-text QRC and YRC. Searches the specified directory only, without recursive scanning. |
| Lyrics offset | Global synchronization adjustment, added to the selected source’s offset. |

Local filenames: `Artist - Title.lrc`, `Title - Artist.lrc`, or `Title.lrc`; use the same patterns for `.qrc` and `.yrc`. Unsupported Windows filename characters are replaced with underscores. Enhanced LRC needs real inline timestamps, for example: `[00:01.00]<00:01.00>Hello <00:01.40>world<00:02.00>`. A final token without an end timestamp does not receive an invented duration.

### Main Settings → Media Sources

Each source has its own enable switch and offset. Automatic selection favors playing sessions, then the configured priority; manual selection is retained. The default priority, highest first, is:

```text
qq,netease,kugou,spotify,apple,soda,foobar,other,browser
```

Retrieval order: **local files first**; for NetEase playback, **NetEase → QQ Music → LRCLIB**; for other sources, **QQ Music → NetEase → LRCLIB**. Real word timing is used when available; line-only lyrics remain line-only. If all lookups fail, the whole lyrics area is hidden.

## 5. Player compatibility

The mod reads **Windows SMTC** track metadata and playback progress. Recognizing an application does not supply a timeline that the application fails to publish.

| Player | Integration and requirements | Validation |
|---|---|---|
| QQ Music | Dedicated configuration; QRC/LRC and numeric track-ID hints. | Windows client and lyrics tested. |
| NetEase Cloud Music | Dedicated configuration; `NCM-<numeric ID>` direct retrieval and YRC/LRC. Incomplete client timelines may require [inflink-rs](https://github.com/apoint123/inflink-rs); check its supported client versions. | Lyrics search/direct retrieval tested; not an end-to-end test of every client version. |
| KuGou / MoeKoeMusic | Dedicated configuration and cross-provider lyrics. Native KuGou’s incomplete timelines can prevent reliable synchronization; [MoeKoeMusic](https://github.com/MoeKoeMusic/MoeKoeMusic) is recognized under this source. | Client versions not tested in this round. |
| Spotify | Dedicated configuration; SMTC metadata/timeline and cross-provider lyrics. No Spotify account access. | Recognition tested offline; client not tested. |
| Apple Music / iTunes | Dedicated configuration, whole-second timeline smoothing, cross-provider lyrics. Requires a client/configuration that exposes SMTC. | Timeline logic tested offline; clients not tested. |
| Soda Music / Qishui Music | Recognizes SodaMusic, `com.soda.music`, and Chinese source identifiers. Requires usable SMTC data. | Recognition tested offline; client not tested. |
| foobar2000 | Requires a component such as [foo_mediacontrol](https://github.com/ungive/foo_mediacontrol) to publish track information and progress. | Recognition tested offline; client not tested. |
| Browsers | Edge, Chrome, Firefox, and other recognized browsers. Websites must supply usable track titles, artists, and progress. Ordinary video titles may not match lyrics. | Edge media-session reading verified. |
| Other SMTC players | Generic source configuration; depends on usable metadata and timeline reporting. | No blanket compatibility guarantee. |

Third-party plugins are **not installed automatically**. Lyrics availability and genuine word timing depend on the track and provider, not just the player name.

## 6. Limitations and troubleshooting

- **No lyrics area:** check its switch, source enablement, track metadata, online retrieval/local files, and provider availability. Hiding the area while fetching or after a miss is intentional.
- **Lyrics do not advance:** check whether the player publishes a usable timeline; configure the companion plugin where required. Offsets cannot repair a missing timeline.
- **Wrong or shifted lyrics:** matching checks titles, artist sets, and usable durations but cannot guarantee every recording. Try local lyrics; use global/per-source offsets for timing differences.
- **No player on another monitor:** enable that display’s Windows taskbar, enable full-player mirroring, and check the missing-anchor fallback and secondary offset.
- **Multiple players or overlap:** disable duplicate copies of this mod and review placement, width, and fallback options.

Not implemented: KuGou’s own lyrics provider, KRC, embedded audio-file lyrics, a translation toggle, disk caching, saved per-track offsets, or lyric transition animations. **KuGou player support and a KuGou lyrics provider are different features.**

## 7. Network use and privacy

Online lookup sends track metadata or available service track IDs to QQ Music, NetEase, and/or LRCLIB. No player account or user login cookie is read. Turn off online retrieval to use local files only. Successful lyrics are cached in memory, not on disk; caches are lost when the mod unloads.

## 8. Source layout and validation

- [`taskbar-fluent-media-player.wh.cpp`](taskbar-fluent-media-player.wh.cpp): self-contained Windhawk source, including QRC decoding and bounded DEFLATE decompression. No external Node.js or .NET runtime is required by the mod.
- [English feature list](Features-and-Player-Support.md), [Chinese feature list](功能列表与播放器支持.md), and [technical notes](LYRICS.md).
- [`tests/lyrics-parser-tests.ps1`](tests/lyrics-parser-tests.ps1): extracts the production implementation and tests formats, cryptography, genuine word timing, source identities, priority, and Apple timeline behavior. Run on Windows with Windhawk’s bundled compiler available:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\lyrics-parser-tests.ps1
```

The current implementation passed source/settings validation, compilation, and offline tests. QQ testing retrieved 48 lines/309 real word-timed segments; a NetEase search sample returned 98 lines/579 segments, and direct ID retrieval succeeded. These results do not establish that every player version works. Development-machine installation scripts and generated binaries are not part of this repository update.

## 9. Credits and license

- Upstream player: [Salyts](https://github.com/Salyts/Taskbar-Fluent-Media-Player); original visualization work by [GR0UD](https://github.com/GR0UD), with upstream contributors including [Eliasilyz](https://github.com/Eliasilyz) and [SpacEagle17](https://github.com/SpacEagle17).
- Fork maintenance and lyrics/multi-monitor additions: [momoca](https://github.com/momoca).
- Lyrics architecture and QQ protocol reference: [ANYNC/TaskbarLyrics](https://github.com/ANYNC/TaskbarLyrics). QRC cipher code retains its MIT notice.
- NetEase protocol/format reference: [Lyricify Lyrics Helper](https://github.com/WXRIW/Lyricify-Lyrics-Helper).
- Embedded DEFLATE implementation: [Mark Adler’s puff](https://github.com/madler/zlib/tree/master/contrib/puff), with its license retained in the source.

The upstream [MIT LICENSE](LICENSE) is preserved; embedded third-party notices remain in the source. Report fork-specific problems in [this repository’s issues](https://github.com/momoca/Taskbar-Fluent-Media-Player-Lyrics/issues).
