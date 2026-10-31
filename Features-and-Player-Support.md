# Taskbar Media Player: New Features and Player Support

Last updated: October 31, 2026  
Version: `1.6.0-full-mirror-v3-lyrics6`  
Source file: `taskbar-fluent-media-player.wh.cpp`

This document summarizes the features added and adjusted in this round of development. Existing album art, playback controls, audio visualization, menus, and multi-monitor mirroring remain available.

## 1. New and Updated Features

| Feature | Current behavior |
|---|---|
| Separate lyrics area | Lyrics appear beside the player without replacing the artist. The original track title and artist information are preserved. |
| Lyrics visibility switch | The lyrics area appears only when the switch is enabled and lyrics have been retrieved for the current track. |
| Automatic hiding when lyrics are unavailable | While fetching, when no lyrics are found, or when no media is available, the entire lyrics area is hidden and its space is released. No “Lyrics not found” message is displayed. |
| Fixed lyrics width | The default width is 260 DIP, adjustable from 80 to 1200 DIP. While visible, the area does not expand or shrink with each lyric line. |
| Automatic height adjustment | The area height and font size adapt to each monitor’s taskbar height and Windows display scaling. |
| Two-line lyrics | The first line shows the current lyric; the second shows the next lyric. |
| Vertical centering | Both lines are centered as a block using their measured height, with tighter line heights and spacing. |
| Scrolling for long lines | The current line scrolls within the configured width. Word-timed lyrics follow the singing position; ordinary line-timed lyrics scroll back and forth automatically. Long next-line previews use an ellipsis. |
| Genuine word-timing highlighting | Uses real timing data from QQ QRC, NetEase YRC, and local enhanced LRC. Ordinary LRC remains line-synchronized; word timing is never estimated or evenly distributed. |
| Independent highlighting switch | Highlighting can be disabled while keeping two-line lyrics and line synchronization. |
| Online lyrics fallback | Integrates QQ Music, NetEase, and LRCLIB, trying another provider when one is unavailable. |
| Local lyrics first | Prioritizes UTF-8 LRC, plain-text QRC, and plain-text YRC files in the configured directory. |
| Pause and seek handling | Playback-position extrapolation stops when paused. Seeking recalculates the current line and word highlight. |
| Global lyrics offset | Adjustable by ±10,000 ms. Positive values advance lyrics; negative values delay them. |
| Per-player offsets | Each media source has an additional ±10,000 ms offset, added to the global offset. |
| Per-source switches | Individual players and browser sources can be enabled or disabled separately. |
| Media-source priority | Automatic selection favors playing sessions, then applies the configured priority. Browsers are last by default. |
| Manual session switching | Existing manual selection is retained, and disabled sources are skipped. |
| Multi-monitor lyrics | Taskbars share the same lyrics state while adapting their layout to their own height and DPI. |
| Apple Music timeline smoothing | Handles whole-second positions and repeated timestamp updates to reduce highlight jumps. |
| Direct retrieval by track ID | Recognizes NetEase `NCM-<numeric ID>` metadata and QQ numeric track IDs, attempting direct QRC retrieval for QQ IDs. |
| Multi-artist matching | Compares artist sets to reduce incorrect matches involving only one artist from a collaboration. |
| Caching and retries | Caches up to 64 successful results in memory. Failed lookups are retried every 30 seconds. |
| Track-change validation | Checks whether the track or media session changed during retrieval, preventing lyrics from the previous track from overwriting the current track. |

Once lyrics have been retrieved, the fixed area remains reserved during the track’s intro and blank lyric lines, avoiding repeated layout changes between lines. Tracks without lyrics do not occupy this area.

## 2. Supported Music Players

The mod reads track information and playback progress through **Windows System Media Transport Controls (SMTC)**. It is not limited to QQ Music. Recognition, enable/disable switches, priority, and timing offsets have been added for the following sources.

