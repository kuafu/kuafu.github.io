---
title: "Lyra UI Policy"
description: "How the Lyra UI Policy is configured and how it works"
breadcrumb_path: "UE5/LyraStarterGame/Input"
breadcrumb_name: "UI Policy"
---

# 1 Lyra UI 策略概述
UI 策略：`B_LyraUIPolicy`*（在`DefaultGame.ini`中定义）*

基本 C++：主要游戏布局：`UPrimaryGameLayout`
- 基于通用用户小部件（[Common UI](/UE5/CommonUI/))

设置整体 UI 布局类 = `W_OverallUILayout`


<a id='W_OverallUILayout'></a>
## 1.1 整体 UI 布局：`W_OverallUILayout`
将 HUD 定义为由按优先级命名的 [可激活小部件](/UE5/CommonUI/ActivatableWidget) 层组成。

- 具有活动小部件的最高优先级层获取输入
- 如果没有层认领输入，则输入通过 [增强输入](/UE5/EnhancedInput/) 流向游戏

| Priority | Layer Name          | Notes                                         |
|----------|---------------------|-----------------------------------------------|
| 1        | `UI.Layer.Game`     | implement with [Lyra HUD Layout](./HUDLayout) |
| 2        | `UI.Layer.GameMenu` |                                               |
| 3        | `UI.Layer.Menu`     |                                               |
| 4        | `UI.Layer.Modal`    |                                               |


### 关于 GameplayTags 的说明

名称是 `LyraProject:/Source/LyraGame/LyraGameplayTags.h` 中定义的 GameplayTags

在 Lyra 5.2 及更高版本中，标签已重构到 `LyraGameplayTags` 命名空间中，并且现在默认情况下它们全部导出。

在 Lyra 5.1 及更早版本中，为了能够在您自己的 C++ 模块中使用这些标签，请使用 `LYRAGAME_API` 导出 `FLyraGameplayTags`。

## 1.2 详细的通用 UI 设置详情
有关更多详细信息，请参阅 [Lyra 默认 UI 策略详情](/UE5/LyraStarterGame/CommonUI/DefaultUIPolicy)。