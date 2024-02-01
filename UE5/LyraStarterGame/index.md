---
title: "LyraStarterGame Overview"
description: "Learn how to make a new game based on UE5 LyraStarterGame (Lyra)"
breadcrumb_path: "UE5"
breadcrumb_name: "LyraStarterGame"
---


# 1 构建Lyra框架

不要从头开始！从Lyra开始。这是Epic建议我们基于Lyra开始新游戏的意图。他们希望我们把Lyra当作引擎代码，也就是以它为基础，构建我们的新游戏。对我们来说，成本仅仅是学习他们如何配置游戏以及如何扩展他们构建的框架。
优缺点讨论了为什么你可能想要或不想要使用Lyra。根据你的情况，使用或不使用Lyra都有正当的理由。
如果你已经有现成的游戏，Lyra提供了一些插件和游戏系统，你可以将它们复制到你的游戏中，省去很多工作。
如果你正在开始一个新游戏，最好是从Lyra开始，然后删除你不想要的内容，而不是将你想要的内容（可能很重要）从Lyra复制到一个空白的游戏中。有多种可行的方法可以以Lyra为基础开始你的新游戏。一些选项在这里进行了讨论。

这些信息来自于discussed:
[Extending Lyra: Development Considerations](./Development-Considerations)


# 2 Getting Started

创建自己的 LyraStarterGame project?