| Player | Current integration | Requirements and validation status |
|---|---|---|
| **QQ Music for Windows** | Track recognition, synchronized lyrics, genuine word-timing highlighting, and session switching. | **Tested on the current machine.** Word-timed lyrics depend on the specific track. |
| **NetEase Cloud Music** | Dedicated source recognition, direct track-ID retrieval, YRC word-timed lyrics, and ordinary LRC. | Lyrics search and direct track-ID retrieval have been tested. If the client supplies an incomplete timeline, a companion plugin such as [inflink-rs](https://github.com/apoint123/inflink-rs) is required. Refer to its project documentation for supported client versions. |
| **KuGou Music** | Source recognition, separate configuration, and lyrics matching across providers. | Synchronization cannot be guaranteed if the native client does not supply an accurate timeline. Client versions have not been individually tested in this round. |
| **MoeKoeMusic** | Recognized and configured under the KuGou source, using lyrics from other providers. | Requires usable SMTC information. Not tested in this round. Project: [MoeKoeMusic](https://github.com/MoeKoeMusic/MoeKoeMusic). |
| **Spotify** | Dedicated source configuration; its track information and timeline are used to retrieve lyrics from other providers. | Does not access the Spotify account. The client has not been tested in this round. |
| **Apple Music / iTunes** | Dedicated source configuration, whole-second timeline smoothing, and lyrics from other providers. | Applies only to clients or configurations that actually expose SMTC information to Windows. Timeline handling was validated with offline samples; the clients have not been tested. |
| **Soda Music / Qishui Music** | Recognizes SodaMusic, `com.soda.music`, and Chinese source identifiers; uses lyrics from other providers. | Requires complete SMTC information. The client has not been tested in this round. |
| **foobar2000** | Dedicated source configuration and lyrics from other providers. | Requires a component such as [foo_mediacontrol](https://github.com/ungive/foo_mediacontrol) to publish track information and progress. The client has not been tested in this round. |
| **Edge, Chrome, Firefox, and other browsers** | Browser media-session recognition, with separate priority and enable/disable controls. | **Reading Edge media sessions has been verified.** Websites must provide accurate track titles, artists, and progress. Ordinary video titles are not guaranteed to match lyrics. |
| **Other SMTC players** | Generic integration remains available, with an “Other SMTC players” switch and offset. | Compatibility depends on whether the application provides usable track information and a timeline to Windows. |

**“Integration added” does not mean that every client version has been tested.** This round included code, format-parsing, source-recognition, and timeline tests. Not every player was installed individually, and third-party plugins were not installed automatically. Adding a recognized application name cannot reconstruct information that the player does not provide.

## 3. Players and Lyrics Providers Are Different

The player tells Windows what is playing, whether it is paused, and the current playback position. The lyrics provider supplies the lyric text and timing tags.

Consequently, tracks playing in Spotify, Apple Music, KuGou, or foobar2000 can use lyrics matched from QQ Music, NetEase, or LRCLIB. The player and lyrics provider do not need to be the same service.

The current retrieval order is:

1. Prefer local lyrics in the configured directory.
2. For the NetEase player, try NetEase lyrics first, then fall back to QQ Music and LRCLIB.
3. For other players, the default order is QQ Music → NetEase → LRCLIB.
4. Use word highlighting when genuine word timing is available; use line synchronization when only line timing is available; hide the area if no lyrics are retrieved.

**KuGou’s own lyrics provider has not been integrated.** KRC, lyrics embedded in audio files, a lyrics-translation switch, disk caching, and saved per-track offsets are also not supported. The KuGou player can use the other available lyrics providers.

## 4. Settings Locations

### Main Settings → Text Area

| Setting | Purpose |
|---|---|
| Show separate lyrics area | Master visibility switch. The area appears only when this is enabled and lyrics are available. |
| Lyrics area width | Defaults to 260 DIP; controls only the lyrics area’s width. |
| Highlight real word timing | Controls highlighting based on genuine timing data. |
| Fetch lyrics from QQ Music, Netease and LRCLIB | Enables or disables online retrieval. |
| Local UTF-8 LRC folder | Local lyrics directory; also supports plain-text QRC and YRC. |
| Lyrics offset | Global synchronization adjustment. |

DIP means device-independent pixels, which scale with Windows display settings. At 150% scaling, for example, 260 DIP is approximately 390 physical pixels. Height adjusts automatically and does not require a manual setting.

### Main Settings → Media Sources

- Enable or disable each player source separately.
- Set an independent lyrics offset for each source.
- Change the priority used for automatic selection. Priority decreases from left to right. The default is:

```text
qq,netease,kugou,spotify,apple,soda,foobar,other,browser
```

Local files can be named `Artist - Title.lrc`, `Title - Artist.lrc`, or `Title.lrc`. QRC and YRC use the same naming patterns. Only the specified directory is searched; subdirectories are not scanned recursively.

## 5. Validation Results for This Round

- The latest version was compiled using Windhawk and loaded into Explorer.
- QQ Music testing retrieved 48 lyric lines with 309 genuine word-timed segments, and other tracks were also checked.
- Direct track-ID retrieval through the NetEase API succeeded. A search sample returned 98 lyric lines with 579 genuine word-timed segments.
- Tests passed for LRC, QRC, YRC, enhanced LRC, decryption, timing offsets, word-timing boundaries, player identifiers, priority, and Apple timeline handling.
- Other clients still require verification against their actual versions, SMTC reporting behavior, and specific tracks.

For technical details and reference projects, see [LYRICS.md](LYRICS.md).
