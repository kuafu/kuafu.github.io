---
title: "B_Hero_ShooterMannequin in Lyra's ShooterCore GameFeature Plugin"
description: "Description of Lyra's primary mannequin: B_Hero_ShooterMannequin"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Shooter Mannequin"
---

# 1 深入了解: Lyra's Shooter Mannequin

Lyra定义了一个名为“Shooter Mannequin”（B_Hero_ShooterMannequin）的基础角色，作为Lyra项目的玩家控制角色和AI控制角色。

本文档截至Lyra 5.1版本。

请注意，我在我的游戏中没有使用 B_Hero_ShooterMannequin。这将要求我将 ShooterCore 声明为一个GFP（可能指"Game Feature Plugin"）依赖项，而我并不希望这样做。相反，我有自己的基础角色类，是使用 B_Hero_ShooterMannequin 作为示例构建的。
因此，即使我没有使用它，了解Epic对这个类的处理仍然非常重要，这样我就可以选择与我的游戏相关的部分来构建我的角色。

Quick Links:

- [主要蓝图概览: `B_Hero_ShooterMannequin`](#ShooterMannequinOverview)
- [关键概念: Pawn Extension System](#PawnExtensionSystem)
  - An implementation of the `ModularGameplay` Plugin
- 深入研究特定蓝图:
  - [`B_Hero_ShooterMannequin`](#BP__B_Hero_ShooterMannequin)
  - [`B_Hero_Default`](#BP__B_Hero_Default)
  - [`B_Character_Default`](#BP__B_Character_Default)


--------------------------------------------------------------------------------

<a id="ShooterMannequinOverview"></a>
## 2 主要蓝图概览: `B_Hero_ShooterMannequin`
这是我们感兴趣的主要蓝图。然而，请注意，许多功能都是在基础类中实现的，包括基础蓝图和基础 C++。如果要完全理解 B_Hero_ShooterMannequin，您需要理解所有基础类和接口。  
<hr/>
This is the primary BP we are interested in.  However, note that A LOT of functionality is implemented
in the base classes, both the base BPs and the base C++.  You need to understand ALL the base classes
and interfaces if you are to fully understand `B_Hero_ShooterMannequin`.

##### `B_Hero_ShooterMannequin` BP Inheritance 继承结构

- BP Base `B_Hero_Default`
  - BP Base `Character_Default`
    - C++ Base `ALyraCharacter`

##### `ALyraCharacter` C++ Inheritance 继承结构

- C++ Interface `IAbilitySystemInterface`
- C++ Interface `IGameplayCueInterface`
- C++ Interface `IGameplayTagAssetInterface`
- C++ Interface `ILyraTeamAgentInterface`
  - C++ Interface `IGenericTeamAgentInterface`
- C++ Base `AModularCharacter`
  - C++ Base `ACharacter`
    - C++ Base `APawn`
      - C++ Interface `INavAgentInterface`
      - C++ Base `AActor`
        - C++ Base `UObject`


### 2.1 Controller挂接的 C++ 组件(Controller-Injected C++ Component): `B_PickRandomCharacter`
除了基础类之外，Lyra 在运行时还向每个 AController 注入了一个 B_PickRandomCharacter 组件。例如，可以查看 B_ShooterGame_Elimination 体验定义。

因此，即使在代码中你看不到它明确地附加到控制器或 Pawn 上，但在运行时，该组件确实存在于默认 Pawn 控制器上。

该组件基于 C++ 的 ULyraControllerComponent_CharacterParts。

这个控制器组件与 Pawn 版本的组件（ULyraPawnComponent_CharacterParts）配合使用。如果你正在处理由不同部分组成的角色，就像 Lyra 一样，你需要阅读这两个组件的基础 C++ 代码。它们是同一系统的两个部分。

在控制器的 BeginPlay 中，控制器组件会随机选择一个身体模型（Manny 或 Quinn）并分配给 Pawn。这就是使 Pawn 在外观和动画风格上随机呈现男性或女性的原因。 

[简单来说似乎就是在APlayerController上挂Component]  

<hr/>
In addition to the base classes, Lyra also injects a `B_PickRandomCharacter`
component into every `AController` at runtime.
For example see the `B_ShooterGame_Elimination` Experience Definition.

Thus, even though you won't see this explicitly attached to the controller or pawn in code,
at runtime this component WILL exist on the default Pawn controller.

This component is based on the C++ `ULyraControllerComponent_CharacterParts`.

This Controller Component acts in conjunction with the Pawn version of this
component (`ULyraPawnComponent_CharacterParts`).  If you are dealing with characters
comprised of different parts, like Lyra, you will want to read the underlying C++
for both the controller AND pawn versions of this component.  They're two parts of
the same system.

On Controller `BeginPlay`, a random body mesh is chosen (either Manny or Quinn)
by the controller component and assigned to the Pawn.
This is what makes the pawn randomly masculine or feminine
in physical appearance and animation style.


--------------------------------------------------------------------------------

<a id="PawnExtensionSystem"></a>
## 3 关键概念: Pawn Extension System
Lyra角色在运行时以模块化方式构建。因此，没有明确定义的初始化顺序。该角色可能有许多可选组件，它们以不同的方式相互依赖，并且这些依赖关系随时间变化。

作为开发者，你无法知道在运行时会注入哪些组件，然而你仍然必须允许它们正确初始化，每个组件都有它们自己的依赖项，在运行时以任意的随机顺序发生。


Lyra通过以 `ULyraPawnExtensionComponent` 的形式在每个 ALyraCharacter 中实现 [ `ModularGameplay Plugin`](/UE5/ModularGameplay/) 插件从而来解决这个问题。


<a id="PawnExtensionComponent"></a>
### 3.1 Lyra Pawn Extension Component

`ULyraPawnExtensionComponent` 是在Pawn上实现[`ModularGameplay` Plugin](/UE5/ModularGameplay/)' 的 [`IGameFrameworkInitStateInterface`](/UE5/ModularGameplay/#GameFrameworkInitStateInterface)功能的组件。

将这个组件分配给一个Actor允许该Actor上的其他组件共享Init State的更新，以满足运行时的依赖关系。如果/当它们有运行时依赖需要满足时，这些组件可以连接到由这个组件广播的 Actor Init State Changed 事件。

请注意，尽管这是一个组件，但在 ALyraCharacter 中有一些深度集成，例如从 ALyraCharacter 的 PossessedBy 调用 ULyraPawnExtensionComponent🡒HandleControllerChanged。如果你想深入了解这个组件正在做什么，请确保阅读 ALyraCharacter。

<hr/>
`ULyraPawnExtensionComponent` is the implementation of the
[`ModularGameplay` Plugin](/UE5/ModularGameplay/)'s
[`IGameFrameworkInitStateInterface`](/UE5/ModularGameplay/#GameFrameworkInitStateInterface)
functionality on a Pawn.

Giving this component to an Actor allows the other components on that actor
to share Init State updates with each other to satisfy runtime dependencies.
The components can hook into `Actor Init State Changed` events broadcast by this component
if/when they have runtime dependencies to satisfy.

Note that, though this is a component, there are some deep integrations in `ALyraCharacter`
for things like, for example, calling `ULyraPawnExtensionComponent`🡒`HandleControllerChanged`
from `ALyraCharacter`🡒`PossessedBy`.  If you want a deep understanding of what
this component is doing, make sure you read through `ALyraCharacter` as well.

##### `OnRegister`
- Register self with `ModularGameplay` plugin's `UGameFrameworkComponentManager`
  - Pawn Extension Component implements feature name `PawnExtension`

##### `BeginPlay`
- Bind `Actor Init State Changed` event to `ULyraPawnExtensionComponent`🡒`OnActorInitStateChanged`

##### Pawn Extension Component 🡒 `OnActorInitStateChanged`

- Every time a feature (**NOT** including the `PawnExtension` feature itself) changes state:
  - If new state == `DataAvailable`:
    - Run `CheckDefaultInitialization()` on all feature components

##### Pawn Extension Component :: `CheckDefaultInitialization`

This tells every component on the owner Actor that supports the
[`IGameFrameworkInitStateInterface`](/UE5/ModularGameplay/#GameFrameworkInitStateInterface)
to try to initialize.

This gets spammed A LOT during initialization.  This is a trigger that keeps getting
executed until all components have initialized successfully or finally fail to initialize.

##### Debugging Tip

The interesting logs related to the Pawn Extension System are made by the
`ModularGameplay` plugin's `IGameFrameworkInitStateInterface`.

It logs to `LogModularGameplay` with a lot of `Verbose` log messages.  Make sure you turn on
`Verbose` viewing for that log if you are trying to understand the flow of code via logs.


--------------------------------------------------------------------------------

<a id="BP__B_Hero_ShooterMannequin"></a>
# Blueprint: `B_Hero_ShooterMannequin`

## 4 Components:

### » AimAssistTarget (`UAimAssistTargetComponent` via `ShooterCore` GFP)

- This component helps other pawns shoot at this one more accurately

### » PawnCosmeticsComponent (`ULyraPawnComponent_CharacterParts`)

- Broadcasts `On Character Parts Changed` Events
- BP `B_MannequinPawnCosmetics` defines 2 Body Meshes:

| Mesh Name | Animation Style | Body Style |
|-----------|-----------------|------------|
| Manny     | `Masculine`     | `Medium`   |
| Quinn     | `Feminine`      | `Medium`   |

The actual Gameplay Tags defined are `Cosmetic.AnimationStyle.*` and `Cosmetic.BodyStyle.*`

Anywhere that you want to know if you have a masculine or feminine character, you can simply
check the Pawn's Tags to, for example, animate a feminine character differently than a masculine one.


## 5 Event Graph:

### `BeginPlay`
- (Async) Listen for Team Events:
  - Update cosmetics each time a different team is assigned
- Hide Actor in game
- (Async) Wait for `ULyraPawnExtensionComponent` State Change to `InitState.GameplayReady`, then:
  - Unhide Actor on next tick

### `Possessed`
- (Async) Wait for Experience Ready
  - (Async) Wait for Inventory Ready
    - Add Initial Inventory

### `ULyraPawnComponent_CharacterParts`.`OnCharacterPartsChanged`
- If pawn is on a Team:
  - Update team colors, assets, etc

### `ULyraHealthComponent`.`OnHealthChanged`
- On Server only:
  - Report Damage events to `AISense_Damage`

### Enhanced Input Action Triggers:
- Quick Slot 1
- Quick Slot 2
- Quick Slot 3
- Quick Slot +
- Quick Slot -

### `OnDeathFinished`
- Clear Inventory

### `OnReset`
- Clear Inventory

### `Set Emote Audio Component` from BI Emote Sound Interface
Not sure what this is or what this does.  Seems to be part of the emote system.  Requires investigation.


--------------------------------------------------------------------------------

<a id="BP__B_Hero_Default"></a>
# 6 Blueprint: `B_Hero_Default`

## 6.1 Components:

<a id="LyraHeroComponent"></a>
### » LyraHero (`ULyraHeroComponent`)
- Implements Player Input & Camera handling
- Implements `IGameFrameworkInitStateInterface`
- `OnRegister`
  - Register self with `ModularGameplay` plugin's `UGameFrameworkComponentManager`
    - Lyra Hero Component implements feature name `Hero`
- `BeginPlay`
  - Bind `Actor Init State Changed` to `ULyraHeroComponent`🡒`OnActorInitStateChanged`
- **Bug:** Intermittently binds player inputs twice
  - Does not seem to adversely affect Lyra, but you should fix this in your implementation
  - Intermittent ensure failures at `ULyraHeroComponent`::`InitializePlayerInput` near `ensure(!bReadyToBindInputs)`
    - There was a similar bug in 5.0

##### Lyra Hero Component 🡒 `OnActorInitStateChanged`

- When the `PawnExtension` feature state changes to `DataInitialized`:
  - Run `CheckDefaultInitialization()` on self

##### Lyra Hero Component :: `CheckDefaultInitialization`

- Tries to advance the init state from its current point to `InitState_GameplayReady`
- **NOTE:** Code is duplicated here from `ULyraPawnExtensionComponent`,
  including the definition of the Init State Chain, which is suboptimal.
  Expect changes.

### » AIPerceptionStimuliSource (`UAIPerceptionStimuliSourceComponent`)
- Auto-register these senses:
  - `AISense_Sight`
  - `AISense_Hearing`

### » LyraContextEffect (`ULyraContextEffectComponent`)
- Register Default Context Effects: `CFX_DefaultSkin`
  - Defines effects:
    - `AnimEffect.Footstep.Walk`: Concrete, Glass, Default
    - `AnimEffect.Footstep.Land`:  Concrete, Glass, Default

## 6.2 Event Graph:

### `ULyraHealthComponent`.`OnDeathStarted`
- Play random death animation montage
- Unregister from AI Sense
  - **Bug:** Only unregisters from `AISense_Sight`, should also unregister from `AISense_Hearing`
    - Impact of this bug is zero if you destroy the pawn after it dies, as all senses are unregistered on destroy
- Delay `0.1`-`0.6` seconds » Ragdoll » Death


### `ULyraContextEffectComponent`.`AnimMotionEffect`
- Uses an external `B_FootStep` Actor to implement the `AninMotionEffect` event


## 6.3 Interesting Variables:

- `Death Montages` = array of Anim Montages to play on character death


--------------------------------------------------------------------------------

<a id="BP__B_Character_Default"></a>
# Blueprint: `B_Character_Default`

This is a very simple BP.  It inherits from `ALyraCharacter` and:

- Set Capsule Component Navigation `Area Class Override` = `NavArea_Obstacle`

Essentially this is telling the navigation system that AI need to path AROUND
a `B_Character_Default` character rather than through it.
