---
title: Create a UE5 GameFeature Plugin for LyraStarterGame
description: Describes the procedure by which to create a new UE5 GameFeature Plugin for Lyra Starter Game (LyraStarterGame)
back_links:
  - link: /UE5/
    name: UE5
  - link: /UE5/LyraStarterGame/
    name: LyraStarterGame
---

# 创建 UE5 GameFeature 插件

要制作基于 Lyra 的游戏，您需要在 LyraStarterGame 项目中创建一个 GameFeature 插件。此插件没有什么特别之处，只是必须进入 `Plugins/GameFeatures` 目录。

## 如何为 Lyra 创建 UE5 GameFeature 插件

在 UE5 编辑器中打开 LyraStarterGame 项目，请按照以下步骤操作：

- UE5 编辑器菜单：`Edit` > `Plugins`
- 单击 `+ Add` 按钮
- 选择 `Game Feature (with C++)` 模板
- 命名插件（我将我的插件命名为 `XistGame`）
- 单击 `Create Plugin` 按钮

创建此插件时，它将为您提供一个初始的、几乎为空的 `GameFeatures.GameFeatureData` 数据资产，以您的游戏命名。

## 向其他插件添加依赖项

*此步骤是可选的*。如果您想要从基础 `ShooterCore` 扩展游戏，则只需执行此操作。如果您的游戏根本不使用任何 `ShooterCore` 内容，则可以跳过此步骤。

- 打开您的 `XistGame` 数据资产（无论您将插件命名为什么）。
- 将插件的 `Current State` 更改为 `Registered`（默认情况下应为 `Active`）
- 单击 `Edit Plugin` 按钮
- 滚动到底部，其中列出了 `Dependencies`
  - 添加 `ShooterCore` 的依赖项
  - 添加 `LyraExampleContent` 的依赖项
  - `Save` 按钮
- 将插件的 `Current State` 更改回 `Active`
- `Save` 数据资产

## 初始插件内容

您的插件现在包含最少的默认内容。有 uplugin 定义、`GameFeatures.GameFeatureData` uasset 配置、图标和所需的样板 C++ 代码。

### Plugins/GameFeatures/XistGame 目录列表
```text
XistGame
├── Content
│   └── XistGame.uasset
├── Resources
│   └── Icon128.png
├── Source
│   ├── XistGameRuntime
│   │   ├── Private
│   │   │   └── XistGameRuntimeModule.cpp
│   │   └── Public
│   │       └── XistGameRuntimeModule.h
│   └── XistGameRuntime.Build.cs
└── XistGame.uplugin
```

### 不喜欢那些默认的“运行时”名称？

如果您不喜欢名为“XistGameRuntime”的文件（以及 API 导出代码“XISTGAMERUNTIME_API”）那么您现在可以更改它们。

我是个很挑剔的人，看到到处都是 `XISTGAMERUNTIME_API` 而不是`XISTGAME_API` 让我很烦。我知道（而且并不在意）我的插件是在运行时加载的。我不需要在整个代码中都看到它！

如果您想更改这一点，**现在是时候了**。这完全是可选的，但如果您等待，以后更改它可能并不容易。

[如何：从 GameFeature 插件代码名称中删除“运行时”后缀](/UE5/GameFeatures/How-To-Remove-GameFeature-Runtime-Code-Suffix)

## 下一步：配置资产管理器

现在您有了插件，您需要配置资产管理器，以便它知道在哪里找到您的游戏组件。

[配置资源管理器](/UE5/LyraStarterGame/Setup/GameFeatureData-AssetManager)或返回 [Lyra Starter Game](./)

## 想要更多信息？

可以通过观看我注释的一些[Epic Games 开发者讨论](./Epic-Games-Developer-Discussion-References)来获取有关创建 GameFeature 插件的更多信息。