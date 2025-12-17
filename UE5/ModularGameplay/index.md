---
title: "Modular Gameplay | Unreal Engine 5"
description: "Overview of UE5's ModularGameplay Plugin"
breadcrumb_path: "UE5"
breadcrumb_name: "Modular Gameplay"
---

# `Modular Gameplay` Plugin Overview

模块化游戏玩法（`Modular Gameplay`）插件指的是：其基类实现了“模块化游戏玩法”模式的一类插件。该模式允许在运行时把组件（Component）注入到 Actor 中，从而支持基于插件的玩法拼装。这套机制也为 [`GameFeature` Plugins](/UE5/GameFeatures/) 提供了基础支撑。

`ModularGameplayActors` 插件是 `Modular Gameplay` 的一个具体实现，也是 Lyra 模块化架构的基础之一；它位于 Lyra 的项目插件中。

模块源码路径：
UnrealEngine\Engine\Plugins\Runtime\ModularGameplay\Source\ModularGameplay

<a id="GameFrameworkComponentManager"></a>
## Game Framework Component Manager

`UGameFrameworkComponentManager` « `UGameInstanceSubsystem`

`GameFrameworkComponentManager` 是“模块化 Actor 组件管理器”：它负责在 Actor 出现（注册）与消失（反注册）时，按规则为其添加/移除组件。

这个 `GameInstance` 级别的 Subsystem，正是 Lyra 能够在运行时向 Actor 注入组件的关键机制。

Actor 必须显式“选择加入”（opt-in）这套行为，系统才会对它执行组件注入。
Epic 随 `LyraStarterGame` 发布了 `ModularGameplayActors` 插件，提供了一组便捷的基类来自动化完成“选择加入”的流程；但你的项目并不强制一定要继承这些基类。
如果你愿意，也可以在自己的类中复刻同样的接入过程。

例如可以参考 `LyraStarterGame` 中的这些代码：

- `Plugins/ModularGameplayActors/Source/ModularGameplayActors/Public/ModularCharacter.h`
- `Plugins/ModularGameplayActors/Source/ModularGameplayActors/Public/ModularPlayerController.h`
- `Plugins/ModularGameplayActors/Source/ModularGameplayActors/Public/ModularPlayerState.h`
- ... etc ...


### Debugging Tip

在控制台执行 `Log LogModularGameplay Verbose`，可以开启该模块的 Verbose 级别日志输出。

在控制台执行 `ModularGameplay.DumpGameFrameworkComponentManagers`，可以输出调试信息，用于理解“哪些组件被注入到了哪些 Actor 上”。


<a id="GameFrameworkInitStateInterface"></a>
## Game Framework Init State Interface

任何需要“按依赖关系”进行初始化的组件（Component），都应实现 `IGameFrameworkInitStateInterface`：当一个组件依赖于其它组件，而这些组件又各自存在分阶段的初始化步骤时，就需要用它来协调初始化顺序与状态推进。

TL;DR：Game Framework 里的组件会反复尝试推进 `Init()`（可以理解为“持续重试/轮询式初始化”），直到所有依赖都成功初始化完成，或最终判定初始化失败为止。


## Implementation in Lyra 5.7: Pawn Extension

要理解 `Modular Gameplay` 插件在项目中的落地方式，可以以 Lyra 为例。Lyra 的实现思路是：

- 定义驱动 `IGameFrameworkInitStateInterface` 的 `ULyraPawnExtensionComponent`
  - 通过基类 `ALyraCharacter`，把该组件添加到游戏中的每个 Character 上
- 在需要参与依赖初始化的其它组件中，实现 `IGameFrameworkInitStateInterface`

更多信息参见：

- [Lyra Pawn Extension System](/UE5/LyraStarterGame/ShooterMannequin#PawnExtensionSystem)
- [Lyra Pawn Extension Component](/UE5/LyraStarterGame/ShooterMannequin#PawnExtensionComponent)

上面的链接会帮助你理解：当 Lyra 的 ShooterGame Mannequin 上存在多个相互依赖的组件时，它们如何按合适的顺序完成初始化。


<br/>
<hr/>
<div class="container">
    <p> 感谢原作者 X157 &copy; 的杰出贡献！<br/>
        原始文档地址：<a href="https://x157.github.io">source</a> | <a href="https://github.com/x157/x157.github.io/issues">issues</a>
    </p>
</div>