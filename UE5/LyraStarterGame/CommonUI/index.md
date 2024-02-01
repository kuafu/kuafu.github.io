---
title: "How Common UI is Setup in LyraStarterGame"
description: "Review of how Epic configured Common UI in LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: Common UI
---


# 1 如何设置LyraStarterGame中的UI

本文档描述了`LyraStarterGame`如何设置和使用`CommonUI`插件。
有关`CommonUI`的一般信息，请参阅 [Common UI Overview](/UE5/CommonUI/)。

## 1.1 整体UI布局
- [Project Settings](./ProjectSettings)
- [Default UI Policy](./DefaultUIPolicy)

## 1.2 UI Layers (可激活的 Widget Stacks)

### `UI.Layer.Game`
- 诸如HUD之类的东西。
- Layer Root is expected to be assigned by the Lyra Experience
  - Layer Root generally derives from [`LyraHUDLayout`](#LyraHUDLayout)

###### Example: `W_ShooterHUDLayout`
- Load `B_ShooterGame_Elimination` Experience
  - Activate `LAS_ShooterGame_StandardHUD` Action Set
    - Assign `UI.Layer.Game` = `W_ShooterHUDLayout`
    - Assign other widgets to slots defined by this HUD

### `UI.Layer.GameMenu`
- "Menus" specifically related to gameplay, like maybe an in game inventory UI.
  - Not in use in current shipping version of Lyra
    - Prototype Inventory map incorrectly tries to use this, but it doesn't work correctly.
- You can implement this yourself in your game
  - Make sure you make the root a `LyraHUDLayout` widget
    - Then add other widgets to the root as needed for your game

### `UI.Layer.Menu`
- 诸如设置屏幕之类的东西。
- Widgets get pushed to this layer by the `UI.Layer.Game` base class [`LyraHUDLayout`](#LyraHUDLayout)

### `UI.Layer.Modal`
- Confirmation dialogs, error dialogs.
- Managed by [Lyra UI Messaging Subsystem](./LyraUIMessagingSubsystem)


<a id="LyraHUDLayout"></a>
## 1.3 Lyra HUD 布局
### `LyraHUDLayout` : public `LyraActivatableWidget` from `CommonUI`
```c++
/**
 * ULyraHUDLayout
 *
 *	Widget used to lay out the player's HUD (typically specified by an Add Widgets action in the experience)
 */
UCLASS(Abstract, BlueprintType, Blueprintable, Meta = (DisplayName = "Lyra HUD Layout", Category = "Lyra|HUD"))
class ULyraHUDLayout : public ULyraActivatableWidget
```

从 `LyraHUDLayout`` 派生的Widgets将获得对 `UI.Action.Escape`` 输入标签的本机支持，并在每个事件上将 BP 定义的 `EscapeMenuClass`` 推送到 `UI.Layer.Menu`。

 `UI.Action.Escape` 事件定义见 [Project Settings](./ProjectSettings)


## 1.4 调试
当您想知道当前哪些widgets处于活动状态时，可以使用此控制台命令来获取CommonUI输出的日志转储：  
**Console Debug command:** `CommonUI.DumpActivatableTree`


