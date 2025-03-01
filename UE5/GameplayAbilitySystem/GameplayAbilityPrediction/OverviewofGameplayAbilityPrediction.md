# GameplayPrediction.h 注释翻译

## 概述

### 游戏能力预测概述

#### 高层次目标

在 GameplayAbility 层面（实现能力）上，预测是透明的。一个能力说“执行 X->Y->Z”，我们会自动预测其中可以预测的部分。我们希望避免在能力本身中出现“如果是 Authority：执行 X。否则：执行 X 的预测版本”这样的逻辑。

目前，并非所有情况都已解决，但我们已经有了一个非常坚实的客户端预测框架。

当我们说“客户端预测”时，我们实际上是指客户端预测游戏模拟状态。某些事情仍然可以“完全在客户端”进行，而无需在预测系统中工作。例如，脚步声完全在客户端处理，从不与此系统交互。但客户端预测他们在施放法术时法力值从 100 变为 90 是“客户端预测”。

#### 我们目前预测什么？

- 初始 GameplayAbility 激活（以及有条件的链式激活）
- 触发事件
- GameplayEffect 应用：
  - 属性修改（例外：执行不预测，仅属性修改器）
  - GameplayTag 修改
- Gameplay Cue 事件（既来自预测的 gameplay effect，也可以单独存在）
- 动作
- 移动（内置于 UE UCharacterMovement 中）

#### 我们不预测的一些事情（大多数这些我们可能可以预测，但目前没有）：

- GameplayEffect 移除
- GameplayEffect 周期性效果（如持续伤害）

#### 我们试图解决的问题：

1. “我能做这个吗？”预测的基本协议。
2. “撤销”如何在预测失败时撤销副作用。
3. “重做”如何避免重放我们在本地预测但也从服务器复制的副作用。
4. “完整性”如何确保我们/真正/预测了所有副作用。
5. “依赖性”如何管理依赖预测和预测事件链。
6. “覆盖”如何预测性地覆盖由服务器复制/拥有的状态。

## 实现细节

### PredictionKey

该系统中的一个基本概念是预测键（FPredictionKey）。预测键本身只是一个在客户端生成的唯一 ID。客户端将其预测键发送到服务器，并将预测动作和副作用与此键关联。服务器可以响应接受/拒绝预测键，并且还会将服务器端创建的副作用与此预测键关联。

（重要）FPredictionKey 始终从客户端 -> 服务器复制，但在从服务器 -> 客户端复制时，它们*仅*复制到最初将预测键发送到服务器的客户端。这发生在 FPredictionKey::NetSerialize 中。当从客户端发送的预测键通过复制属性复制回下来的时候，所有其他客户端将收到一个无效（0）的预测键。

### 能力激活

能力激活是一个一等预测动作——它生成一个初始预测键。每当客户端预测性地激活一个能力时，它会显式地请求服务器，服务器会显式地响应。一旦能力被预测性地激活（但请求尚未发送），客户端就有一个有效的“预测窗口”，在此期间可以发生预测副作用，而无需显式“询问”。（例如，我们不会显式询问“我可以减少法力值吗，我可以将此能力置于冷却状态吗”。这些动作被认为是与激活能力逻辑上原子的）。你可以将此预测窗口视为 ActivateAbility 的初始调用栈。一旦 ActivateAbility 结束，你的预测窗口（因此你的预测键）就不再有效。这很重要，因为许多事情可以使你的预测窗口无效，例如任何计时器或蓝图中的潜在节点；我们不会跨帧预测。

AbilitySystemComponent 提供了一组用于在客户端和服务器之间通信能力激活的函数：TryActivateAbility -> ServerTryActivateAbility ->  ClientActivateAbility(Failed/Succeed)。

1. 客户端调用 TryActivateAbility，生成一个新的 FPredictionKey 并调用 ServerTryActivateAbility。
2. 客户端继续（在听到服务器的回应之前）并调用 ActivateAbility，将生成的 PredictionKey 与能力的 ActivationInfo 关联。
3. 在调用 ActivateAbility 结束之前发生的任何副作用都与生成的 FPredictionKey 关联。
4. 服务器决定能力是否真的发生在 ServerTryActivateAbility 中，调用 ClientActivateAbility(Failed/Succeed) 并将 UAbilitySystemComponent::ReplicatedPredictionKey 设置为客户端发送请求时使用的键。
5. 如果客户端收到 ClientAbilityFailed，它会立即终止能力并回滚与预测键关联的副作用。
   - “回滚”逻辑通过 FPredictionKeyDelegates 和 FPredictionKey::NewRejectedDelegate/NewCaughtUpDelegate/NewRejectOrCaughtUpDelegate 注册。
   - ClientAbilityFailed 是我们“拒绝”预测键的唯一情况，因此我们当前的所有预测都依赖于能力是否激活。
