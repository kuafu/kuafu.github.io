---
title: "LyraStarterGame Equipment System"
description: "Overview of the Equipment system in UE5 LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Equipment System"
---


# 1 LyraStarterGame Equipment System
这是 [LyraStarterGame](/UE5/LyraStarterGame/) 中装备系统的概述。

一个 Lyra 中的装备是一个具有特定 Item Definition Fragment 的库存项目，该片段将其标识为装备。因此，该系统基于 Lyra 库存系统 [Lyra Inventory System](/UE5/LyraStarterGame/Inventory/)，请确保您也熟悉该系统。

Lyra 装备系统是 Lyra 武器系统[Lyra Weapon System](/UE5/LyraStarterGame/Weapons/)的基础。

请注意，尽管装备定义和装备实例与库存定义和库存实例共享命名约定，**但对象之间的关系是不同的**。这可能会引起混淆，因此请注意。


## 1.1 Equipment Concepts

- [Equipment Definition](#EquipmentDefinition) (constant)
  - 将一个装备实例与其赋予的能力相关联
  - 确定装备如何以及在何处附着到 Pawn

- [Equipment Instance](#EquipmentInstance)
  - 生成并应用于 Pawn 的一件装备
  - 具体的子类是 Equipment Definition 的一部分

- [Equipment Manager](#EquipmentManager) (Pawn Component)
  - 允许装备/卸下物品
  - 跟踪正在使用的装备

- [Pickup Definition](#PickupDefinition) (constant)
  - 定义世界中可以拾取的武器/物品
  
- [QuickBar Component](#QuickBarComponent) (Controller Component)
  - 玩家与 Equipment Manager 的唯一接口
  - 控制 Pawn 在任何给定时间内装备的装备是哪一件

## 1.2 相关的游戏玩法能力（Gameplay Abilities）

- [Equipment Ability](#EquipmentAbility)
  - 装备相关的游戏能力


<a id="EquipmentDefinition"></a>
## 1.3 Equipment Definition

This is a simple constant config.  There is no functionality associated with a `ULyraEquipmentDefinition`, it's just data.

An Equipment Definition consists of:

- Type of Equipment (subclass of `ULyraEquipmentInstance`)
- Array of Ability Sets to grant on equip
  - The abilities don't necessarily have to be based on `ULyraGameplayAbility_FromEquipment`
- Array of Actors to spawn on equip, including:
  - Which socket to attach each to
  - Attachment transform


<a id="EquipmentInstance"></a>
## 1.4 装备实例

`ULyraEquipmentInstance` handles spawning and destroying the equipment actors as needed for a given piece of equipment.

请注意，与物品实例不同，装备实例子类实际上是装备定义的一个必需部分。因此，它不仅是装备定义的实例，而且还是它的一个依赖项，这有点奇怪。

<a id="EquipmentManager"></a>
## 1.5 装备管理器

`ULyraEquipmentManagerComponent` 是一个 Pawn 组件。它必须附加到一个 Pawn 上。

装备管理器跟踪此 Pawn 当前可用的装备，并允许 Pawn 装备或卸下任何给定的装备。它使用 `FLyraEquipmentList` 来实现这一点。`FLyraEquipmentList` 的所有者是装备管理器本身。

它根据需要调用装备实例的 `OnEquipped()` 和 `OnUnequipped()`。

核心功能是在 [`EquipItem`](#EquipmentManagerComponent) 方法中实现的。


<a id="PickupDefinition"></a>
## 1.6 拾取定义

这有点奇怪，因为他们在相同的地方实现了基础的库存项目拾取和武器拾取。

无论如何，拾取定义定义了以下内容：
- 在拾取时生成的库存项目定义
- 显示网格
- 拾取冷却时间、效果等


<a id="QuickBarComponent"></a>
## 1.7 QuickBar Component

控制 Pawn 装备了哪个物品。
- 根据插槽数量限制库存中可用的可装备物品数量
- 通过 Equipment Manager 管理装备了哪个物品

请注意，在 Lyra 中，为了能够使用装备，QuickBar Component 是 必需的。尽管在 Lyra 的简单射击游戏概念中这样做效果很好，但我不能说我对这个设计选择非常喜欢。

Lyra 基于 QuickBar 的装备系统的关键是 `ULyraQuickBarComponent::SetActiveSlotIndex_Implementation`，这是 Lyra 中唯一导致装备被装备或卸下的代码片段。

`SetActiveSlotIndex_Implementation`` 调用 `UnequipItemInSlot`（卸下旧槽中的物品，如果有的话），然后是 `EquipItemInSlot`（在新槽中装备物品，如果有的话）。在这两种情况下，底层的工作由 [Equipment Manager](#EquipmentManager) 完成。

QuickBar Component 对于 AI Bot 几乎没有用途，但每个 Bot 都被强制拥有一个。在我的游戏中，Bot 的数量比玩家多得多，因此在每个 Bot 上放置仅对玩家有用的组件在我这种情况下效率相当低。移除这种依赖似乎相当容易，因此在我自己的装备系统实现中，这是我的计划。


<a id="EquipmentAbility"></a>
## 1.3 Equipment Ability

`ULyraGameplayAbility_FromEquipment`作为与装备相关的能力的基础能力类，提供的关键功能包括：

- Get **Associated Equipment**
  - Current Ability Spec `SourceObject` cast to Equipment Instance (`ULyraEquipmentInstance`)
- Get **Associated Item**
  - Associated Equipment Instigator cast to Item Instance (`ULyraInventoryItemInstance`)

The Associated Equipment `SourceObject` value is assigned by [`FLyraEquipmentList`::`AddEntry`](#EquipmentList_AddEntry) during the construction of the Equipment Instance.

Thus any Ability deriving from this base (or implementing similar functionality) can easily access the underlying Weapon Instance and its base Item Instance.

The Associated Equipment `Instigator` value is assigned by `ULyraQuickBarComponent`::`EquipItemInSlot` whenever a piece of equipment is chosen to be equipped by the Pawn to be the underlying Inventory Item Instance.


# 2 重点考虑的代码

特别是如果您打算自己实现类似的系统，以下是一些重要的代码，有助于支持装备/武器能力。

您应该考虑阅读这些代码，以了解它是如何在整个系统中提供支持的。

<a id="EquipmentManagerComponent"></a>
### `ULyraEquipmentManagerComponent`::`EquipItem`

```c++
ULyraEquipmentInstance* EquipItem (TSubclassOf<ULyraEquipmentDefinition> EquipmentDefinition);
```

每当应该装备新的装备时调用。根据装备定义生成一个装备实例。通过调用以下方法创建装备实例：

<a id="EquipmentList_AddEntry"></a>
### `FLyraEquipmentList`::`AddEntry`

```c++
ULyraEquipmentInstance* AddEntry (TSubclassOf<ULyraEquipmentDefinition> EquipmentDefinition);
```

- Creates a new Equipment Instance (`ULyraEquipmentInstance`)
  based on the Equipment Definition (`ULyraEquipmentDefinition`)
  - Equipment Instance Owner = The Equipment Manager's Owner Actor
- Adds the equipment's ability sets to the Equipment Manager Owner's ASC
  - Sets `SourceObject` for each ability to the Equipment Instance
- Spawns the equipment actors

<br/>
<hr/>
<div class="container">
    <p> 感谢原作者 X157 &copy; 的杰出贡献！Thanks to the original author X157&copy; for his outstanding contribution!<br/>
        原始文档地址：<a href="https://x157.github.io">source</a> | <a href="https://github.com/x157/x157.github.io/issues">issues</a>
    </p>
</div>