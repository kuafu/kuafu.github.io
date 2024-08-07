---
title: "God Player Experience"
description: ""
breadcrumb_path: "/UE5/LyraStarterGame/Experience"
breadcrumb_name: "God Player"
---


# XCL God Player Experience

This is a 3rd person experience.  The player is effectively a god.

God Players are purely spiritual and have no physical representation in the world.  They:

- can never be harmed or killed
- are not constrained by world physics

The God Player Experience Concept is the gods are in Top Down mode observing and interacting
with the world through their influence on AI Pawns.


# God Player Pawn Data

- Pawn Class = `AXCLGodPlayerCharacter`
- Ability Set: `XAI_GodPlayer_AbilitySet` (`ULyraAbilitySet`)
- Input Config: `XAI_GodPlayer_InputConfig` (`ULyraInputConfig`)
- Camera Mode: `UXCLTopDownCameraMode`


## Player Pawn: `AXCLGodPlayerCharacter`

Inheritance: `AXCLGodPlayerCharacter` « `AXCLCharacter` « `ALyraCharacter`

##### 类默认值

- 胶囊（Capsule）：
  - 碰撞已禁用
  - 禁用导航障碍
  - 阴影已禁用

- 骨架网格体（Skeletal Mesh）：
  - 禁用导航障碍
  - 重力已禁用

- 角色移动组件：
  - 设置模式 = 飞行
  - 重力已禁用
  - 定义所需的最大移动速度和加速度
  - 定义所需的控制器旋转速率


## Camera Mode: `UXCLTopDownCameraMode`

Inheritance: `UXCLTopDownCameraMode` « `UXCLCameraMode` « `ULyraCameraMode`

In an `UpdateView` override the `View` is focused on the (invisible) God Player Mesh Location.
The Rotation is set based on the PlayerController Rotation.

When it activates, the Camera automatically positions itself above the (invisible) pawn, looking down.

This Camera Mode allows you to have pretty much any perspective you want, zoom way in or out,
look in any rotation you want.
