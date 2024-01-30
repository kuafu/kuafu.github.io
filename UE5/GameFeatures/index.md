---
title: "UE5 GameFeature Plugins"
description: "What are GameFeature Plugins? How are they different from regular Plugins?"
breadcrumb_path: "UE5"
breadcrumb_name: "Game Features"
---


# 1 GameFeature Plugins 概述

A `GameFeature` Plugin is more like a *Mod* than like a traditional plugin.
Where a regular `Plugin` cannot access base game code,
a `GameFeature` plugin **CAN**.

Implementing the [`Modular Gameplay`](/UE5/ModularGameplay/)
pattern in your game allows you to ship a basic game
that can choose **IF** and **WHEN**
to load custom `GameFeature` components at runtime.

要使其工作，需要基于各自的 Modular Gameplay 实现来构建 APlayerState、APlayerController、ACharacter 和其他类。

(You can implement the [`Modular Gameplay`](/UE5/ModularGameplay/) patterns yourself
into your existing code if you prefer to avoid a rebase onto
the default `ModularGameplayActors` implementation.)


## 1.1 调试 Tip

Enable `LogGameFeatures` Verbose logging to gain visibility into when Game Feature Actions
are being run and what they are doing to your game objects.

Console Command: `Log LogGameFeatures Verbose`


## 1.2 LyraStarterGame Example

在 LyraStarterGame 中，ALyraPlayerState、ALyraPlayerController、ALyraCharacter 等都基于`ModularGameplayActors 插件`。

在运行时，游戏知道所有可用的“GameFeature”插件，但除非游戏明确选择这样做，否则它不会加载或激活这些插件。

在Lyra中，当你加载一个`Experience`时，它将自动加载该体验依赖的任何`GameFeature`插件，然后将游戏启动到该地图，使用该experience以及所有已启用的运行时加载的代码/资源。


### There is a default "Runtime" suffix that you can remove

By default, when you create a `GameFeature` plugin in the UE5 editor, it will force
some parts of your `XistGame` project to use the name `XistGameRuntime` instead.

I asked for: `XistGame`

I received: `XistGame` (sometimes `XistGameRuntime` and `XISTGAMERUNTIME_API`)

#### How to: Remove the "Runtime" suffix

Follow this procedure:
[How to: Remove "Runtime" Suffix from GameFeature Plugin Code Names](./How-To-Remove-GameFeature-Runtime-Code-Suffix)

Now what I have is: `XistGame` (always `XistGame` and `XISTGAME_API`)
