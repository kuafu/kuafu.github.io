---
title: "Common UI Plugin"
description: "Overview of the Common UI plugin for Unreal Engine 5"
breadcrumb_path: "UE5"
breadcrumb_name: "Common UI"
---


# 1 Common UI Plugin

Common UI 插件允许在 UI 中自动执行许多特定于平台的行为。例如，可以根据平台类型自动显示/隐藏按钮，并且在编辑器中测试不同平台非常容易。


[Lyra 输入概述](/UE5/LyraStarterGame/Input/) 很好地概述了 Common UI 的可能实现方式。

## 1.1 关键概念

- [通用 UI 动作路由器](./ActionRouter)
- 管理输入模式
- [可激活小部件](./ActivatableWidget)
- 大多数 Lyra 小部件的基础

## 1.2 Lyra 中的示例用法

- [Lyra UI 策略](/UE5/LyraStarterGame/Input/UIPolicy) 定义了优先级的标记层
[可激活小部件](./ActivatableWidget)

### 1.2.1 示例：Lyra 通用 UI 层

按优先级升序，Lyra 将这些通用 UI 层定义为具有相关游戏标记的堆栈：

- `UI.Layer.Game` - 与游戏直接相关的 UI
- `UI.Layer.GameMenu` - 例如：库存 UI
- `UI.Layer.Menu` - 主菜单层
- `UI.Layer.Modal` - 提示/确认对话框层


## 1.3 输入处理

通用 UI 会随时将输入定向到当前具有焦点的小部件（默认情况下，位于最高优先级可见层顶部的小部件）。

Widget 输入通过以下方式配置：

- `DataTable` with row type `CommonInputActionDataBase`
- One or more `CommonInputBaseControllerData`-derived `ControllerData` assets
  - These reference the input action `DataTable`
- Custom `CommonUIInputData`-derived BP/Object
  - This references the input action `DataTable`
- 配置通用输入操作，例如：
  - 继续
  - 返回/取消
  - 可能还有其他


### 1.3.1 项目设置：通用输入

- 将自定义`CommonUIInputData` 对象分配给`Input`。`Input Data`下拉菜单
- 根据需要配置平台和输入设备设置
- Windows
  - MKB
  - 游戏手柄
- 等等


### 1.3.2 更好地了解通用 UI 的输入和项目设置的资源

- [Epic 的官方通用 UI 快速入门指南](https://docs.unrealengine.com/5.0/en-US/common-ui-quickstart-guide-for-unreal-engine/) (文本 +屏幕截图文档)
- Volkiller Games：[虚幻引擎 5 中的通用 UI 输入系统](https://youtu.be/q05jmFyeb0c)（5 分钟视频）
- Epic 的 Inside Unreal 剧集：[CommonUI 简介](./Annotations/EpicGames-Introduction-to-CommonUI)（2.5 小时视频）



## 1.4 共享样式资产
Common UI 允许您创建样式资产，然后轻松应用于小部件、按钮等。

这样，您只需更新一种样式，游戏中的所有小部件都将根据该样式更改进行更新。

为此，请根据需要从基本样式类派生并配置您的小部件以使用适当的样式。


### 1.4.1 Base Style C++ Classes:
- `CommonBorderStyle`
- `CommonButtonStyle`
- `CommonTextStyle`
- others?


## 105 调试 通用 UI

###### 控制台命令：`CommonUI.DumpActivatableTree`

如果您输入上述控制台命令，您将获得调试信息的输出日志转储,这有助于了解当前通用 UI 显示堆栈的样子。

<a id="Annotations"></a>
<a id="Annotations_EpicGames"></a>

## 1.6 来自 Epic Games 视频源的注释
- [Lyra 跨平台 UI 开发](./Annotations/EpicGames-Lyra-Cross-Platform-UI-Development) (45 分钟)
  - 如何在 LyraStarterGame 中实现 CommonUI
  - 对 CommonUI 实现的良好总体概述
- [CommonUI 简介](./Annotations/EpicGames-Introduction-to-CommonUI) (2 小时 41 分钟)
  - 实际上是 2.5 小时的头脑风暴
  - 如何将 CommonUI 添加到新项目中
  - 展示一些常见的样式选项
  - 完整的蓝图实现，并附有多个注释“实际上不要这样做”
    - 仅作为示例

<a id="Annotations_Other"></a>


## 1.7 外部参考资料

有关 Common 的更多见解UI，我推荐：

- [benui 的通用 UI 简介](https://benui.ca/unreal/common-ui-intro/)
- [benui 的通用 UI 按钮深度解析](https://benui.ca/unreal/common-ui-button/)
- 深入了解通用 UI 按钮，了解如何设计和使用它们
- [Volkiller Games：虚幻引擎 5 中的通用 UI 输入系统](https://youtu.be/q05jmFyeb0c) (6 分钟)
- 本视频主要详细介绍了初始项目设置
- 还展示了特定于控制器的按钮图标
- [Volkiller Games：虚幻引擎 5 中的通用按钮和通用可激活小部件](https://youtu.be/HUGtsOqTIp8) (6 分钟)