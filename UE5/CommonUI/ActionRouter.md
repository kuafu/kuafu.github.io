---
title: "Common UI Action Router"
description: "Description of the Common UI Action Router and how to use it to manage Input Modes in your Common UI based Game."
breadcrumb_path: "UE5/CommonUI"
breadcrumb_name: "Action Router"
---

# 1 通用 UI 操作路由器(Common UI Action Router)

The Common UI Action Router is the place to route all requests to set the input mode.

**DO NOT** try to circumvent this in your own code.
Instead, have your code create Common UI `FUIInputConfig` settings and
send them to Common UI to actually do the input mode changes.

See my [Tutorial: How to Take Control of the Mouse in Lyra](/UE5/LyraStarterGame/Tutorials/How-to-Take-Control-of-the-Mouse)
for more information about how to make the input modes in your Lyra-based game
work exactly the way you want them to.

通用 UI 操作路由器是路由所有设置输入模式的请求的地方。

**请勿**尝试在您自己的代码中规避这一点。

相反，让您的代码创建通用 UI `FUIInputConfig` 设置并将它们发送到通用 UI 以实际执行输入模式更改。

有关如何使基于 Lyra 的游戏中输入模式按照您希望的方式工作的更多信息，请参阅我的 [教程：如何在 Lyra 中控制鼠标](/UE5/LyraStarterGame/Tutorials/How-to-Take-Control-of-the-Mouse)。

## 1.1 如何覆盖（override）基本 UI 操作路由器
要覆盖 `UCommonUIActionRouterBase`，您只需从中派生自己的子类。

您的派生类的存在将阻止初始化基本子系统，并且您的派生类将在您的项目中使用，而不是基本类。

这是虚幻引擎的一个小把戏。要了解其工作原理和原因，请参阅`UCommonUIActionRouterBase::ShouldCreateSubsystem`并搜索该方法的调用。


## 1.2 设置活动 UI 输入配置

```c++
void SetActiveUIInputConfig(const FUIInputConfig& NewConfig);
```

此方法是公共的，从游戏代码中调用此方法可将通用 UI 输入配置更改为您的首选值。

## 1.3 应用 UI 输入配置

```c++
virtual void ApplyUIInputConfig(const FUIInputConfig& NewConfig, bool bForceRefresh);
```

要更改游戏中输入的工作方式，您必须重写此方法。这实际上是`ActiveInputConfig`成员变量的设置器。

您的重写**不得**调用基类。相反，请完全重写它。

完成后，您可以按照自己希望的方式设置输入，使其在您的游戏中发挥作用。
