---
title: "Lyra: How to ResaveAssets for Lyra 5.1"
description: "Commands to fix Lyra 5.1 assets and improve Editor startup time"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Resave Lyra 5.1 Assets"
---


# 重新保存 Lyra 5.1 资产

Lyra 的 DDC 处理中存在一些与动画资产和粒子系统相关的错误。修复只需重新保存受影响的资产即可。

##### 设置 PowerShell 变量

```powershell
# 虚幻编辑器的路径（“-Cmd”版本）
$UnrealEd = "E:/XUE51/Engine/Binaries/Win64/UnrealEditor-Win64-Debug-Cmd.exe"

# .uproject 文件的路径
$UProject = "D:/Dev/Lyra_Xist/XistGame.uproject"
```

##### 在特定游戏内容文件夹上运行 `ResavePackages` 命令行

```powershell
& $UnrealEd $UProject -run=ResavePackages `
    -PackageFolder=/Game/Characters/Heroes/Mannequin/Animations/Locomotion/ `
    -PackageFolder=/Game/Effects/Camera/ `
    -PackageFolder=/Game/Effects/NiagaraModules/ `
    -PackageFolder=/Game/Effects/Particles/ `
    -AutoCheckOut -BatchSourceControl `
    -IgnoreChangelist -NoShaderCompile -GCFREQ=1000
```

这将自动签出（但不会签入）它重写的所有文件。这将需要一些时间，可能长达一个小时。检查更改并在您满意时将其提交到服务器。

### 关于源代码控制的说明

似乎您需要编译 Lyra、启动它并启用源代码控制以将其连接到 Perforce。否则，该命令将失败，并出现大量“无法签出文件”警告。

### 它起作用了吗？

通过运行此测试，您将知道它起作用了：

停止编辑器，重新启动它。您将看到它为所有动画和 Niagara 系统计算 DDC。*（与您启动 Lyra 时总是看到的相同内容）*。

计算完 DDC 后，再次停止编辑器，然后重新启动。这次它应该启动得更快，因为它读取 DDC，而不是总是为这些资产写入新的 DDC。

有关更多信息，请参阅 [引擎更新时重新保存资产](/UE5/Engine/Resave-Assets)。