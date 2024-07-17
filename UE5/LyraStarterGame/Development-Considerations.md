---
title: "Extending LyraStarterGame: Development Considerations"
description: "Considerations for developing a game based on Lyra, including BP & UAsset duplication and native C++ extension and duplication"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Development Considerations"
---


# 1 扩展Lyra：开发思考

我的目标是永远不修改基本的Lyra代码或资产，除非绝对必要（这种情况很少发生）。

我越接近实现这个目标，将来合并Epic的Lyra更新到我的代码中就会变得越容易。如果他们对我正在使用的代码进行错误修复，我希望能够获得这些修复。如果他们添加新功能，我希望能够尽可能轻松地实现这些新功能。

- [扩展Lyra C++ Code](#ExtendCPP)
  - [在Lyra的C++代码中填补一些空白](#FillInCPPGaps)
  - [复制 Lyra 原型 C++ 代码](#DuplicatePrototypeCpp)
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
Lyra的C++代码覆盖到与ShooterCore不同的游戏模式方面存在一些空白。  

您可能需要自行填补其中的一些。例如：


#### 1.1.2.1 通用模块化 AI 控制器

Lyra没有提供通用的模块化AI控制器。我复制了Lyra玩家机器人控制器ALyraPlayerBotController到我的XCL AI控制器``AXCLAIController，并移除了特定于玩家的代码，以创建一个通用的基础模块化AI控制器，用于我未来的所有Lyra项目。希望Epic将来会添加一个通用的AI控制器，在那时，我可以选择将我的XCL AI控制器重新基于新的Lyra AI控制器，或者不这样做，这取决于他们对其的处理。

#### 1.1.2.2 具有能力系统的通用 Actor
Lyra 也不包含具有能力系统的通用 Actor。我创建了一个通用基础
[具有能力的 XCL Actor](https://github.com/x157/Lyra-ActorWithAbilities)类，作为我的[Lyra 声明和伤害](https://x157.github.io/UE5/LyraStarterGame/Health-and-Damage/)教程的一部分，该教程基于具有能力的 Lyra 角色。

<a id='DuplicatePrototypeCpp'></a>
### 复制 Lyra 原型 C++ 代码
在某些情况下（交互、库存、装备、武器），Lyra 代码是构建您自己的系统的绝佳起点。即使在这些情况下它不是一组好的基类，但它**是一个**好的、功能齐全的多人原型，您可以自己构建。

例如，我详细记录了[复制一些 Lyra 原型代码的过程](/UE5/LyraStarterGame/Inventory/#DuplicateToExtend)。

再次强调，重要的是，一般来说，扩展代码比复制代码更好。


<a id='DuplicateAssets'></a>
## 1.2 复制 Lyra 二进制资产
###### 问题：无法合并二进制文件的多个分支

因此，如果您希望 Epic 将来更新 Lyra 而不会完全破坏您的游戏，则**您不应修改 Lyra 资产**。

###### 解决方案：将 Lyra 资产复制到您自己的 GFP 中并修改您的复制资产

当您发现自己需要保存 Lyra uasset（蓝图、数据资产、小部件等）时，**请勿**修改 Lyra 资产。相反，将其复制到您自己的 GFP 中并修改您的副本。

这样，Epic 可以根据需要更新 Lyra 二进制资产，并且不会影响您的游戏。您将使用的唯一 Lyra 资产是您根本没有更改的资产。

您将能够选择**是否以及何时**复制 Epic 未来的 Lyra 更改（如果他们进行更改）。

###### 替代方案：直接破解 Lyra

这是目前为止开始使用 Lyra 最简单的选择。只需按照您想要的方式破解文件并立即保存即可。

从长远来看，选择此选项，您就选择**无法从 Epic 获取**未来的 Lyra 更新。

如果您只是为了学习而摆弄 Lyra，那么尽一切可能，破解 Lyra。

如果您打算在 Lyra 上构建真正的游戏产品，那么我个人不建议破解它，但您不是我，所以您自己去做吧。

#### 题外话：二进制资产糟透了
老实说，我不确定为什么 Epic 决定将二进制文件用于蓝图和数据资产等内容。二进制格式似乎没有任何好处，而且世界各地的开发人员都为此烦恼不已。

我离题了。二进制资产糟透了。不要尝试重复使用或扩展它们，只需复制它们并使用您自己的。


<a id='Structure'></a>
## 1.3 XCL 插件 + XaiLife GFP

我正在通过 2 个插件开发 Lyra 游戏：
- `XCL` 插件 (Xist Core Lyra)
  - 基础 C++ 代码 (源自 Lyra)
- `XaiLife` GameFeature 插件 (GFP)
  - 配置
  - 内容

当​​您在我的文档的任何地方看到对 `XCL` 的引用时，我指的是这个插件和其中的 Lyra 派生代码。

从长远来看，我的目的是我开发的任何/所有 Lyra 项目也将包括我的 Xist Core Lyra 插件 (`XCL`)，以修复和扩展 Lyra，使其尽可能地可重复使用。

当我第一次开始这个项目时，`XCL` 最初是一个 GFP。但是，我对其进行了修改，使得 `XCL` 现在被视为基础 C++ 代码，它将始终存在于我的 Lyra 中，因此它不需要是 GFP。

`XaiLife` 插件是一个 GFP，包含我迄今为止的所有内容。