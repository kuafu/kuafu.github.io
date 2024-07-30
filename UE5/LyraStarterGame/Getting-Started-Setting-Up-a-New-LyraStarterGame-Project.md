---
title: How to Set Up a New LyraStarterGame Project
description: Get your LyraStarterGame Project set up and ready to work in
back_links:
- link: /UE5/
  name: UE5
- link: /UE5/LyraStarterGame/
  name: LyraStarterGame
back_link_title: Create New LyraStarterGame Project
---

# 入门：设置新的 LyraStarterGame 项目

在使用 LyraStarterGame 进行大量操作之前，您首先需要创建一个新的 UE5 LyraStarterGame 项目并自行定制。

# 步骤 1：创建 GameFeature 插件

UE5+Lyra 的设置使您永远无需接触基础代码。Michael Noland 说“将 Lyra 视为引擎代码。”

然后，我们为 Lyra 制作“GameFeature 插件”来创建新游戏。它不是传统意义上的插件，更像是模组。

通过将我们所有的工作都包含在我们自己的插件中，我们确保尽可能轻松地集成 Epic 在基础 Lyra 框架上生成的未来升级、错误修复等。

[如何创建 GameFeature 插件](./How-To-Create-a-GameFeature-Plugin)

# 步骤 2：配置游戏功能数据

有了插件后，您需要告诉 Lyra 的 Asset Manager 在哪里可以找到插件的文件。

[如何为 GameFeature 插件配置 Asset Manager](./Setup/GameFeatureData-AssetManager)

您还需要添加 Gameplay Cue 路径，以便制作自定义提示：

[将 GameplayCue 路径添加到 GameFeatureData](./Setup/GameFeatureData-AddGameplayCuePath)

# 步骤 3：创建您的开发体验

Lyra 中的“体验”本质上是某种形式的用户交互。它是一张地图，以及一组输入和
控件，可能会或可能不会与其他地图或其他体验共享。

您设置的第一个体验是最难的，需要为您的 mod 完成一些样板工作。

因此，我们将设置一个纯粹以开发为中心的体验，以便我们有一个基本的起点。

[如何创建您的开发体验](./How-To-Create-New-GameFeature-Dev-Experience)

# 恭喜

您现在拥有一个属于您自己的 LyraStarterGame 项目！

是时候[了解有关 LyraStarterGame 的更多信息](/UE5/LyraStarterGame/) 并构建您的游戏了！