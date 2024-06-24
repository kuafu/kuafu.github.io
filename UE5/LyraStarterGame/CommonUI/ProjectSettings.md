---
title: "LyraStarterGame Project Settings for Common UI implementation"
description: "List of Common UI specific Project Settings found in LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame/CommonUI"
breadcrumb_name: Project Settings
---


# 1. 与CommonUI相关的 Lyra 项目设置

## 2. 项目设置: Gameplay Tags

`DefaultGameplayTags.ini`

```ini
[/Script/GameplayTags.GameplayTagsSettings]
+GameplayTagList=(Tag="UI.Action.Back",DevComment="")
+GameplayTagList=(Tag="UI.Layer.Game",DevComment="")
+GameplayTagList=(Tag="UI.Layer.GameMenu",DevComment="")
+GameplayTagList=(Tag="UI.Layer.Menu",DevComment="")
+GameplayTagList=(Tag="UI.Layer.Modal",DevComment="")
```


## 3. 项目设置: `Plugins` / `Common UI Input Settings`

`UI.Action.Escape` Action Tag assigned to:

- Keyboard `Escape` key
- Gamepad `Special Right` button


## 4. 项目设置: `Game` / `Common Input Settings`

分配项目范围的 UI 输入映射：

`Input`.`Input Data` = `B_CommonInputData`

本节中有很多针对平台的输入配置，适用于`Android`, `HoloLens`, `IOS`, `Linux`, `LinuxArm64`, `Mac`, `TVOS` and `Windows`。

有关如何配置每个平台的更多详细信息，请参阅`Project Settings`中的`Game` / `Common Input Settings`。


## 5. 通用输入数据(Common Input Data)

`B_CommonInputData` : public `UCommonUIInputData` from `CommonUI`

| ID                   | Data Table            | Data Key         | Windows Default | Xbox Default | PS Default |
|----------------------|-----------------------|------------------|-----------------|--------------|------------|
| Default Click Action | `DT_UniversalActions` | `DefaultForward` | *None*          | (A)          | (O)        |
| Default Back Action  | `DT_UniversalActions` | `DefaultBack`    | `Escape`        | (B)          | (X)        |


Consider changing Default Click Action for MKB = ENTER key


## 6. 通用操作数据表(Universal Actions Data Table)
`DT_UniversalActions` : public `CommonInputActionDataBase` from `CommonUI`

此数据表列出了 Common UI 将对其作出反应的输入操作。

*(这里定义了一些东西，我不确定它们为什么在这里。也许它们被使用，也许没有。需要深入研究 Lyra 才能找出答案。)*

The two that are **definitely** used are `DefaultForward` and `DefaultBack`.


## 7 项目设置: `Plugins` / `Common UI Editor`

这里有一些设置可以配置项目的默认文本、按钮和边框样式。

| Default Style | Asset                                                 |
|---------------|-------------------------------------------------------|
| Text          | `Content/UI/Foundation/Text/TextStyle-Regular`        |
| Border        | *(None)*                                              |
| Button        | `Content/UI/Foundation/Buttons/ButtonStyle-Primary-M` |
