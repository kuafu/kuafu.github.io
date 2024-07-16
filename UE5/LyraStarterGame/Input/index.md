---
title: "LyraStarterGame Input"
description: "Discussion of User Input handling in LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Input"
---

# 1 Lyra 输入概述

Lyra 将不同的UE5系统和插件组合在一起，以协调一个一致的输入策略。

有关5分钟的高层次概念概述，请查YouTube视频：[UE5 Lyra Input Overview](https://youtu.be/mEIQDcW65qs)


<a id='KeyConcepts'></a>
## 1.1 关键概念

- [Common UI](/UE5/CommonUI/) 通过 [Common UI Action Router](/UE5/CommonUI/ActionRouter)管理游戏过程中的输入模式变化

- [Enhanced Input](/UE5/EnhancedInput/) 接收所有直接进入游戏的输入, filtered by active [Input Mapping Contexts](/UE5/EnhancedInput/InputMappingContext)
  
- [UI Manager Subsystem](/UE5/LyraStarterGame/Input/UIManagerSubsystem) 由 [Lyra UI Policy](/UE5/LyraStarterGame/Input/UIPolicy)管理
  - 定义 UI 层 `UI.Layer.*` 优先用于输入捕获

- [Lyra HUD Layout](/UE5/LyraStarterGame/Input/HUDLayout) 实现 `UI.Layer.Game` 游戏HUD
- 默认情况下, 游戏功能操作（Game Feature Actions）--- 例如 [`LAS_ShooterGame_StandardHUD`](./LAS_ShooterGame_StandardHUD) ---定义:
  - 使用哪个 HUD 布局类
  - 为每个 UI 扩展点(UI Extension Point)实例化哪些可激活小部件类(Activatable Widget classes)

- 您可以在游戏过程中管理其他 HUD 布局和/或小部件的添加/删除
- 您可以通过从 [deriving from `ULyraHeroComponent`](#LyraHeroComponent) 派生来覆盖本机玩家输入处理


<a id='InputHandlingOverview'></a>
## 1.2 输入处理概述

Lyra 使用 [通用 UI](/UE5/CommonUI/) 和 [增强输入](/UE5/EnhancedInput/) 来管理玩家输入。请熟悉两者。

这些 UE5 插件通过 [Lyra UI 策略](/UE5/LyraStarterGame/Input/UIPolicy) 集成，该策略将 HUD 定义为由 [可激活小部件](/UE5/CommonUI/ActivatableWidget) 的优先级层组成。

例如，`Escape` 键（“后退”按钮）可激活游戏菜单小部件，当菜单打开时，它会暂停玩家游戏输入。

[通用 UI](/UE5/CommonUI/)控制输入是否、何时以及如何进入游戏。如果/当您想在游戏中明确更改输入模式时，您必须使用 [通用 UI 操作路由器](/UE5/CommonUI/ActionRouter) 来执行此操作。

当 [可激活小部件](/UE5/CommonUI/ActivatableWidget) 激活和停用时，它们可以选择更改输入模式和/或将自身聚焦于输入以支持 MKB、游戏手柄、VR 控制器等。所有设置都可通过输入设备和平台自定义。特别的，它们应该就“获取所需输入配置”的值达成一致，希望通过共享实现。

当没有可激活小部件修改输入模式时，输入将通过 [增强输入](/UE5/EnhancedInput/) 流向游戏本身，由游戏时间给定点的任何活动 [输入映射上下文](/UE5/EnhancedInput/InputMappingContext) 触发。


<a id='IMC'></a>
### 输入上下文映射（Input Mapping Contexts (IMC)）

在游戏过程中，输入映射上下文[Input Mapping Context](/UE5/EnhancedInput/InputMappingContext)）管理允许您根据上下文激活或停用任何给定的 IMC。例如，驾驶车辆或从车辆中弹出可能会改变与步行时的活动 IMC。

Lyra 使用游戏特性操作来初始化默认 IMC，并且您可以添加自己的 IMC 切换逻辑，以在游戏过程中动态更改输入。

<a id='LyraHeroComponent'></a>
## 1.3 Lyra Hero Component 管理玩家输入
- 如果您想要自定义输入处理，您**必须**从`ULyraHeroComponent`派生

The Lyra Hero Component activates the Native & Ability Input Actions for the Player Pawn.
Lyra Hero 组件为玩家 Pawn 激活本机和能力的输入操作，见`ULyraHeroComponent::InitializePlayerInput`。

- 为了让 pawn 接收玩家输入，它**必须**有一个 `ULyraHeroComponent` 组件
  - Lyra 需要 `ULyraHeroComponent` 作为基类，包括但不限于：
    - `ULyraGameplayAbility`
      - 管理能力相机模式
      - 还将 Hero 组件公开给可能出于其他原因使用它的 BP 
    - 与输入管理有关的游戏功能操作：
      - `GameFeatureAction_AddInputBinding`
      - `GameFeatureAction_AddInputConfig`
      - `GameFeatureAction_AddInputContextMapping`

- `ULyraHeroComponent` 与 `ULyraPawnExtensionComponent` 配合使用以激活 pawn 上的输入
  - 因此，pawn 还必须有一个 `ULyraPawnExtensionComponent` 并完全支持 `IGameFrameworkInitStateInterface`
  - 参见`ULyraHeroComponent`::`InitializePlayerInput` 了解实现细节
    - 在转换到 `InitState.DataInitialized` 时，在 pawn 初始化过程中调用此方法
  - 这要求玩家使用 `ULyraInputComponent` 进行输入，该输入在 [项目设置](#ProjectSettings) 中配置

<a id='References'></a>
# References

- [官方 Epic Lyra 输入文档](https://docs.unrealengine.com/5.1/en-US/lyra-input-settings-in-unreal-engine/)
- [ULyraSettingsLocal](/UE5/LyraStarterGame/ULyraSettingsLocal)



<br/>
<hr/>
<div class="container">
    <p> 感谢原作者 X157 &copy; 的杰出贡献！Thanks to the original author X157&copy; for his outstanding contribution!<br/>
        原始文档地址：<a href="https://x157.github.io">source</a> | <a href="https://github.com/x157/x157.github.io/issues">issues</a>
    </p>
</div>