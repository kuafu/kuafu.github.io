---
title: "LyraStarterGame Inventory System"
description: "Overview of the Inventory system in UE5 LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Inventory System"
---


# 1 Lyra 库存（物品）系统(Inventory System) 
库存系统是构建[Lyra 装备系统](/UE5/LyraStarterGame/Equipment/) 和[Lyra 武器系统](/UE5/LyraStarterGame/Weapons/) 的基础。

这里有很多代码（包括装备和武器系统），而且在大多数情况下，它似乎对 Lyra 的用例来说运行得相当好。这是一个很好的起点，应该可以让您大致了解 Epic 对库存实施的想法。还有一些改进的空间，我将在下面讨论。
- [建设性批评(Constructive Criticism)](#ConstructiveCriticism) - 您可能无法按原样使用此系统的原因
- [复制并扩展(Duplicate to Extend)](#DuplicateToExtend) - 如何复制此代码以自己实现它*（大约需要 2 个小时，节省更多时间）*

请注意，此代码支持多人游戏。如果您不是 UE 网络复制方面的专家，我建议您阅读此代码。它实现了 `FFastArraySerializer` 以通过网络序列化数组差异。此方法特定于 UE，因此您可以将其应用于任何/所有与远程播放器同步数组的情况。

其他参考：  
- 官方文档：[Lyra物品栏和装备](https://dev.epicgames.com/documentation/zh-cn/unreal-engine/lyra-inventory-and-equipment-in-unreal-engine)  
- 网络视频：[参考视频](https://youtu.be/MMiDMn0fJRU)

## 1.1 名词解释
官方文档将Inventory 翻译为`物品栏`，Google翻译为库存，而有的地方也叫背包。Inventory一般与Equipment关联，两者也是不同范畴的概念，Inventory表示角色的背包，Inventory Item表示背包中的物品，而这个物品如果装配到角色身上时才会创建Equipment实例，卸载下来就被销毁。具体两者对比参考官方文档[Lyra物品栏和装备](https://dev.epicgames.com/documentation/zh-cn/unreal-engine/

## 1.2 库存(物品)(Inventory)概念
- [物品定义(Item Definition)](#ItemDefinition) (常量)
  - 由一个或多个 [物品碎片](#ItemFragments) 组成，例如：
    - `EquippableItem`（如何创建物品“类别”的示例，在本例中为玩家可以装备的物品）
    - `SetStats`（在我看来，这是最有趣且最有用的示例）
    - 等等

- [物品实例(Item Instance)](#ItemInstance)
  - 通用物品定义的特定实例
- [物品管理器(Inventory Manager)](#InventoryManager) (Controller component)
  - 跟踪 Pawn 库存中的物品实例

- [`IPickupable` 接口](#IPickupable)
  - 定义当物品被拾取时实际进入库存的东西

#### Lyra 5.1 更新点

Lyra 5.1 中的网络代码发生了变化。不是复制库存列表数组，数组中的每个条目都被视为库存管理器组件的子对象。
通常，这是相同的想法，只是实现不同。这是一个小小的效率提升。当我从 Lyra 5.0 升级到 Lyra 5.1 时，我还需要更改此代码以匹配新的
子对象实现。可能是 UE 5.1 中的某些更改导致了这种变化，否则也许我只是有一个糟糕的 5.1 开发版本，具有破坏的向后兼容性。
如果您发现在 5.1 升级后您的重复库存无法正确复制，这很可能是您的问题。更新代码中的这几个网络函数以匹配Lyra 5.1 正在使用的
子对象样式，它将再次正确复制。


<a id="ItemDefinition"></a>
## 1.3 物品定义(Item Definition)

为了将物品存储在库存中，该物品必须具有物品定义。这本质上是一个简单的常量配置。`ULyraInventoryItemDefinition` 几乎没有任何功能，它只是数据。从本质上讲，物品定义只不过是玩家的显示名称，以及实际定义物品的物品碎片数组。


<a id="ItemFragments"></a>
### 1.3.1 物品碎片(Item Fragments)
商品片段包含商品定义的一部分。这本质上就是商品定义实现模块化的方式。您可以通过从“ULyraInventoryItemFragment”派生来创建自己的片段。

示例代码很好地说明了模块化和可重用性，但它的性能肯定不高。有很多可以优化的组件搜索和循环，但同样，总的来说，这是一个与库存相关的“什么”的好例子，即使不是最好的“如何”。

官方文档《Lyra物品栏和装备》中有各种物品片段的说明。
  
	  
	  
| 物品栏物品                         | 说明                                                   |
|-----------------------------------|--------------------------------------------------------|
| InventoryFragment_PickupIcon      | 确定可以拾取的物品在世界中的表示。                        |
| InventoryFragment_EquippableItem | 将此物品栏物品与所有者配备该物品时使用的装备定义配对        |
| InventoryFragment_SetStats        | 在拾取时授予一组基于Gameplay标签的堆栈，例如弹药。         |
| InventoryFragment_QuickbarIcon    | 确定用于占据玩家快速栏UI中插槽的物品的HUD图标。            |
| InventoryFragment_ReticleConfig   | 指定在配备此物品栏物品时要实例化的替代HUD准星类。          |

#### 碎片(Fragment)：可装备的物品
`UInventoryFragment_EquippableItem` 保存对[装备定义](/UE5/LyraStarterGame/Equipment/#EquipmentDefinition)(`ULyraEquipmentDefinition`) 的引用。

此片段允许库存物品成为[装备系统](/UE5/LyraStarterGame/Equipment/) 的一部分。物品必须具有此类型的片段，玩家才能装备它。缺少此片段的物品仍可存储在库存中，但无法装备。

将其视为一种界面。当用户尝试装备物品时，C++ 会搜索类型为 `EquippableItem` 的物品定义片段。如果存在，则检索装备定义引用以对其执行装备操作。


<a id="Fragment_SetStats"></a>

#### 碎片：设置统计数据
`UInventoryFragment_SetStats` 是一个数字属性集，以游戏标记到整数的映射形式设置。例如，在 `ShooterCore` 中有一个 `ID_Rifle` 项目定义，它定义了步枪武器。

`ID_Rifle` 项目定义包括一个 `SetStats` 片段，具有以下映射：
| GameplayTag                            | Value |
|----------------------------------------|-------|
| `Lyra.ShooterGame.Weapon.MagazineSize` | 30    |
| `Lyra.ShooterGame.Weapon.MagazineAmmo` | 30    |
| `Lyra.ShooterGame.Weapon.SpareAmmo`    | 60    |

#### 碎片: 拾取图标
`UInventoryFragment_PickupIcon` 特定于设备生成板，并定义在板上显示的网格、项目的显示名称和板的颜色。

#### 碎片: 快捷栏图标
`UInventoryFragment_QuickBarIcon` 特定于显示在玩家屏幕右下角的 QuickBar。它定义在 QuickBar 中显示的图标以表示物品及其弹药。

#### 碎片: 准心(Reticle)配置
`UInventoryFragment_ReticleConfig` 实际上是 [Lyra 武器系统](/UE5/LyraStarterGame/Weapons/) 的一部分。它是一个小部件数组，组成了给定武器的瞄准线。

<a id="ItemInstance"></a>
## 1.4 物品实例(Item Instance)

这是物品定义的“实例”。当玩家获得物品时，他们实际上会收到一个物品实例。

物品实例包括：
- 对通用 const 物品定义的引用
- 游戏标记映射特定于此物品实例的数字统计数据
- *（请参阅 [SetStats Fragment](#Fragment_SetStats)，如果存在，则初始化此映射）*


<a id="InventoryManager"></a>
## 1.5 物品栏管理器(Inventory Manager)
我认为这个组件就是实际的库存本身。Lyra 希望您将这个组件放在 `AController` 上。

方法包括以下内容：
- 添加物品
- 删除物品
- 查找物品
- 获取物品数量
- 消耗物品

<a id="IPickupable"></a>
## 1.6 `IPickupable` 接口
为了使物品能够被拾取，它必须支持这个纯虚拟接口。您的物品必须实现 `GetPickupInventory`，它会告诉基本代码如何将
物品添加到库存中。

<a id="ConstructiveCriticism"></a>

# 2 建设性的批评(Constructive Criticism)
就我而言，需要对基础 Lyra 库存系统进行一些根本性的更改以支持我的游戏要求。

如果您的游戏与 Lyra 的 ShooterGame 足够相似，那么这可能不会对您造成太大影响。下面讨论了针对我的用例解决这些问题的方法。

### Lyra 库存系统(nventory System)作为基础实施存在的问题
以下是我在衍生实现中修改的 Lyra 库存系统的一些问题：

- 无法正常处理物品堆叠计数
  - 有代码允许物品堆叠计数，但尚未完全实现
    - 因此堆叠实际上被限制为大小 = `1`
    - 这不会对 Lyra 的 ShooterGame 产生实质性影响，因为 Lyra 中的物品堆叠大小 == `1`
      - 例如 `1` 把手枪或 `1` 把步枪
      - Lyra 中的弹药与库存物品不对应
        - 因为弹药是武器属性，所以不受此物品堆叠计数限制的影响
  - 因此 Lyra 不支持“填充堆叠”的概念
    - Lyra **在向库存添加某些东西时始终会创建一个新的物品实例**；
      它不允许更新现有物品堆栈的数量
    - 如果我可以在一个插槽中堆叠多达 200 件物品，那么当我拾起 10 件物品时，我不需要一个新的包含 10 件物品的堆栈；我想将物品添加到我现有的堆栈中，直到它们达到最大值 200 件，然后根据需要添加剩余的新堆栈
    - 我还想知道我成功添加了多少件物品；`0/10`？`3/10`？`10/10`？
  - Lyra 不支持“库存已满”或其他“无法添加到库存”条件的概念
    - 底层库存代码永远不会无法添加新物品堆栈
    - Lyra 将物品放入库存的唯一方法是通过[装备系统快捷栏](../Equipment/#QuickBarComponent)，这就是他们限制库存大小的方式

- Lyra 将库存管理器放在控制器上，因此它仅在服务器上可用以及在本地控制 Pawn 的客户端上
  - 在我的游戏中，玩家需要能够查看/修改他们团队中 AI 机器人的库存，这需要将此组件移动到 Pawn 本身而不是其控制器

这并不是说 Lyra 代码不好。它并不坏。它只是没有以一种我可以轻松扩展以满足不同游戏需求的方式实现库存。

鉴于 Lyra 库存系统还不错，它也**不**是一个很好的基础库存系统。它确实足以处理 Lyra 的最低 ShooterGame 库存要求，并且代码易于理解。但是，它**通常不可配置**，导致代码难以在不进行重大修改的情况下进行扩展。

因此，Lyra 的库存系统不是一个很好的基础实现，尽管它是一个很好的示例和起点。

<a id="DuplicateToExtend"></a>
# 3 XCL方法：复制并扩展
对于 XCL，我决定最好的方法是将 Lyra 的库存+设备+武器系统复制到我的游戏功能插件中，重构名称，然后修改我的代码版本。这相当容易，大约需要 2 个小时。大部分繁重的工作都是由 Rider 的重构功能完成的。

我自己输入这些内容需要**更长的时间**，所以总的来说，走这条路明显节省了时间。

相反，您可以开始破解 Lyra 代码本身来做您想做的事情，但这样您将失去合并 Epic 未来 Lyra 更新的能力，所以这不是我走的路。

我建议您熟悉[Lyra 开发注意事项](/UE5/LyraStarterGame/Development-Considerations)，它解释了为什么我不想直接修改 Lyra 代码/资产，除非绝对必要。*

## 3.1 XCL复制流程

1. 如下表所示复制代码
2. 将所有 `Lyra` 名称重构为 `XCL` *(仅重构**导入目录中的代码**)*
- 类名
- 方法名
- 变量名
- 文件名
- 等等
3. 重命名文件以保持一致的命名约定
4. 修改新导入文件中的原生游戏标签名称：`Lyra` 🡒 `XCL`

I duplicated Public headers:

| Lyra C++ Path                  | XCL GameFeature Plugin Source          | Scope   | Relative Path  |
|--------------------------------|----------------------------------------|---------|----------------|
| `_LYRA_/Equipment/*.h`         | `Plugins/GameFeatures/XCL/Source/XCL/` | Public  | `/Equipment/`  |
| `_LYRA_/Inventory/*.h`         | `Plugins/GameFeatures/XCL/Source/XCL/` | Public  | `/Inventory/`  |
| `_LYRA_/Weapons/*.h`           | `Plugins/GameFeatures/XCL/Source/XCL/` | Public  | `/Weapons/`    |
| `_LYRA_/UI/Weapons/_WIDGET_.h` | `Plugins/GameFeatures/XCL/Source/XCL/` | Public  | `/UI/Weapons/` |

and Private implementation:

| Lyra C++ Path                    | XCL GameFeature Plugin Source          | Scope   | Relative Path  |
|----------------------------------|----------------------------------------|---------|----------------|
| `_LYRA_/Equipment/*.cpp`         | `Plugins/GameFeatures/XCL/Source/XCL/` | Private | `/Equipment/`  |
| `_LYRA_/Inventory/*.cpp`         | `Plugins/GameFeatures/XCL/Source/XCL/` | Private | `/Inventory/`  |
| `_LYRA_/Weapons/*.cpp`           | `Plugins/GameFeatures/XCL/Source/XCL/` | Private | `/Weapons/`    |
| `_LYRA_/UI/Weapons/_WIDGET_.cpp` | `Plugins/GameFeatures/XCL/Source/XCL/` | Private | `/UI/Weapons/` |

模板变量：
- `_LYRA_` == `Source/LyraGame`
- `_WIDGET_` == `LyraReticleWidgetBase`
- 我只复制了一个小部件：`LyraReticleWidgetBase`
  - 这是基本武器代码所必需的
- 如果您需要其他小部件，请以相同的方式复制它们

# 4 如何体验 Lyra 的物品系统(Inventory System)

TLDR 库存原型体验在 UE 5.0.3 中不起作用。

如何体验它：
- 仅限编辑器的快速破解：[X157 开发人员说明：如何体验 Epic 的原型库存系统](/UE5/LyraStarterGame/Interactions/#How_to_Experience_Epics_Inventory_Prototype)
- 游戏兼容修复：[Garashka：修复 Lyra 的库存系统](https://garashka.github.io/LyraDocs/lyra/fixing-inventory-system)
深入了解底层体验问题和相关修复

**更新：**此问题已在 Lyra 5.1 中修复

在 Lyra 5.1+ 中，打开`ShooterExplorer` GFP 中的地图以体验 Lyra 的原型库存系统。



<br/>
<hr/>
<div class="container">
    <p> 感谢原作者 X157 &copy; 的杰出贡献！Thanks to the original author X157&copy; for his outstanding contribution!<br/>
        原始文档地址：<a href="https://x157.github.io">source</a> | <a href="https://github.com/x157/x157.github.io/issues">issues</a>
    </p>
</div>