---
title: "Extending LyraStarterGame: Development Considerations"
description: "Considerations for developing a game based on Lyra, including BP & UAsset duplication and native C++ extension and duplication"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Development Considerations"
---


# 1 扩展Lyra：开发考虑

我的目标是永远不修改基本的Lyra代码或资产，除非绝对必要（这种情况很少发生）。

我越接近实现这个目标，将来合并Epic的Lyra更新到我的代码中就会变得更容易。如果他们对我正在使用的代码进行错误修复，我希望能够获得这些修复。如果他们添加新功能，我希望能够尽可能轻松地实现这些新功能。

- [Extend Lyra C++ Code](#ExtendCPP)
  - [Fill in Some Gaps in Lyra C++ Code](#FillInCPPGaps)
  - [Duplicate Lyra Prototype C++ Code](#DuplicatePrototypeCpp)
- [Duplicate Lyra Binary Assets](#DuplicateAssets)
- [Xist Project Structure: XCL Plugin + XaiLife GFP](#Structure)


<a id='ExtendCPP'></a>
## 1.1 扩展 Lyra C++ Code

我的一般策略是尽可能从Lyra的C++代码派生，定制Lyra类的行为，并以典型的C++方式进行扩展。这需要在Lyra的C++源代码中强制导出许多带有LYRAGAME_API标签的Lyra类，但我预计Epic最终会自行完成这些工作。即使他们不这样做，在任何情况下合并也是非常容易的。

### 1.1.1 优先扩展而不是复制(Prefer Extension to Duplication)

尽可能应该扩展Lyra代码，而不是复制它。只有在不实际扩展Lyra的情况下才复制（例如，原型代码）。当需要对代码进行大量工作以至于合并成为挑战时，这时才需要复制。如果只是对Lyra进行轻微更改，只需修改Lyra本身，并承诺在Lyra更新时将来的Lyra更新合并到您的代码中（例如LYRAGAME_API导出）。

<a id='FillInCPPGaps'></a>
### 1.1.2 在Lyra的C++代码中填补一些空白

There are some gaps in Lyra's C++ code coverage for game modes different from `ShooterCore`.  
Lyra的C++代码覆盖在与ShooterCore不同的游戏模式方面存在一些空白。  

您可能需要自行填补其中的一些。例如：


#### 1.1.2.1 Generic Modular AI Controller

Lyra没有提供通用的模块化AI控制器。我复制了Lyra玩家机器人控制器ALyraPlayerBotController到我的XCL AI控制器``AXCLAIController，并移除了特定于玩家的代码，以创建一个通用的基础模块化AI控制器，用于我未来的所有Lyra项目。希望Epic将来会添加一个通用的AI控制器，在那时，我可以选择将我的XCL AI控制器重新基于新的Lyra AI控制器，或者不这样做，这取决于他们对其的处理。

#### 1.1.2.2 Generic Actor with Ability System

Lyra also does not include a generic Actor with an Ability System.
I created a generic base
[XCL Actor with Abilities](https://github.com/x157/Lyra-ActorWithAbilities)
class as part of my
[Lyra Health and Damage](https://x157.github.io/UE5/LyraStarterGame/Health-and-Damage/)
tutorial based on the Lyra Character with Abilities.

<a id='DuplicatePrototypeCpp'></a>
### Duplicate Lyra Prototype C++ Code

In some cases (Interaction, Inventory, Equipment, Weapons) the Lyra code
is a great jump-off point to build your own systems.  Even if it is not a good
set of base classes in these cases, it **is** a good, functional multiplayer prototype
that you can build out yourself.

For example, I documented the
[Process of Duplicating some Lyra Prototype Code](/UE5/LyraStarterGame/Inventory/#DuplicateToExtend)
in some detail.

Again, it's important to stress that in general extending code is preferable
to duplicating it.


<a id='DuplicateAssets'></a>
## Duplicate Lyra Binary Assets

###### Problem: It is not possible to merge multiple branches of a binary file

Because of this,
**you should not modify Lyra assets**
if you want future Lyra updates from Epic
that don't completely break your game.

###### Solution: Duplicate the Lyra asset into your own GFP and modify your duplicated asset

When you find yourself needing to save a Lyra uasset
(Blueprint, Data Asset, Widget, anything),
**DO NOT** modify the Lyra asset.
Instead, duplicate it into your own GFP and modify your duplicate.

This way Epic can update the Lyra binary assets as much as they want,
and it will not affect your game.  The only Lyra assets you will be using
are the ones you haven't changed at all.

You will be able to choose **if and when**
to copy Epic's future Lyra changes (if and when they make them).
`:-)`

###### Alternative: Hack Lyra Directly

This is by far the easiest option to get started with Lyra.
Just hack the files how you want and save them immediately.

In the long run, by choosing this option you are choosing to
**not be able to get** future Lyra updates from Epic.

If you're just messing around with Lyra to learn, then by all means,
hack Lyra all you want.
If you intend to build an actual game product on Lyra then
I personally don't recommend hacking it, but you're not me,
so you do you.


#### Digression: Binary Assets SUCK

I'm honestly not sure why Epic decided to use binary files for things such
as blueprints and data assets.  There does not seem to be any benefit to a
binary format, and there are many pains in the asses of developers all around
the world.

I digress.  Binary assets suck.  Don't try to reuse or extend them, just
duplicate them and use your own.


<a id='Structure'></a>
## XCL Plugin + XaiLife GFP

I am developing a Lyra game via 2 plugins:

- `XCL` Plugin (Xist Core Lyra)
  - Foundational C++ code (derived from Lyra)
- `XaiLife` GameFeature Plugin (GFP)
  - Configs
  - Content

When you see references to `XCL` anywhere in my documentation, I'm referring
to this plugin and the Lyra-derived code within it.

In the long term my intent is that any/all Lyra projects I develop will
also include my Xist Core Lyra plugin (`XCL`) to fix and extend Lyra to be as reusable
as I require.

When I first started this project, `XCL` was originally a GFP.  However, I modified
it such that `XCL` is now considered foundational C++ code that will always exist
in my Lyra, and so it doesn't need to be a GFP.

The `XaiLife` Plugin is a GFP and contains all of my project's content so far.
