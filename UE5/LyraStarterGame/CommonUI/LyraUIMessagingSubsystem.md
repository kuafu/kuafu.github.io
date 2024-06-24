---
title: "Overview of Lyra UI Messaging Subsystem"
description: "Overview of ULyraUIMessagingSubsystem as configured in UE5 LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame/CommonUI"
breadcrumb_name: Lyra UI Messaging Subsystem
---


# Lyra消息子系统（Lyra UI Messaging Subsystem）

## 1. Lyra UI Messaging Subsystem

`LyraUIMessagingSubsystem` : public `CommonMessagingSubsystem` from `CommonGame`

Lyra消息子系统管理UI布局的`UI.Layer.Modal`层。此子系统提供以下通用功能：
- 显示确认对话框
- 显示错误对话框

要使用的窗口小部件类由 INI 设置定义。它们**必须**是`CommonGameDialog`的派生类，而它本身就是一个`CommonActivatableWidget`。

*`DefaultGame.ini` Settings for Lyra UI Messaging Subsystem*

```ini
[/Script/LyraGame.LyraUIMessaging]
ConfirmationDialogClass=/Game/UI/Foundation/Dialogs/W_ConfirmationDefault.W_ConfirmationDefault_C
ErrorDialogClass=/Game/UI/Foundation/Dialogs/W_ConfirmationError.W_ConfirmationError_C
```
