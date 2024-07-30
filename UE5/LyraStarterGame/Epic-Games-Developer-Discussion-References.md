---
title: Epic Games Developer Discussion References
description: Annotated links to Epic Games developer live streams and videos
back_links:
  - link: /UE5/
    name: UE5
  - link: /UE5/LyraStarterGame/
    name: LyraStarterGame
---


# Epic Games 开发者讨论

这是我查看过的 Epic Games 开发者与 LyraStarterGame 相关的一些更有趣的讨论的集合。

并非所有这些都直接谈论 LyraStarterGame，但它们确实涵盖了需要理解的相关技术，以便有效地将 LyraStarterGame 转变为自定义游戏。

## Lyra Starter Game 概述（Epic Games）

该视频由 Epic 在 5.0 发布前发布，如果您想了解 Lyra 及其整体情况，这是必看视频。

[完整视频](https://youtu.be/Fj1zCsYydD8)

一些特别有趣的观点：

- [06:57 - 什么是体验](https://youtu.be/Fj1zCsYydD8?t=417)
- [09:57 - 面向用户的体验](https://youtu.be/Fj1zCsYydD8?t=597)
- [11:58 - 在线功能](https://youtu.be/Fj1zCsYydD8?t=718)
- [13:21 - 可扩展性](https://youtu.be/Fj1zCsYydD8?t=801)
- [14:40 - UE5 人体模型](https://youtu.be/Fj1zCsYydD8?t=880)
- [16:21 - 化妆品& 动画](https://youtu.be/Fj1zCsYydD8?t=981)
- [20:41 - 团队颜色](https://youtu.be/Fj1zCsYydD8?t=1241)
- [23:48 - 输入系统](https://youtu.be/Fj1zCsYydD8?t=1428)
- [26:19 - 关卡设计灰盒](https://youtu.be/Fj1zCsYydD8?t=1579)

## Lyra Walkthru 问答

这是上面链接的原始视频的后续内容。如果您要观看整个视频，Twitch 版本比 YouTube 版本要好得多。

[完整视频](https://www.twitch.tv/videos/1469444417)

Twitch 版本：
- [0:11:14 - 创造新体验](https://www.twitch.tv/videos/1469444417?t=0h11m14s)
- [0:22:54 - 创建 GameFeature 插件](https://www.twitch.tv/videos/1469444417?t=0h22m54s)
- [0:23:52 - ? TOTO ?](https://www.twitch.tv/videos/1469444417?t=0h22m54s)
- [他引用的模块化游戏视频](https://www.twitch.tv/videos/1101918638?filter=archives&sort=time)
- [0:26:08 - 参考查看器](https://www.twitch.tv/videos/1469444417?t=0h26m08s)
- [参考查看器截图](https://twitter.com/joatski/status/1453130573380206601/photo/1)

YouTube 版本（有故障）：
- [0:24:13 - 如何设置游戏可执行文件名称](https://youtu.be/N1X7BgIQ4QY?t=1453)
- [0:26:28 - 如何让 EOS (Epic Online Subsystem) 运行](https://youtu.be/N1X7BgIQ4QY?t=1588)
- [0:29:47 - Lyra 库存系统概述](https://youtu.be/N1X7BgIQ4QY?t=1787)
- [0:35:30 - 常见加载屏幕](https://youtu.be/N1X7BgIQ4QY?t=2130)
- [0:45:33 - Unreal 编辑器网络延迟工具](https://youtu.be/N1X7BgIQ4QY?t=2733)
- [0:50:04 - 开发人员秘籍 &技巧](https://youtu.be/N1X7BgIQ4QY?t=3004)
- [0:51:14 - 队伍颜色](https://youtu.be/N1X7BgIQ4QY?t=3074)
- [0:52:05 - 英雄/典当数据资产](https://youtu.be/N1X7BgIQ4QY?t=3125)
- [1:00:27 - 提示：CTRL+B 和 CTRL+E 编辑器快捷键](https://youtu.be/N1X7BgIQ4QY?t=3627)
- [1:01:57 - 提示：视口收藏夹](https://youtu.be/N1X7BgIQ4QY?t=3757)
- [1:03:12 - 提示：菜单：工具 >搜索](https://youtu.be/N1X7BgIQ4QY?t=3792)

## 模块化游戏功能

该视频由 Michael Noland 在 Lyra Walkthru Q&A 中推荐

[完整视频](https://www.twitch.tv/videos/1101918638?filter=archives&sort=time)

兴趣点：

- [0:08:22 - 开始讨论](https://www.twitch.tv/videos/1101918638?t=0h8m22s)

- [0:09:06 - 模块化游戏系统概述](https://www.twitch.tv/videos/1101918638?t=0h9m6s)

- [0:14:42 - AssetManager集成](https://www.twitch.tv/videos/1101918638?t=0h14m42s)
- [0:15:32 - GameFeature 激活/停用时的操作](https://www.twitch.tv/videos/1101918638?t=0h15m32s)
- [0:18:17 - 通过 GameFeature 插件中的蓝图添加新的 Pawn 能力](https://www.twitch.tv/videos/1101918638?t=0h18m7s)
- [0:29:04 - 问：GameFeature 插件应该有多精细？](https://www.twitch.tv/videos/1101918638?t=0h29m4s)
- [0:32:27 - 问：GameFeature1 是否会影响GameFeature2?](https://www.twitch.tv/videos/1101918638?t=0h32m27s)
- [0:33:42 - GameFeature 插件的资源引用策略](https://www.twitch.tv/videos/1101918638?t=0h33m42s)
- [0:36:09 - GameFeature 插件实际上是一个“Mod”而不是“插件”](https://www.twitch.tv/videos/1101918638?t=0h36m9s)
- [0:39:47 - AncientGame 如何使用 GameFeature 插件](https://www.twitch.tv/videos/1101918638?t=0h39m47s)
- [0:41:58 - 如何将动画添加到基础角色](https://www.twitch.tv/videos/1101918638?t=0h41m58s)
- [0:48:00 - AncientGame HoverDrone 为例](https://www.twitch.tv/videos/1101918638?t=0h48m0s)
- [0:59:54 - 增强输入系统](https://www.twitch.tv/videos/1101918638?t=0h59m54s)
- [1:15:41 - 使用 GameFeature 插件的 DLC 交付方法](https://www.twitch.tv/videos/1101918638?t=1h15m41s)
- [1:19:39 - 问：动态添加调试组件？](https://www.twitch.tv/videos/1101918638?t=1h19m39s)
- [1:23:03 - 问：您可以从 GameFeature 继承吗