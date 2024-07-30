---
title: "LyraStarterGame Weapon System"
description: "Overview of the Weapon system in UE5 LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Weapon System"
---

# 1. Lyra 武器系统
Lyra武器是一种基于[Lyra装备系统](/UE5/LyraStarterGame/Equipment/)的特殊装备 ，而Lyra装备系统本身又基于[Lyra库存(物品)系统](/UE5/LyraStarterGame/Inventory/)。 
从而有这种层次关系：'武器 --> 装备 --> 库存'。武器属于装备的一种，装备属于库存的一种特殊形式。

## 1.1 武器概念
- [武器实例](#WeaponInstance)
  - 继承自装备实例 [Equipment Instance](/UE5/LyraStarterGame/Equipment/#EquipmentInstance)
  - 添加装备/未装备的动画集

- [远程武器实例](#RangedWeaponInstance)
  - Derived from [Weapon Instance](#WeaponInstance)
  - Adds logic RE shooting a projectile at range, ammunition capacity and use, etc

- [武器状态组件](#WeaponStateComponent) (Controller Component)
  - 管理装备的武器Tick和玩家反馈（命中结果可视化）

- [武器调试设置](#WeaponDebugSettings)
  - Developer debug helper

- [武器生成器 Weapon Spawner](#WeaponSpawner) (Actor)
  - Spawn Weapons at dedicated spawning pads in the world


## 1.2 相关 Gameplay Abilities
- [Melee Attack Ability](#MeleeAttackAbility)
  - 用于所有近战攻击，无论武器类型如何
- [Ranged Weapon Base Ability](#RangedWeaponBaseAbility)
  - 所有远程武器的基础能力


<a id="WeaponInstance"></a>
## 1.3 武器实例(Weapon Instance)
武器实例 (`ULyraWeaponInstance`) 是一个 [装备实例](/UE5/LyraStarterGame/Equipment/#EquipmentInstance)，它还具有与之关联的装备和未装备动画集。它还会跟踪玩家上次与其交互的时间。大部分实现都在 BP `B_WeaponInstance_Base` 中，所有其他 Lyra 武器实例均从中派生：
- `B_WeaponInstance_Pistol`
- `B_WeaponInstance_Rifle`
- `B_WeaponInstance_Shotgun`
- `B_WeaponInstance_NetShooter` (原型)

武器实例有一个 `Tick()` 方法，**如果/当** Pawn 装备武器时，该方法会在每个 tick 执行。这个Tick是由 Pawn Controller 的 [武器状态组件](#WeaponStateComponent) 管理的。


<a id="RangedWeaponInstance"></a>
## 1.4 远程武器实例
远程武器实例源自武器实例，并实现 `ILyraAbilitySourceInterface`。它添加了子弹、射击精度和散布等概念。


<a id="WeaponStateComponent"></a>
## 1.5 武器状态组件
`ULyraWeaponStateComponent` 位于 Pawn 控制器上。此组件主要功能包括：
- 负责使 Pawn 当前装备的武器 `Tick()`
- 瞄准期间：
    - 跟踪本地玩家的武器“命中标记”
        - 例如，这样您就可以看到子弹确实击中了目标（如果它们确实击中了某物）
- 当服务器处理 TargetData 时：
    - 记住实际导致有效命中的“命中标记”
      - 将这些提供给 `SHitMarkerConfirmationWidget` 以在玩家的屏幕上绘制命中标记


<a id="WeaponDebugSettings"></a>
## 1.6 武器调试设置
`ULyraWeaponDebugSettings`是 UE5 新实现的功能，`UDeveloperSettingsBackedByCVars`。

如果您想在游戏中拥有类似的功能，请务必阅读此类，我建议您这样做，因为这使游戏调试变得更加容易。Lyra 支持编译武器调试的选项，有利于生产。在开发远程武器时，您绝对应该打开这些调试功能，除非您想不必要地浪费自己的时间。


<a id="WeaponSpawner"></a>
## 1.7 武器生成器(WeaponSpawner)
这是一个具有固定位置的垫板，可根据您为其配置的武器定义生成武器。您可以设置冷却时间、显示将被拾取的武器网格等。

此功能由C++类实现，实际使用时需要在实现对应的蓝图，将武器赋予 pawn 的核心功能**必须**在蓝图中实现。有 2 个 BP 实现：

- `B_WeaponSpawner`
    - 提供武器和生命拾取的 ShooterCore 垫板
- `B_AbilitySpawner`
    - ShooterCore 接近 HOT/DOT 垫子
    - 基于 `B_WeaponSpawner`，但实际上不授予武器



<a id="MeleeAttackAbility"></a>
## 1.8  近战攻击 Ability
`GA_Melee`是近战攻击能力，继承自 `GA_AbilityWithWidget`，其本身基于 `ULyraGameplayAbility`。它的实现使得无论装备的武器类型如何都可以执行，只要该武器源自`B_WeaponInstance_Base` （BP约束）。

请注意，此Ability**不是**继承自基础装备Ability ( `ULyraGameplayAbility_FromEquipment`)。虽然这是有道理的，因为近战不一定需要装备（Pawn 有拳头、脚、头等），但这也意味着在当前的实现中，没有办法让武士刀近战超过拳头。这似乎是一个重大的实施缺陷。如果你想要有趣的近战游戏，你绝对应该改变这一点。

所以，GA_Melee 近战非武器近战，而是相当“肉搏”的的能力，例如用刀或枪去砸东西。

GA_Melee近战攻击时的逻辑：
- 播放近战攻击动画蒙太奇*（每个武器均可配置）*
- 如果由授权：
    - 如果所有这些条件都为真：
        - 如果攻击者前方的 Pawn 被击中*（BP 限制为最多 1 次击中）*
        - 如果被击中的 Pawn 与攻击者属于不同的队伍*（BP 约束）*
        - 如果被击中的 Pawn 不在墙或其他障碍物后面
    - 然后：
        - 根据近战攻击的“强度”参数在攻击者的向前方向应用附加根运动力*（无论武器如何都是常数）*
        - 添加游戏效果以击中 Pawn：`GE_Damage_Melee`*（无论武器如何都是常数）*
        - 对攻击者执行 GameplayCue：`GameplayCue.Weapon.Melee.Hit`
        - 在世界冲击位置播放近战冲击声音


<a id="RangedWeaponBaseAbility"></a>
## 1.9 远程武器 Ability
`ULyraGameplayAbility_RangedWeapon` 继承自自装备系统的[装备能力](/UE5/LyraStarterGame/Equipment/#EquipmentAbility)(`ULyraGameplayAbility_FromEquipment`)，使其能够轻松访问负责授予玩家能力的特定武器，该武器将在能力激活时装备。这是所有 Lyra 远程武器的基类，由以下类实现：
- `GA_Weapon_Fire`
    - `GA_Weapon_Fire_Pistol`
    - `GA_Weapon_Fire_Rifle_Auto`
    - `GA_Weapon_Fire_Shotgun`
    - `GA_WeaponNetShooter`（原型）

Lyra 游戏能力的标准似乎是如此，C++ 中实现的内容很少，大多数实现都在 BP 中，在本例中为 `GA_Weapon_Fire`，它是远程武器的基础 BP。如果您对 Lyra 中武器的工作原理感兴趣，请务必研究 `GA_Weapon_Fire` 的事件图，了解其工作原理。

激活能力时（开火）的逻辑表现：
- 如果是本地控制的 pawn：
    - 根据武器瞄准的位置生成 TargetData
        - 参见 `ULyraGameplayAbility_RangedWeapon`::`PerformLocalTargeting`
    - 如果是远程客户端：
        - 将 TargetData RPC 发送到服务器
- 播放武器开火动画
- 向武器所有者发送游戏提示：`GameplayCue.Weapon.Rifle.Fire`
- 向每个目标命中发送游戏提示：`GameplayCue.Weapon.Rifle.Impact`
- 如果有授权：
    - 在每个目标命中处生成物理场 actor*（如果武器配置了物理场影响）*
    - 为每个目标命中添加游戏效果
        - 效果因武器而异，例如：`GE_Damage_Pistol`

此外，远程武器将监听“武器射击失败”游戏事件(`Ability.PlayMontageOnActivateFail.Message`)，并播放动画蒙太奇，帮助玩家直观地了解失败的能力激活。该游戏消息由基础`ULyraGameplayAbility`::`NativeOnAbilityFailedToActivate`广播。

2024/7/30整理

<br/>
<hr/>
<div class="container">
    <p> 感谢原作者 X157 &copy; 的杰出贡献！Thanks to the original author X157&copy; for his outstanding contribution!<br/>
        原始文档地址：<a href="https://x157.github.io">source</a> | <a href="https://github.com/x157/x157.github.io/issues">issues</a>
    </p>
</div>