---
title: Customizing the Lyra Front-end
description: Detailed description of all the steps necessary to customize the LyraStarterGame front-end experience
back_links:
  - link: /UE5/
    name: UE5
  - link: /UE5/LyraStarterGame/
    name: LyraStarterGame
---

# 1 自定义 Lyra 前端

## 1.1 资产管理器更新

在此过程进行得更深入之前，我们需要修改 AssetManager，以便它知道在哪里找到我们要添加的新内容。在这里，我假设您一直在关注我的教程，因此您的设置与我的相同。

### `XistGame.uasset` 资产管理器增量

- 修改现有的：
  - `Map` 添加目录 `/XistGame/FrontEnd/Maps`
- 添加新的：
  - `LyraLobbyBackground` 添加目录 `/XistGame/FrontEnd`

如果您只想用以下内容替换现有内容，以下是 `XistGame` 的完整 `主要资产类型扫描` 设置：

```text
((PrimaryAssetType="LyraExperienceDefinition",AssetBaseClass="/Script/LyraGame.LyraExperienceDefinition",bHasBlueprintClasses=True,Directories=((Path="/XistGame/Experiences"))),(PrimaryAssetType="LyraExperienceActionSet",AssetBaseClass="/Script/LyraGame.LyraExperienceActionSet",Directories=((Path="/XistGame/Experiences"))),(PrimaryAssetType="Map",AssetBaseClass="/Script/Engine.World",Directories=((Path="/XistGame/Maps"),(Path="/XistGame/FrontEnd/Maps"))),(PrimaryAssetType="PlayerMappableInputConfig",AssetBaseClass="/Script/EnhancedInput.PlayerMappableInputConfig",Directories=((Path="/XistGame/Input/Configs"),(Path="/Game/Input/Configs"))),(PrimaryAssetType="LyraLobbyBackground",AssetBaseClass="/Script/LyraGame.LyraLobbyBackground",Directories=((Path="/XistGame/FrontEnd"))),(PrimaryAssetType="LyraUserFacingExperienceDefinition",AssetBaseClass="/Script/LyraGame.LyraUserFacingExperienceDefinition",Directories=((Path="/XistGame/Experiences/Playlists"))))
```
   
#### 必须重新启动编辑器以使 Asset Manager 更改生效！！

进行上述更改后，**必须**重新启动 UE5 编辑器以使这些更改生效。

## 1.2 创建大厅背景

### 脚本用于随机加载我们自己的背景地图之一

默认的 Lyra 代码将随机加载可能位于代码中*任何地方*的*任何*背景地图，这不是我们想要的。我们只希望加载我们自己的背景。这里我们复制 Lyra 实现并将其更改为仅选择我们自己的背景：

- 复制 `Lyra.Environments/B_LoadRandomLobbyBackground`
  - `XistGame.FrontEnd/B_XG_LoadRandomLobbyBackground`
    - 修改 `BeginPlay` 事件，以便过滤掉名称以除 `DA_XG_` 以外的任何内容开头的大厅背景
      - 在我的版本中，我添加了返回布尔值的新函数 `IsRelevantLobbyBackground`


### 创建 LobbyBackground1，可能还有更多

这是您将看到的作为菜单背景的地图。

- 创建 `XistGame.FrontEnd/Maps/L_XG_LobbyBackground1`
  - 这是将在菜单页面的背景中显示的地图
  - 最低限度的设置：
    - 需要查看的内容
    - 电影摄影机
    - 强制将视图移到电影摄影机的 LevelSequence 演员
  - 我的设置只是一个小小的绿灯竞技场，里面有 3 个球在滚动

- 创建 `LyraLobbyBackground` 数据资产 `XistGame.FrontEnd/DA_XG_LobbyBackground1`
  - 设置对 `L_XG_LobbyBackground1` 的引用

### 如果需要，可以创建更多！

如果需要，您可以创建更多大厅背景。上面的解决方案将搜索名为 `DA_XG_*` 的任何/所有大厅背景，并随机显示其中一个作为背景菜单。创建更多循环比您上面的工作要容易得多。只需制作一个新的“L_XG_LobbyBackgroundN”地图（增加 N！），然后创建一个“DA_XG_LobbyBackgroundN”资产来指向它。

## 1.3 创建大厅体验

创建体验定义：
- 复制 `Lyra.System/FrontEnd/B_LyraFrontEnd_Experience`
  - `XistGame.Experiences/B_XG_Experience_FrontEnd`

创建将激活体验的地图：

- 复制 `Lyra.System/FrontEnd/Maps/L_LyraFrontEnd`
  - `XistGame.FrontEnd/Maps/L_XG_FrontEnd`
    - 替换随机大厅背景逻辑
      - 删除原版 Lyra(vanilla Lyra) `B_LoadRandomLobbyBackground` actor
      - 新增一个 `B_XG_LoadRandomLobbyBackground` 角色
    - 设置 `WorldSettings`.`Game Mode`.`Default Gameplay Experience` = `B_XG_Experience_FrontEnd`

更改项目设置以默认加载此体验：
- Maps & Modes > Default Maps > Game Default Map = `L_XG_FrontEnd`


## 1.4 自定义菜单本身
TODO
此外，这里还有很多 TODO，但希望以上内容能帮助您入门。如果您到目前为止一直关注，您应该有足够的洞察力从这里继续自己。我希望在实际构建了一个需要玩家使用菜单的游戏后，在某个时候回到这一点。