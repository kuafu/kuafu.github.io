---
title: "Lyra Experience"
description: "A look at the Lyra Experience system. What is it? How does it work?"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Experience"
---

# 1 Lyra Experience

Lyra Experience 是一种定制、可配置的游戏模式/状态。在Lyra项目中，每个关卡都可以通过自定义[World Settings](#LyraWorldSettings)以指定要加载的该关卡的默认Experience。

[加载 Lyra Experience](#ExperienceLoadingProcedure)是一个异步过程。内容预期放置在游戏特性插件（GFPs）中，这些插件只有在实际需要时才会被动态加载。您的项目预期使用“On Experience Loaded”事件来启动游戏玩法，该事件在异步加载完成时触发。

Lyra Experience 的定义配置了默认的 Lyra Pawn 数据和要加载并执行的体验动作集（运行时组件注入、HUD 小部件扩展等）。

需要注意的是，在 Lyra 中，“BeginPlay”具有不同的含义。在其他游戏中，“BeginPlay”可能字面上意味着“游戏已经开始”，但在 Lyra 中，它只表示关卡已经加载并且（可能相当缓慢的）异步加载过程已经开始。在 Lyra 中，游戏实际上不应该开始进行直到“On Experience Loaded”事件触发，这通常发生在“BeginPlay”之后的某个时间点。您可以通过设置一些控制台变量来测试延迟的体验加载，例如模拟计算机性能较差或网络延迟。这些信息可以在 LyraStarterGame 的官方文档中找到。

![ULyraExperienceDefinition](./screenshots/ULyraExperienceDefinition.png)


<hr/>
[Loading a Lyra Experience](#ExperienceLoadingProcedure) is asynchronous.  Content is expected to be placed into Game Feature Plugins([GFPs](/UE5/GameFeatures/)) which are dynamically loaded only when actually needed. Your project is expected to use the [On Experience Loaded](#OnExperienceLoaded) event to initiate gameplay, it fires when the async loading completes.

The [Experience Definition](#LyraExperienceDefinition) configures the default [Lyra Pawn Data](#LyraPawnData) and a list of [Experience Action Sets](#LyraExperienceActionSet) to load and execute.
*(Runtime component injection, HUD widget extension, etc.)*

Note that `BeginPlay` has a different meaning in Lyra.  Whereas in other games Begin Play might literally mean in some cases "game play has begun", in Lyra it just means the Level has been loaded and the (perhaps quite slow) async loading process has begun. In Lyra, the game shouldn't actually start playing until the [On Experience Loaded](#OnExperienceLoaded) event fires, sometime **well after** `BeginPlay`. You can test delayed Experience loading (e.g. to simulate slow computers/networks) by setting some [console variables](#CVars).


## 1.1 定义Experience的资源
`Primary Data Assets Defining an Experience`

  - [Lyra Experience Definition](#LyraExperienceDefinition)
  - [Lyra Experience Action Set](#LyraExperienceActionSet)
  - [Lyra Pawn Data](#LyraPawnData)
  - [Lyra Input Config](#LyraInputConfig)
  - [Game Feature Action](#GameFeatureAction)

## 1.2  虚幻设置

  - [Lyra Game Mode](#LyraGameMode)
  - [Lyra Game State](#LyraGameState)
    - [Lyra Experience Manager Component](#LyraExperienceManagerComponent)
      - [Experience Loading Procedure](#ExperienceLoadingProcedure)
- [Lyra World Settings](#LyraWorldSettings)
- [Lyra Asset Manager](#LyraAssetManager)
- [Lyra Experience Manager](#LyraExperienceManager) Subsystem *(only relevant to PIE)*
- [Console Variables](#CVars)

## 1.3 如何初始化Experience的Gameplay
How to Initiate Gameplay in a Lyra Experience

- [Event: `OnExperienceLoaded`](#OnExperienceLoaded)
  - [Usage Examples](#OnExperienceLoadedExamples)
    - [Example BP Hook Code](#ExampleHookBP)
    - [Example C++ Hook Code](#ExampleHookCPP)
- [Loading a Default Experience](#LoadingADefaultExperience)
  - Example: [Lyra Frontend State Component](#LyraFrontendStateComponent)


### 1.4 调试Tips

Execute these console commands to enable Verbose logging for these modules:

- `Log LogLyraExperience Verbose`
- `Log LogGameFeatures Verbose`

Execute `ModularGameplay.DumpGameFrameworkComponentManagers` in the console to dump
debugging info to help understand which components are being injected into which actors.

See [Console Variables](#CVars), they are helpful for debugging.


<a id='PrimaryDataAssets'></a>

# 2 主要数据资产
`Primary Data Assets`

This section describes the major Primary Data Assets that are required to define
a Lyra Experience.


<a id='LyraExperienceDefinition'></a>

## 2.1 Lyra Experience Definition

« Primary Data Asset »
这是一个 Const 数据资产。它明确的地定义了一个Experience。

- Default [Lyra Pawn Data](#LyraPawnData)
- List of Instanced [Game Feature Actions](#GameFeatureAction)
- List of [Lyra Experience Action Sets](#LyraExperienceActionSet)
- List of Game Feature Plugin ([GFP](/UE5/GameFeatures/)) dependencies


<a id='LyraExperienceActionSet'></a>
## 2.2 Lyra Experience Action Set

« Primary Data Asset »

- Array of [Game Feature Actions](#GameFeatureAction)
- Array of Game Feature Plugin ([GFP](/UE5/GameFeatures/)) dependencies used by this Action Set


<a id='LyraPawnData'></a>
## 2.3 Lyra Pawn Data

« Primary Data Asset »

- Pawn (Subclass)
- Lyra Ability Sets (Array)
- Lyra Ability Tag Relationship Mapping
- [Lyra Input Config](#LyraInputConfig)
- Lyra Camera Mode (Subclass)


<a id='LyraInputConfig'></a>
## 2.4 Lyra Input Config

« Const Data Asset »

- Native Lyra Input Actions (Array)
- Ability Lyra Input Actions (Array)


<a id='GameFeatureAction'></a>
## 2.5 Game Feature Action

An Action to be taken when a Game Feature is activated.
Part of the experimental `GameFeatures` plugin.

An Instanced Game Feature Action handles
[Game Features](/UE5/GameFeatures/)
asset loading and unloading.  Events include:

- Registering
- Unregistering
- Loading
- Activating
- Deactivating

### CUGameFeatureAction	继承关系
 - CUApplyFrontendPerfSettingsAction	
 - CUGameFeatureAction_AddGameplayCuePath	
 - CUGameFeatureAction_WorldActionBase	
    - CUGameFeatureAction_AddAbilities	
    - CUGameFeatureAction_AddInputBinding	
    - CUGameFeatureAction_AddInputContextMapping
    - CUGameFeatureAction_AddWidgets
    - CUGameFeatureAction_SplitscreenConfig

<a id='EngineSetup'></a>
# 3 设置UE的Lyra Experience

This section describes how Lyra sets up Unreal Engine to support a Lyra Experience.


<a id='LyraGameMode'></a>
## 3.1 Lyra Game Mode

Lyra Game Mode is the required base Game Mode providing Lyra Experience support.

- Uses a [Lyra Game State](#LyraGameState)
- In `Init Game`:
  - On Server, call `ServerSetCurrentExperience` via `OnMatchAssignmentGiven`
- Adds support for loading an Experience on PIE start by simulating a match assignment
- Delay initial player spawn until `OnExperienceLoaded`
  - Lots of other player start related logic

[Initialization of the Game Mode](/UE5/LyraStarterGame/InitGame/)
is discussed separately.


<a id='LyraGameState'></a>
## 3.2 Lyra Game State

The Lyra Game State is key to the functionality of Lyra Experiences.

The Lyra Game State itself is relatively simple, but it does initialize
and activate two very important components that enable Experiences:

- Ability System Component
- [Lyra Experience Manager Component](#LyraExperienceManagerComponent)


<a id='LyraExperienceManagerComponent'></a>
### Lyra Experience Manager Component

The `ULyraExperienceManagerComponent`
does the heavy lifting related to loading and unloading,
activating and deactivating Experiences.


<a id='ExperienceLoadingProcedure'></a>
#### Experience Loading Procedure: `StartExperienceLoad`

On the server and on all clients, `StartExperienceLoad` must be called
*(explicitly on the server and via replication on the clients)*,
which begins this process:

- Set state = `Loading`

##### State: Loading
- Async Load assets via [Lyra Asset Manager](#LyraAssetManager)
    - Primary Experience Asset ID
    - Experience Action Sets
    - Client/Server Game Features Subsystem
- On async load complete:
  - Set state = `LoadingGameFeatures`

##### State: Loading Game Features
- Async Load and Activate any/all required GFPs
- After all GFPs finish async loading:
    - Optionally delay loading for debugging purposes based on CVar settings
    - Set state = `ExecutingActions`

##### State: Executing Actions
- Execute all [Game Feature Actions](#GameFeatureAction) defined by the experience and its action sets
- Set state = `Loaded`

##### State: Loaded
- Broadcast [`OnExperienceLoaded`](#OnExperienceLoaded)


<a id='LyraWorldSettings'></a>
## 3.3 Lyra World Settings

- Adds `Default Gameplay Experience` setting to `ULevel` assets
- In PIE, load the default experience during `InitGame`
- This is what allows you to specify the Lyra Experience for a level to use

`Config/DefaultEngine.ini` configures the use of Lyra World Settings:

```ini
[/Script/Engine.Engine]
WorldSettingsClassName=/Script/LyraGame.LyraWorldSettings
```


<a id='LyraAssetManager'></a>
## 3.4 Lyra Asset Manager

- Game-specific implementation of Asset Manager to handle loading assets
  - Allows using Soft Object Pointers in configs to delay loading of assets until they are really needed
    - Supposedly a significant performance boost as compared to *not* using Soft Object Pointers

`Config/DefaultEngine.ini` configures the use of Lyra Asset Manager:

```ini
[/Script/Engine.Engine]
AssetManagerClassName=/Script/LyraGame.LyraAssetManager
```


<a id='LyraExperienceManager'></a>
## 3.5 Lyra Experience Manager

« Engine Subsystem »

- This is required for PIE but otherwise doesn't do anything for the game


<a id='CVars'></a>
## 3.6 Console Variables

For testing purposes, you can add a delay to the Lyra Experience Loading process
to simulate slow computers and/or networks.

- `lyra.chaos.ExperienceDelayLoad.MinSecs` (minimum delay)
- `lyra.chaos.ExperienceDelayLoad.RandomSecs` (maximum time added to `MinSecs`)


# Lyra Gameplay Initiation

This section discusses the intended way to initiate actual gameplay in a Lyra Experience.
TLDR **do not** use `BeginPlay` to start gameplay, instead in `BeginPlay` you need to wait for
`OnExperienceLoaded`.


<a id='OnExperienceLoaded'></a>
## 3.7 On Experience Loaded

The [Lyra Experience Manager Component](#LyraExperienceManagerComponent)
will broadcast the `OnExperienceLoaded` event after the asynchronous experience loading
process has completed.

Your game needs to be diligent about using this event to initiate game play, and **not** use
`BeginPlay` for that purpose.  Using `BeginPlay` to initiate game play will result in intermittent
errors.

Lyra also provides `AsyncAction_OnExperienceLoaded` which is an asynchronous BP action, so that
you can easily wait for `OnExperienceLoaded` in BPs.  Lyra does this when it initializes its
Shooter Mannequin character, for example.

### Three Levels of Priority

The `OnExperienceLoaded` event is fired with three different levels of priority
to allow you to have some handlers that are dependent on other higher priority handlers.

- High (`OnExperienceLoaded_HighPriority`)
- Normal (`OnExperienceLoaded`)
- Low (`OnExperienceLoaded_LowPriority`)

The system is minimal.
For complex interdependencies you will need to devise your own solution,
and understand that the callbacks are executed in random order.


<a id='OnExperienceLoadedExamples'></a>
### Examples of `OnExperienceLoaded` in C++ and BP

There are many examples of how to use `OnExperienceLoaded` in Lyra.
`CTRL`+`SHIFT`+`F` in Rider to see many interesting C++ snippets.
Some examples of particular interest are discussed below.

#### High Priority Examples
- Lyra Team Creation Component :: Begin Play
  - `OnExperienceLoaded` THEN Create Teams
- [Lyra Frontend State Component](#LyraFrontendStateComponent) :: Begin Play
  - `OnExperienceLoaded` THEN Start a multistep async process to show the Frontend Game Menu as soon as possible

#### Normal Priority Examples
- Lyra Player State :: Post Initialize Components
  - `OnExperienceLoaded` THEN Set Player Pawn Data
    - This grants Ability Sets to the Player State based on the Default Pawn Data config
- [Lyra Game Mode](#LyraGameMode) :: Init Game State
  - `OnExperienceLoaded` THEN Restart all players who don't yet have Pawns
    - This effectively assigns each player/bot the Default Pawn Data

#### Low Priority Examples
- Lyra Bot Creation Component :: Begin Play
  - `OnExperienceLoaded` THEN Create Bots
    - Depends on the (high priority) Lyra Team Creation Component having created the teams
    - Depends on the (normal priority) Lyra Player State having set the [Lyra Pawn Data](#LyraPawnData)


<a id='ExampleHookBP'></a>
#### Example BP Hooking into `OnExperienceLoaded`

![Example BP Hook](./screenshots/ExampleHookBP.png)


<a id='ExampleHookCPP'></a>
#### Example C++ Hooking into `OnExperienceLoaded`

In this C++ example, you'd set `BeginPlay` as follows:

```c++
void AMyExampleActor::BeginPlay()
{
    Super::BeginPlay();

    // Boilerplate OnExperienceLoaded hook:
    // TODO consider moving this to a static helper class so you can paste 1 line instead of 5
    AGameStateBase* GameState = GetWorld()->GetGameState();
    check(GameState);
    ULyraExperienceManagerComponent* ExperienceComponent = GameState->FindComponentByClass<ULyraExperienceManagerComponent>();
    check(ExperienceComponent);
    ExperienceComponent->CallOrRegister_OnExperienceLoaded(FOnLyraExperienceLoaded::FDelegate::CreateUObject(this, &ThisClass::OnExperienceLoaded));
}
```

You must also create an `OnExperienceLoaded` handler in `AMyExampleActor`
to receive the event:

```c++
// Called by Lyra Experience Manager
void AMyExampleActor::OnExperienceLoaded(const ULyraExperienceDefinition* Experience)
{
    DoStuff();
}
```

<a id='LoadingADefaultExperience'></a>
# 4 加载默认的 Default Experience

Lyra loads the Frontend Experience as the default by injecting the
[Lyra Frontend State Component](#LyraFrontendStateComponent)
into the [Lyra Game State](#LyraGameState)
from a [Lyra Experience Definition](#LyraExperienceDefinition).

For example, the map Lyra uses by default to start the game is `L_LyraFrontEnd`,
which uses `B_LyraFrontEnd_Experience` as the `Default Gameplay Experience`.

An `AddComponents`
[Game Feature Action](#GameFeatureAction)
in `B_LyraFrontEnd_Experience`
injects `B_LyraFrontendStateComponent`
into the `LyraGameState`,
which causes the Lyra FrontEnd Experience to load on Game start.


<a id='LyraFrontendStateComponent'></a>
## 4.1 Lyra Frontend State Component

The `B_LyraFrontendStateComponent` is a simple BP configuration of
Lyra Frontend State Component,
defining the menu widgets used by the project.

This component is expected to be injected into a
[Lyra Game State](#LyraGameState).
It registers a high priority `OnExperienceLoaded` callback that initiates the
asynchronous process of showing the frontend menu system to the user.

This interfaces with the `CommonLoadingScreen` plugin that is 
[distributed with Lyra](/UE5/LyraStarterGame/Plugins/).
That allows the loading screen to be visible for however long it takes to load the
Lyra Experience.

Once the Experience has loaded and the player is ready to see the menu, the loading
screen is disabled and the menu system is displayed.

- Generally you'll need to make a BP version of this to configure the menu widgets
- Consider this an example component that loads a default experience even if you do not want to use Lyra's FrontEnd


<br/>
<hr/>
<div class="container">
    <p> 感谢原作者 X157 &copy; 的杰出贡献！Thanks to the original author X157&copy; for his outstanding contribution!</p>
        原始文档地址：<a href="https://x157.github.io">source</a> | <a href="https://github.com/x157/x157.github.io/issues">issues</a>
    </p>
</div>