6. 如果 ServerTryActivateAbility 成功，客户端必须等待属性复制赶上（Succeed RPC 将立即发送，属性复制将自行发生）。一旦 ReplicatedPredictionKey 赶上前面步骤中使用的键，客户端可以撤销其本地预测的副作用。
   - 请参阅 FReplicatedPredictionKeyItem::OnRep 了解 CatchUpTo 逻辑。请参阅 UAbilitySystemComponent::ReplicatedPredictionKeyMap 了解键的实际复制方式。请参阅 ~FScopedPredictionWindow 了解服务器确认键的方式。

### GameplayEffect 预测

GameplayEffects 被视为能力激活的副作用，不单独接受/拒绝。

1. 只有在有有效的预测键时才会在客户端应用 GameplayEffects。（如果没有预测键，它会简单地跳过客户端的应用）。
2. 如果 GameplayEffect 被预测，属性、GameplayCues 和 GameplayTags 都会被预测。
3. 当 FActiveGameplayEffect 创建时，它会存储预测键（FActiveGameplayEffect::PredictionKey）
   - 瞬时效果在“属性预测”中解释。
4. 在服务器上，相同的预测键也会设置在服务器的 FActiveGameplayEffect 上，并会复制下来。
5. 作为客户端，如果你得到一个带有有效预测键的复制 FActiveGameplayEffect，你会检查是否有一个带有相同键的 ActiveGameplayEffect，如果有匹配，我们不会应用“应用时”的逻辑，例如 GameplayCues。这解决了“重做”问题。然而，我们的 ActiveGameplayEffects 容器中会暂时有两个“相同”的 GameplayEffects：
6. 同时，FPredictionKeyItem::OnRep 将赶上并移除预测效果。在这种情况下移除时，我们再次检查 PredictionKey 并决定是否不应该执行“移除时”逻辑/GameplayCue。

此时，我们有效地预测了一个作为副作用的 gameplay effect，并处理了“撤销”和“重做”问题。

- 请参阅 FActiveGameplayEffectsContainer::ApplyGameplayEffectSpec 了解它如何注册在赶上时要做的事情（RemoveActiveGameplayEffect_NoReturn）。
- 请参阅 FActiveGameplayEffect::PostReplicatedAdd、FActiveGameplayEffect::PreReplicatedRemove 和 FActiveGameplayCue::PostReplicatedAdd 了解 FPredictionKey 如何与 GE 和 GC 关联。

### 属性预测

由于属性作为标准 uproperties 复制，预测它们的修改可能会很棘手（“覆盖”问题）。瞬时修改可能更难，因为它们本质上是无状态的。（例如，如果没有修改后的记录，回滚属性修改是困难的）。这使得“撤销”和“重做”问题在这种情况下也很难。

基本的解决方案是将属性预测视为增量预测而不是绝对值预测。我们不预测我们有 90 法力值，我们预测我们从服务器值减少了 10 法力值，直到服务器确认我们的预测键。基本上，将瞬时修改视为/无限持续时间修改/，在预测时对属性进行修改。这解决了“撤销”和“重做”问题。

对于“覆盖”问题，我们可以在属性的 OnRep 中处理，通过将复制的（服务器）值视为属性的“基值”而不是“最终值”，并在复制发生后重新聚合我们的“最终值”。

1. 我们将预测的瞬时 gameplay effects 视为无限持续时间的 gameplay effects。请参阅 UAbilitySystemComponent::ApplyGameplayEffectSpecToSelf。
2. 我们必须*始终*接收属性上的 RepNotify 调用（不仅仅是当有变化时，因为我们会提前预测变化）。通过 REPNOTIFY_Always 完成。
3. 在属性 RepNotify 中，我们调用 AbilitySystemComponent::ActiveGameplayEffects 以根据新的“基值”更新我们的“最终值”。GAMEPLAYATTRIBUTE_REPNOTIFY 可以做到这一点。
4. 其他一切将像上面（GameplayEffect 预测）一样工作：当预测键赶上时，预测的 GameplayEffect 将被移除，我们将返回服务器给定的值。

#### 示例

void UMyHealthSetGetLifetimeReplicatedProps(TArray< FLifetimeProperty > & OutLifetimeProps) const { SuperGetLifetimeReplicatedProps(OutLifetimeProps);
DOREPLIFETIME_CONDITION_NOTIFY(UMyHealthSet, Health, COND_None, REPNOTIFY_Always);
}
void UMyHealthSet::OnRep_Health() { GAMEPLAYATTRIBUTE_REPNOTIFY(UMyHealthSet, Health); }


