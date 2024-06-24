---
title: "Game Initialization | UE5 LyraStarterGame"
description: "Overview of Game Initialization in LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Game Initialization"
---

# 1 游戏初始化

The GameMode initializes when a World is loaded.
The [World Settings](/UE5/LyraStarterGame/Experience/#LyraWorldSettings)
defines the [GameMode](/UE5/LyraStarterGame/Experience/#LyraGameMode) to use
and (in [Lyra](/UE5/LyraStarterGame/))
which [Lyra Experience](/UE5/LyraStarterGame/Experience/)
to load by default.

加载世界的方式有多种，包括单击“在编辑器中播放”(PIE) 按钮。

更多细节讨论见[Lyra Experience](/UE5/LyraStarterGame/Experience/)，不同于其他游戏，在Lyra中你必须`延迟所有Game play`直到`OnExperienceLoaded`开始,这可能在 `BeginPlay`后很久。


# 2 世界加载流程

世界加载遵循以下流程：

- [Initialize Components of all World Actors](#InitializeActorsForPlay)
  - [Init Game Mode](#InitGame)
  - [Initialize Components](#InitializeComponents) *(random Actor order)*
  - [Player Login](#PlayerLogin)
    - Create Player Controller & Player State
- [World Begin Play](#BeginPlay)
  - Begin Play on all World Actors *(random Actor order)*
- [Load Lyra Experience](#LoadLyraExperience)
  - [`OnExperienceLoaded`](/UE5/LyraStarterGame/Experience/#OnExperienceLoaded)
    signals that game play can begin


<a id='InitializeActorsForPlay'></a>
## 2.1 初始化世界中的所有Actor组件

实现见 World🡒InitializeActorsForPlay


<a id='InitGame'></a>
### 2.1.1 初始化 GameMode

- GameMode🡒InitGame


<a id='InitializeComponents'></a>
### 2.1.2 初始化组件

Initialization of World Actors is in **RANDOM ORDER**.

When the GameMode is initialized, it does:

- GameMode🡒PreInitializeComponents
  - GameState🡒PreInitializeComponents
  - GameState🡒PostInitializeComponents
  - GameMode🡒InitGameState
- GameMode🡒PostInitializeComponents


<a id='PlayerLogin'></a>
### 2.1.3 玩家登录(Player Login)

- GameMode🡒Login
  - GameMode🡒SpawnPlayerController
    - PlayerController🡒PreInitializeComponents
    - PlayerController🡒PostInitializeComponents
      - PlayerController🡒InitPlayerState
        - PlayerState🡒PreInitializeComponents
        - PlayerState🡒PostInitializeComponents
          - GameState🡒AddPlayerState
        - PlayerController->OnPlayerStateChanged
      - PlayerController🡒AddCheats
  - GameMode🡒InitNewPlayer
- PlayerController🡒SetPlayer
  - PlayerController🡒SetupInputComponent
  - PlayerController🡒ReceivedPlayer
    - `CommonGame` adds root HUD layout
- GameMode🡒OnPostLogin


<a id='BeginPlay'></a>
## 2.2 World BeginPlay

- All World Subsystems `OnWorldBeginPlay`
- GameMode🡒StartPlay
  - GameState🡒HandleBeginPlay
    - PlayerController🡒PushInputComponent
    - All World Actors BeginPlay (**RANDOM ORDER**)
      - GameMode🡒BeginPlay
      - GameState🡒BeginPlay
      - PlayerController🡒BeginPlay
      - PlayerState🡒BeginPlay
      - ... etc ...


<a id='LoadLyraExperience'></a>
## 2.3 加载 Lyra Experience

In PIE, the World's Default Lyra Experience gets loaded on the tick after GameMode🡒InitGame.

In Game, the appropriate Lyra Experience is loaded by
the Frontend State Component (or your similar Game State Component).


### 2.3.1 Experience 加载流程

- Load Experience Asset and its References
- Load all GameFeature Plugin (GFP) dependencies
- Activate GFPs (execute GameFeature Actions)
- Broadcast [`OnExperienceLoaded`](/UE5/LyraStarterGame/Experience/#OnExperienceLoaded)

For full details, see
[Experience Loading Procedure](/UE5/LyraStarterGame/Experience/#ExperienceLoadingProcedure)



<br/>
<hr/>
<div class="container">
    <p> 感谢原作者 X157 &copy; 的杰出贡献！Thanks to the original author X157&copy; for his outstanding contribution!<br/>
        原始文档地址：<a href="https://x157.github.io">source</a> | <a href="https://github.com/x157/x157.github.io/issues">issues</a>
    </p>
</div>