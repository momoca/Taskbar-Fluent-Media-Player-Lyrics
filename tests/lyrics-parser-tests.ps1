$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$source = Get-Content -LiteralPath (Join-Path $root 'taskbar-fluent-media-player.wh.cpp') -Raw
$start = $source.IndexOf('// QQ QRC cipher port')
$end = $source.IndexOf('static std::wstring CurrentLyric(', $start)
if ($start -lt 0 -or $end -le $start) { throw 'Cannot locate production LRC parser' }
$parser = $source.Substring($start, $end - $start)
$profileStart = $source.IndexOf('enum class PlayerSource {')
$profileEnd = $source.IndexOf('// Separate snapshots keep', $profileStart)
$profiles = $source.Substring($profileStart, $profileEnd - $profileStart)
$preamble = @'
#include <string>
#include <vector>
#include <sstream>
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cassert>
#include <iostream>
#include <windows.h>
#include <winhttp.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Json.h>
#include <atomic>
#include <cwctype>
#include <array>
#include <mutex>
#include <bcrypt.h>
static std::atomic<bool> g_unloading{false};
#define Wh_Log(...) ((void)0)
'@
$cases = @'
int main() {
    auto a = ParseLyrics(L"[ar:Artist]\n[00:01.2]one\n[00:03.45][00:04.567]repeat\n[00:06]\n");
    assert(a.size() == 4 && a[0].ms == 1200 && a[1].ms == 3450 && a[2].ms == 4567);
    assert(a[3].ms == 6000 && a[3].text.empty());
    auto b = ParseLyrics(L"\xFEFF[00:02.00]second\r\n[00:01]first\n[offset:250]\n");
    assert(b.size() == 2 && b[0].ms == 750 && b[1].ms == 1750 && b[1].text == L"second");
    auto c = ParseLyrics(L"[00:01]original\n[00:01]translation\n[00:01]original\n");
    assert(c.size() == 1 && c[0].text.find(L"translation") != std::wstring::npos);
    assert(ParseLyrics(L"plain lyrics\n[ar:name]\n[00:61]bad\n[xx:01]bad\n[00:1.2.3]bad").empty());
    auto d = ParseLyrics(L"[00:01]first\n[00:03]second\n[00:05]\n");
    auto select = [&](int64_t ms) {
        auto next = std::upper_bound(d.begin(), d.end(), ms,
            [](int64_t position, const LyricLine& line) { return position < line.ms; });
        return next == d.begin() ? std::wstring{} : std::prev(next)->text;
    };
    assert(select(999).empty() && select(1000) == L"first");
    assert(select(3000) == L"second" && select(5000).empty());
    assert(select(1500) == L"first"); // seek backwards
    auto qrc = ParseWordLyrics(L"[1000,1500]你(1000,400)好(1400,600)！(2000,500)\n[3000,1000]下一句(3000,1000)");
    assert(qrc.size() == 2 && qrc[0].text == L"你好！" && qrc[0].words.size() == 3);
    assert(qrc[0].words[1].ms == 1400 && qrc[0].words[1].duration == 600);
    std::vector<double> widths{0,10,25,30};
    assert(LyricHighlightWidth(qrc[0].words, 999, widths) == 0);
    assert(LyricHighlightWidth(qrc[0].words, 1200, widths) == 5);
    assert(LyricHighlightWidth(qrc[0].words, 1700, widths) == 17.5);
    assert(LyricHighlightWidth(qrc[0].words, 2600, widths) == 30);
    assert(LyricHighlightWidth(qrc[0].words, 1200, widths) == 5); // seek backwards
    assert(LyricHighlightWidth({}, 1700, widths) == 0); // never invent word timing
    auto gap = ParseWordLyrics(L"[1000,2000]你(1000,200)好(2000,1000)");
    assert(LyricHighlightWidth(gap[0].words, 1800, widths) == 10); // hold between real words
    auto zero = ParseWordLyrics(L"[1000,500]你(1000,0)好(1200,300)");
    assert(LyricHighlightWidth(zero[0].words, 1000, widths) == 10);
    auto elrc = ParseWordLyrics(L"[offset:100]\n[00:01]<00:01>你<00:01.4>好<00:02>\n");
    assert(elrc.size() == 1 && elrc[0].text == L"你好" && elrc[0].words.size() == 2);
    assert(elrc[0].ms == 900 && elrc[0].words[0].ms == 900 && elrc[0].words[1].duration == 600);
    auto plain = ParseWordLyrics(L"[00:01]你好\n[00:02]再见\n");
    assert(plain.size() == 2 && plain[0].words.empty());
    // Ciphertext generated independently by the original JS cipher, then zlib compressed.
    std::wstring fixture = L"ee7befb746f93831d42dcdf2e21f0d5d977de00c85449a7c535da3bcf1beb3ca54d5d801d40005b7aa5cced3246e3a5f6b40d6f294403ebed1fad49758a706d8d82df65f35d288ea0e12bda1fdd66e72d650193fbfb2983462b10a7655fc9839667e833b3615888d4eedbde42fa49dc0d5dccbec11f71726";
    auto decrypted = QqQrc::Decode(fixture);
    auto decoded = ParseWordLyrics(LyricUtf8(decrypted));
    assert(decoded.size() == 2 && decoded[0].text == qrc[0].text && decoded[0].words[1].ms == 1400);
    fixture[0] = fixture[0] == L'a' ? L'b' : L'a';
    assert(QqQrc::Decode(fixture).empty());
    assert(QqQrc::Decode(L"not hex").empty());
    assert(ParseWordLyrics(L"[1000,500]你(1000,9999999999)").empty());
    auto yrc = ParseYrcLyrics(L"{\"t\":0}\n[1000,1500](1000,400,0)你(1400,600,0)好(2000,500,0)！\n");
    assert(yrc.size() == 1 && yrc[0].text == L"你好！" && yrc[0].words.size() == 3);
    assert(yrc[0].words[1].ms == 1400 && yrc[0].words[1].duration == 600);
    assert(ParseYrcLyrics(L"[1000,500](bad)text").empty());
    assert(ExtractPlayerSongId(PlayerSource::Netease,{L"Rock",L"NCM-123456"}) == L"123456");
    assert(ExtractPlayerSongId(PlayerSource::QQ,{L"QQ-003abc"}) == L"003abc");
    assert(ExtractPlayerSongId(PlayerSource::Netease,{L"NCM-bad&other=1"}).empty());
    assert(ExtractPlayerSongId(PlayerSource::Spotify,{L"NCM-123"}).empty());
    assert(LyricArtistsEquivalent(L"A / B",L"B、A"));
    assert(!LyricArtistsEquivalent(L"A / B",L"A"));
    assert(NeteaseEapiForm("/api/song/lyric/v1","{\"id\":\"123\"}") == "params=04AE33D34A93FE3EC22DA8FA305D290AB337D0FE5F36D211DE0D338CC6AA89D0E132480CA4AAA841CABC849C58C2067F7ECBE33F2693AF387545E1032268EE6CDB7427D62D934CBF1EECE7247E77344B1D4A3034649D3C913D992D368E2BDA84");
    assert(ClassifyPlayerSource(L"QQMusic.exe") == PlayerSource::QQ);
    assert(ClassifyPlayerSource(L"NeteaseCloudMusic.exe") == PlayerSource::Netease);
    assert(ClassifyPlayerSource(L"MoeKoeMusic.exe") == PlayerSource::Kugou);
    assert(ClassifyPlayerSource(L"SpotifyAB.SpotifyMusic_zpdnekdrzrea0!Spotify") == PlayerSource::Spotify);
    assert(ClassifyPlayerSource(L"AppleInc.AppleMusicWin_nzyj5cx40ttqa!App") == PlayerSource::Apple);
    assert(ClassifyPlayerSource(L"com.soda.music") == PlayerSource::Soda);
    assert(ClassifyPlayerSource(L"foobar2000.exe") == PlayerSource::Foobar);
    assert(ClassifyPlayerSource(L"MSEdge") == PlayerSource::Browser);
    assert(ClassifyPlayerSource(L"MyCustomPlayer.exe") == PlayerSource::Other);
    auto priorities=ParsePlayerPriority(L"spotify,QQ, spotify,unknown");
    assert(priorities[(size_t)PlayerSource::Spotify]==0 && priorities[(size_t)PlayerSource::QQ]==1);
    assert(priorities[(size_t)PlayerSource::Browser]>priorities[(size_t)PlayerSource::Foobar]);
    PlayerTimelineSmoother apple;
    assert(apple.Select(PlayerSource::Apple,L"track",10000,100000,100100,1000,true,1)==10100);
    assert(apple.Select(PlayerSource::Apple,L"track",10000,100100,100300,1200,true,1)==10300);
    assert(apple.Select(PlayerSource::Apple,L"track",11000,101000,101000,1900,true,1)==11000);
    auto paused=apple.Select(PlayerSource::Apple,L"track",11000,101001,101100,2000,false,1);
    assert(apple.Select(PlayerSource::Apple,L"track",11000,101001,102100,3000,false,1)==paused);
    assert(apple.Select(PlayerSource::Apple,L"track",30000,102000,102100,3100,true,1)==30000);
    assert(apple.Select(PlayerSource::Apple,L"track",5000,103000,103100,3300,true,1)==5000);
    PlayerTimelineSmoother common;
    assert(common.Select(PlayerSource::Spotify,L"track",1000,100000,100500,1000,true,1.5)==1750);
    assert(common.Select(PlayerSource::Netease,L"track",1000,100000,100500,1000,false,1)==1000);
    std::cout << "Lyrics / EAPI / YRC / player identity / priority / timeline checks passed\n";
}
'@
$buildDir = Join-Path $root '.lyrics-check'
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
$testSource = Join-Path $buildDir 'lyrics-parser-tests.cpp'
$exe = Join-Path $buildDir 'lyrics-parser-tests.exe'
Set-Content -LiteralPath $testSource -Value ($preamble + "`n" + $profiles + "`n" + $parser + "`n" + $cases) -Encoding utf8
$compiler = 'C:\Program Files\Windhawk\Compiler\bin\clang++.exe'
& $compiler --target=x86_64-w64-mingw32 -D_WIN32_WINNT=0x0A00 -std=c++23 -static $testSource -o $exe -lole32 -lruntimeobject -lwindowsapp -lwinhttp -lbcrypt
if ($LASTEXITCODE -ne 0) { throw 'Parser test compilation failed' }
& $exe
if ($LASTEXITCODE -ne 0) { throw 'Parser tests failed' }
