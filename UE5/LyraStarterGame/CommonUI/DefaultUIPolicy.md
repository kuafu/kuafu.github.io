---
title: "LyraStarterGame Default UI Policy"
description: "Review the UE5 INI setting that sets the Lyra Default UI Policy and the default settings configured there"
breadcrumb_path: "UE5/LyraStarterGame/CommonUI"
breadcrumb_name: Default UI Policy
---


# 1 Lyra 默认 UI 策略详细信息

更多信息见 [How Common UI is Setup in LyraStarterGame](./)


## 1.1 默认 UI 策略

Lyra UI 管理子系统实现了一个全局的 "UI 策略"，最终只是一个定义了prioritized widget 容器 "层" 的widget。（a widget that defines prioritized widget container "layers"）
使用哪个小部件是通过蓝图类定义的，在INI中进行配置：

- In `DefaultGame.ini`:
    - Set Default UI Policy = `Content/UI/B_LyraUIPolicy`

### `DefaultGame.ini` Setting:

```ini
[/Script/LyraGame.LyraUIManagerSubsystem]
DefaultUIPolicyClass=/Game/UI/B_LyraUIPolicy.B_LyraUIPolicy_C
```

### Lyra UI Manager Subsystem

#### `LyraUIManagerSubsystem` : public `GameUIManagerSubsystem` from `CommonGame`

该子系统管理创建 UI Layout widget并将其添加到本地玩家的视口。它还支持在运行时更改 UI 策略。如果需要执行此操作，请查看其 C++ 代码。

## 1.2 Lyra UI Policy
### `B_LyraUIPolicy` : public `GameUIPolicy` from `CommonGame`

```c++
UCLASS(Abstract, Blueprintable, Within = GameUIManagerSubsystem)
class COMMONGAME_API UGameUIPolicy : public UObject
```

This BP specifies a single global UI Layout Widget:

- In `B_LyraUIPolicy`:
  - Set `Game UI Policy` / `LayoutClass` = `Content/UI/W_OverallUILayout`

###### Set Overall UI Layout = `W_OverallUILayout`


## 1.3 Overall UI Layout
### `W_OverallUILayout` : public `PrimaryGameLayout` from `CommonGame`

```c++
/**
 * The primary game UI layout of your game.  This widget class represents how to layout, push and display all layers
 * of the UI for a single player.  Each player in a split-screen game will receive their own primary game layout.
 */
UCLASS(Abstract, meta = (DisableNativeTick))
class COMMONGAME_API UPrimaryGameLayout : public UCommonUserWidget
```

### Lyra UI Layers

The `W_OverallUILayout` widget defines 4 widget layer stacks:

- `UI.Layer.Game` - Things like the HUD.
- `UI.Layer.GameMenu` - "Menus" specifically related to gameplay, like maybe an in game inventory UI.
- `UI.Layer.Menu` - Things like the settings screen.
- `UI.Layer.Modal` - Confirmation dialogs, error dialogs.

## 1.4 Common Activatable Widget Containers

`CommonUI` ships with both `Stack` and `Queue` containers, and Lyra only uses `Stack` by default.

If you need something more complex than a `Stack` or `Queue`, you can derive your own layer type by deriving from `CommonUI` `UCommonActivatableWidgetContainerBase`.

### Common Activatable Widget Stack
#### `CommonActivatableWidgetStack` : public `UCommonActivatableWidgetContainerBase` from `CommonUI`
```c++
/** 
 * A display stack of ActivatableWidget elements. 
 * 
 * - Only the widget at the top of the stack is displayed and activated. All others are deactivated.
 * - When that top-most displayed widget deactivates, it's automatically removed and the preceding entry is displayed/activated.
 * - If RootContent is provided, it can never be removed regardless of activation state
 */
UCLASS()
class COMMONUI_API UCommonActivatableWidgetStack : public UCommonActivatableWidgetContainerBase
```

You can create your own, more complex Layer type by sub-classing
`CommonActivatableWidgetContainerBase`.

All other widgets are `CommonActivatableWidget` derivatives, and rather than getting
added directly to the viewport, they get pushed onto one of the UI layer stacks.

### Common Activatable Widget Queue
#### `CommonActivatableWidgetQueue` : public `UCommonActivatableWidgetContainerBase` from `CommonUI`
```c++
/** 
 * A display queue of ActivatableWidget elements. 
 *
 * - Only one widget is active/displayed at a time, all others in the queue are deactivated.
 * - When the active widget deactivates, it is automatically removed from the widget, 
 *		released back to the pool, and the next widget in the queue (if any) is displayed
 */
UCLASS()
class COMMONUI_API UCommonActivatableWidgetQueue : public UCommonActivatableWidgetContainerBase
```