### Gameplay Cue 事件

除了已经解释的 GameplayEffects，Gameplay Cues 可以单独激活。这些函数（UAbilitySystemComponent::ExecuteGameplayCue 等）考虑了网络角色和预测键。

1. 在 UAbilitySystemComponent::ExecuteGameplayCue 中，如果是 authority，则执行多播事件（带有复制键）。如果不是 authority，但有有效的预测键，则预测 GameplayCue。
2. 在接收端（NetMulticast_InvokeGameplayCueExecuted 等），如果有复制键，则不执行事件（假设你预测了它）。

请记住，FPredictionKeys 仅复制到原始所有者。这是 FReplicationKey 的固有属性。

### 触发数据预测

触发数据目前用于激活能力。本质上，这一切都通过与 ActivateAbility 相同的代码路径。与从输入按下激活能力不同，它是从另一个游戏代码驱动的事件激活的。客户端能够预测性地执行这些事件，从而预测性地激活能力。

然而，这有一些细微差别，因为服务器也会运行触发事件的代码。服务器不会只是等待听到客户端的消息。服务器将保留一个触发能力的列表，这些能力已被预测性地激活。当接收到来自触发能力的 TryActivate 时，服务器将查看它是否已经运行了此能力，并响应该信息。

问题是我们没有正确回滚这些操作。触发事件和复制还有待解决的工作（在结尾解释）。

### 高级主题

#### 依赖性

我们可能会遇到这样的情况：“能力 X 激活并立即触发一个事件，该事件激活能力 Y，该事件又触发另一个能力 Z”。依赖链是 X->Y->Z。每个这些能力都可能被服务器拒绝。如果 Y 被拒绝，那么 Z 也不会发生，但服务器不会显式决定“Z 不能运行”。

为了解决这个问题，我们有一个基本预测键的概念，这是 FPredictionKey 的成员。在调用 TryActivateAbility 时，我们传入当前的预测键（如果适用）。该预测键用作生成任何新预测键的基础。我们通过这种方式构建键链，然后如果 Y 被拒绝，我们可以使 Z 无效。

这稍微复杂一些。在 X->Y->Z 的情况下，服务器在尝试自己运行链之前只会收到 X 的预测键。例如，它将使用客户端发送的原始预测键尝试激活 Y 和 Z，而客户端在每次调用 TryActivateAbility 时都会生成一个新预测键。客户端*必须*为每次能力激活生成一个新预测键，因为每次激活在逻辑上不是原子的。事件链中产生的每个副作用都必须有一个唯一的预测键。我们不能让 X 中产生的 GameplayEffects 与 Z 中产生的预测键相同。

为了解决这个问题，X 的预测键被视为 Y 和 Z 的基础键。Y 到 Z 的依赖关系完全在客户端保持，这是通过 FPredictionKeyDelegates::AddDependancy 完成的。我们添加委托以在 Y 被拒绝/确认时拒绝/赶上 Z。

这个依赖系统允许我们在单个预测窗口/范围内拥有多个非逻辑原子的预测动作。

但有一个问题：因为依赖关系在客户端保持，服务器实际上不知道它是否之前拒绝了一个依赖动作。你可以通过使用游戏能力中的激活标签来设计解决这个问题。例如，当预测依赖 GA_Combo1 -> GA_Combo2 时，你可以使 GA_Combo2 仅在具有 GA_Combo1 赋予的 GameplayTag 时激活。因此，GA_Combo1 的拒绝也会导致服务器拒绝 GA_Combo2 的激活。

#### 能力中的额外预测窗口

如前所述，预测键仅在单个逻辑范围内可用。一旦 ActivateAbility 返回，我们基本上就完成了该键。如果能力在等待外部事件或计时器，当我们准备继续执行时，可能已经收到了服务器的确认/拒绝。因此，初始激活后产生的任何额外副作用都不能再与原始键的生命周期相关联。

这并不糟糕，除非能力有时想要响应玩家输入。例如，“按住并充能”能力希望在按钮释放时立即预测一些东西。可以使用 FScopedPredictionWindow 在能力中创建一个新的预测窗口。

FScopedPredictionWindows 提供了一种方法，可以向服务器发送一个新的预测键，并让服务器在同一逻辑范围内使用该键。

UAbilityTask_WaitInputRelease::OnReleaseCallback 是一个很好的示例。事件流程如下：