- [Epic official tutorial: How to create a new Game Feature Plugin and Experience in Lyra](https://dev.epicgames.com/community/learning/tutorials/rdW2/unreal-engine-how-to-create-a-new-game-feature-plugin-and-experience-in-lyra)

我在官方指南发布之前制作了这个操作指南，我将其保留在这里以供后人参考: [Set Up a New LyraStarterGame Project](./Getting-Started-Setting-Up-a-New-LyraStarterGame-Project)


# 3 Lyra概念

## 3.1 工程组织结构  
在我看来，你应该尽量不修改基本的Lyra游戏，除非你确实必须。基本游戏的整个命名空间应被视为Lyra所保留。  
- 内容放入GameFeature插件（GFP）
- 核心C++可以放入常规插件
  - 实际上这是理想的，尽管这是可选的

至少你需要为你的内容创建一个GFP

IMO you should try to not modify the base Lyra game unless you **really must**.
The entire namespace of the base game should be considered to be reserved by Lyra.

- Content goes into GameFeature Plugins (GFPs)
- Core C++ can go into a regular Plugin
  - Practically speaking this is ideal, though it is optional

At the very least you need to create one GFP for your Content.

## 3.2 升级 Lyra Core

Epic will sometimes upgrade the Engine and/or Lyra Core.

[Upgrading Lyra Core](./Upgrading-Lyra-Core/)
discusses how I try to make this process as easy on myself as possible.

[Re-save Assets on Engine Update](/UE5/Engine/Resave-Assets)
discusses the need to explicitly re-save many binary project assets any time you
update the Engine version.  This is a UE requirement that significantly affects
Editor startup time.


## 3.3 Player Input

Common UI "owns" player input

  - [Lyra Input Overview](./Input/)
  - [How Common UI is Setup in Lyra](./CommonUI/)
  - [High Level Overview of Common UI in General](/UE5/CommonUI/)
  - [How to take Control of the Mouse in Lyra](/UE5/LyraStarterGame/Tutorials/How-to-Take-Control-of-the-Mouse)


## 3.4 Lyra Game Mode

- [Lyra Experience](./Experience/)
  - Lyra如何以及为何以目前的方式加载GFPs
- [Lyra Game Initialization](./InitGame/)
  - 调试追踪以说明Lyra World如何启动和初始化自身
- [Lyra Game Phase Subsystem](./GamePhaseSubsystem/)
  - 一旦游戏开始进行，如何管理游戏过程的不同阶段
- [Lyra Plugins](./Plugins/)
  - Epic通过Lyra项目分发的插件概述


## 3.5 Lyra Gameplay Systems

- [Character Parts](./CharacterParts/)
  - 模块化角色部件
- [Equipment System](./Equipment/) *(prototype)*
  - Inventory 扩展：Inventory Items that are pieces of Equipment usable by Pawns
- [Health and Damage System](./Health-and-Damage/)
  - Based on Gameplay Ability System Attributes & Effects
- [Interaction System](./Interactions/) *(prototype)*
  - Allows the player to interact with Actors in the World
- [Inventory System](./Inventory/) *(prototype)*
  - Allows pawns to keep items in inventory
- [Team System](./Teams/)
  - Organize Players, Pawns, etc into Teams
- [Weapon System](./Weapons/) *(prototype)*
  - Equipment extension: Equipment Items that are Weapons usable by Pawns


## 3.6 Lyra其他系统

- [Game Settings](https://docs.unrealengine.com/5.3/en-US/lyra-sample-game-settings-in-unreal-engine/)
  - Comprehensive Game Settings *(this is a beast to try to copy out due to the extensive use of UI assets, but it can be done)*


## 3.7 Lyra Character

- [Shooter Mannequin Character](./ShooterMannequin)
  - `B_Hero_ShooterMannequin` 是Lyra中的基础角色, 需要充分理解

  - Demonstrates key concept: 异步、相互依赖的Pawn组件的ModularGameplay初始化（Asynchronous, inter-dependent `ModularGameplay` Initialization of Pawn components）

- Lyra provides a great `Character` base, but *does not provide* a useful `Pawn`.
  - This seems to be typical in UE5; Characters are first class, Pawns are completely up to you.
  （这在UE5中似乎很典型；角色（Characters）是first class，而Pawn则完全由你决定。）

## 3.8 Gameplay Ability System (GAS)

#### Lyra-Specific GAS Resources

- [How to: Create a New Gameplay Ability](./Tutorials/How-To-Create-a-New-Gameplay-Ability)
- Lyra Ability Tag Relationship Maps
  - [Tutorial courtesy of ScaleSculptor](https://www.artstation.com/blogs/scalesculptor/ZgqV/ability-tag-relationship-maps-in-lyra)
- C++ Examples:
  - [How to: Send Client Gameplay Ability Data to Server in C++](/UE5/GameplayAbilitySystem/How-To-Send-Client-Gameplay-Ability-Data-to-Server-in-C++)
  - [Target Dummy Actor Full C++ Example](https://github.com/x157/Lyra-ActorWithAbilities) (Github)

#### General GAS Resources

- [UE5 Gameplay Ability System Conceptual Overview](/UE5/GameplayAbilitySystem/)
- Gameplay Attributes:
    - [Attributes and Attribute Sets](https://docs.unrealengine.com/5.0/en-US/gameplay-attributes-and-attribute-sets-for-the-gameplay-ability-system-in-unreal-engine/) (Epic Documentation)
    - [Attributes and Gameplay Effects](https://docs.unrealengine.com/5.0/en-US/gameplay-attributes-and-gameplay-effects-for-the-gameplay-ability-system-in-unreal-engine/) (Epic Documentation)


# 4 各种Lyra相关的方面

In an effort to understand the material Epic has provided us to start with, I am dissecting the GameFeature plugins they shipped to understand what they do, how they're similar and how they differ from one another.

为了理解Epic提供给我们的起步材料，我正在分析他们提供的GameFeature插件，以了解它们的功能、相似之处以及它们之间的差异。

| Module                        | Description                       |
|-------------------------------|-----------------------------------|
| [ShooterCore](./ShooterCore/) |  射击游戏基础框架 |
| [ShooterMaps](./ShooterMaps/) |  "ShooterCore" 的实现     |
| TopDownArena                  |  *跳过*       |

Bug fixes:

- [How to: Resave Lyra 5.1 Assets for faster Editor Load Times](./How-To-Resave-Assets-v5.1)
- [How to: Fix Lyra's Unarmed Animation Bugs](./Tutorials/How-To-Fix-Lyra-Unarmed-Animation-Bugs)

Works in progress:

- [How to: Customize the Lyra FrontEnd](./How-To-Customize-Lyra-FrontEnd) *(incomplete; coming eventually)*


# References

随着我对LyraStarterGame的了解越来越多，我正在整理一个参考列表。

- [Lyra 5.3 Release Notes](https://docs.unrealengine.com/5.3/en-US/upgrading-the-lyra-starter-game-to-the-latest-engine-release-in-unreal-engine/#unrealengine5.3)

- [Epic Games Developer Discussion References](./Epic-Games-Developer-Discussion-References)