1. 客户端进入 UAbilityTask_WaitInputRelease::OnReleaseCallback 并启动一个新的 FScopedPredictionWindow。这为此范围创建了一个新的预测键（FScopedPredictionWindow::ScopedPredictionKey）。
2. 客户端调用 AbilitySystemComponent->ServerInputRelease，传递 ScopedPrediction.ScopedPredictionKey 作为参数。
3. 服务器运行 ServerInputRelease_Implementation，接受传入的 PredictionKey，并将其设置为 UAbilitySystemComponent::ScopedPredictionKey，带有 FScopedPredictionWindow。
4. 服务器在同一范围内运行 UAbilityTask_WaitInputRelease::OnReleaseCallback。
5. 当服务器在 ::OnReleaseCallback 中命中 FScopedPredictionWindow 时，它从 UAbilitySystemComponent::ScopedPredictionKey 获取预测键。现在，该键用于此逻辑范围内的所有副作用。
6. 一旦服务器结束此范围的预测窗口，使用的预测键完成并设置为 ReplicatedPredictionKey。
7. 在此范围内创建的所有副作用现在在客户端和服务器之间共享一个键。

这工作的关键是：：OnReleaseCallback 调用：：ServerInputRelease，后者调用：：OnReleaseCallback 在服务器上。没有空间让其他事情发生并使用给定的预测键。

虽然在此示例中没有“尝试/失败/成功”调用，但所有副作用都是程序性分组/原子的。这解决了在服务器和客户端上运行的任何任意函数调用的“撤销”和“重做”问题。

### 不支持/问题/待办事项

触发事件不会显式复制。例如，如果触发事件仅在服务器上运行，客户端将永远不会听到它。这也阻止我们进行跨玩家/AI 等事件。最终应添加对此的支持，并应遵循 GameplayEffect 和 GameplayCues 的相同模式（预测触发事件，带有预测键，如果有预测键，则忽略 RPC 事件）。

这个系统的一个大问题：目前无法回滚任何链式激活（包括触发事件）。原因是每个 ServerTryActivateAbility 将按顺序响应。让我们将依赖 GA 链作为示例：GA_Mispredict -> GA_Predict1。在此示例中，当 GA_Mispredict 激活并在本地预测时，它会立即激活 GA_Predict1。客户端发送 ServerTryActivateAbility 用于 GA_Mispredict，服务器拒绝它（发送回 ClientActivateAbilityFailed）。如现状，我们没有任何委托来拒绝客户端上的依赖能力（服务器甚至不知道有依赖关系）。在服务器上，它也会接收 GA_Predict1 的 ServerTryActivateAbility。假设成功，客户端和服务器现在都在执行 GA_Predict1，即使 GA_Mispredict 从未发生。你可以通过使用标签系统来设计解决这个问题，以确保 GA_Mispredict 成功。

### 预测“元”属性（如伤害/治疗）与“真实”属性（如健康）

我们无法预测性地应用元属性。元属性仅在 GameplayEffect 的后端（UAttributeSet 上的 Pre/Post Modify Attribute）上工作。这些事件在应用基于持续时间的 gameplay effects 时不会被调用。例如，一个修改伤害 5 秒的 GameplayEffect 没有意义。

为了支持这一点，我们可能会添加一些有限的支持，用于基于持续时间的元属性，并将瞬时 gameplay effect 的转换从前端（UAbilitySystemComponent::ApplyGameplayEffectSpecToSelf）移动到后端（UAttributeSet::PostModifyAttribute）。

### 预测持续的乘法 GameplayEffects

在预测基于百分比的 gameplay effects 时也有一些限制。由于服务器复制下来的属性的“最终值”，而不是修改它的整个聚合链，我们可能会遇到客户端无法准确预测新 gameplay effects 的情况。

例如：

- 客户端有一个永久 +10% 移动速度增益，基础移动速度为 500 -> 550 是此客户端的最终移动速度。
- 客户端有一个能力，授予额外的 10% 移动速度增益。预计将*总和*百分比乘数，最终 20% 奖励为 500 -> 600 移动速度。
- 然而在客户端，我们只是将 10% 增益应用于 550 -> 605。

这需要通过复制属性的聚合链来修复。我们已经复制了一些数据，但不是完整的修改器列表。我们需要研究如何支持这一点。

### “弱预测”

我们可能仍然会有一些不适合此系统的情况。有些情况下，预测键交换不可行。例如，一个能力，任何与玩家碰撞/接触的人都会收到一个减速并使其材质变蓝的 GameplayEffect。由于我们不能每次发生这种情况时都发送服务器 RPC（服务器不一定能够处理此时