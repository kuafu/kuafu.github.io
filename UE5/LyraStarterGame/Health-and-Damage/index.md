---
title: "LyraStarterGame Health and Damage System"
description: "Overview of how to heal or damage things in UE5 LyraStarterGame"
breadcrumb_path: "UE5/LyraStarterGame"
breadcrumb_name: "Health and Damage"
---

# 1 Lyra 生命值和伤害(Health and Damage)

有关此信息的overview视频 [Lyra Health and Damage System](https://youtu.be/HwQ7BrLVfJI)
: [XistGG](https://www.youtube.com/c/XistGG).

从本质上讲，Lyra 的生命值和伤害系统基于游戏能力系统 (GAS)。即使你使用Lyra，在其他工程中使用GAS给角色处理生命并、伤害或治疗，这个做法也会与Lyra中的做法非常相似。

在 Lyra 游戏中，任何想要拥有生命并可能受到伤害或治疗的角色（actor/pawn/character）都必须具有有效的、正确初始化的`AbilitySystemComponent`(ASC)，并且必须具有`LyraHealthSet`GAS 属性集。

虽然从技术上讲`LyraCombatSet`是可选的并且默认为零值，但如果参与者没有明确具有`LyraCombatSet`，Lyra 将输出警告日志。因此，除了可以消灭警告消息，实际上也需要`LyraCombatSet`。

因此，`LyraCombatSet`` 实际上是必需的，即使只是为了消除警告消息。（如果您复制/重构了 Lyra 伤害/治疗计算，您可以删除对战斗集的需要）。
hus, a `LyraCombatSet` is practically required as well, if for no reason other than to
squelch the warning messages. (If you duplicate/refactor the Lyra Damage/Heal Calculations, you can remove the requirement for a combat set if you prefer).

Therefore by default in Lyra, to give an actor/pawn/character health, so you can damage or heal it, your actor must have:
因此，在 Lyra 中默认情况下要给予角色(actor/pawn/character)生命值，以便你可以伤害或治疗它，你的角色必须具备：

- Lyra ASC (`ULyraAbilitySystemComponent`)  
  -允许角色使用GAS
- Lyra Health Set (`ULyraHealthSet`)
  - 定义角色的生命属性
- Lyra Combat Set (`ULyraCombatSet`)
  - 定义角色的战斗能力 (基础治疗和伤害值)

尽管不是严格要求的，但还需要添加另一个有用的组件：
- Lyra 生命组件 (`ULyraHealthComponent`)
  - 可以更轻松地读取蓝图中的health信息并处理health变化事件


## 1.1 以Lyra Character为例

默认情况下，Epic 构建了`ALyraCharacter`基类使其具有 ASC、生命值集和战斗集。因此，只要您的角色基于`ALyraCharacter` ，那么使用角色就非常容易。`ALyraCharacter`是相当复杂的，所以它并不是一个很好的例子来展示生命值和伤害在Lyra中的具体作用。

Epic 还提供了一个 C++ 类`ALyraCharacterWithAbilities`，该类未在任何官方 Lyra 代码中使用，但他们确实使用它来制作目标假人来测试 Lyra 武器。然而，最终这仍然是一个角色，并且它是基于`ALyraCharacter`的，所以同样，它并没有给出一个非常清晰的例子。

# 2 XCL Actor with Abilities

In my `XCL` plugin I've made a class `AXCLActorWithAbilities`.  This was inspired by Lyra's `ALyraCharacterWithAbilities`.

The XCL Actor with Abilities is the simplest possible example of an actor that can participate in GAS.

It does not have any health information.  It cannot be damaged or healed.  It does have
an ASC, so you can give it abilities or attributes as needed.

Why would you want this?  Maybe you want some actor in the world that doesn't have any health, but it still has abilities.  Maybe this is an in-game interactive computer terminal.  You want to be able to use it, but not kill it.  This would be your base for such an actor.


# 3 XCL Actor with Abilities and Health

The next step then is to take an XCL Actor with Abilities and add a Health Set, a Combat Set
and an optional but useful `ULyraHealthComponent` to it.

We derive from XCL Actor with Abilities, and we add these components, and the result is
`AXCLActorWithAbilitiesAndHealth`.

Now this actor has health and combat capabilities.  You can heal it or damage it by applying
GAS Gameplay Effects.  If you damage it enough, it will die.


## 3.1 How do I Damage it !?

To damage the actor, apply a Gameplay Effect that increases the `Damage` attribute
of the actor's `HealthSet`.  When it executes, it will decrease the `Health` by the `Damage`
amount (down to a minimum of zero).

An example Gameplay Effect that damages an actor is `GE_Damage_Basic_Instant`.

For more details, see `GE_Damage_Basic_Instant` and read the code for `ULyraDamageExecution`
which is what actually applies the damage effect in Lyra.


## 3.2 How do I Kill it !?

At zero health, the Health Set will fire off its `OnOutOfHealth` event.

**It is your responsibility to listen for this event and kill off your actor.**

Because we added the optional but useful `ULyraHealthComponent` to our actor,
it hooks into the `OnOutOfHealth` event and translates it into a series of related,
derivative events:

- A `GameplayEvent.Death` Gameplay Event is sent to the now-pending-death Actor's ASC
- A `Lyra.Elimination.Message` message is broadcast to the Gameplay Message Subsystem
  - This includes info like which actor died and who killed them

Note that there are some TODO notes in the `ULyraHealthComponent` with some ideas for how
those events could be improved.  You may be interested to do some of that, or add your
own logic there instead.

In Lyra, player and AI characters are injected with the `GA_Hero_Death` ability on spawn.
This ability triggers on `GameplayEvent.Death` events related to its owning actor, and
calls `HealthComponent`🡒`StartDeath`, which initiates the procedure of killing the actor.

Listen for the Health Component's `OnDeathStarted` event, and start to kill your actor/pawn/character
when that event fires.  By the time `OnDeathFinished` fires, the actor should be dead, as it is
being forcefully removed from the world probably on the next tick.

Lyra listens for this component's event in its `B_Hero_Default` (one of the Lyra Character
base BPs) event graph.

For more info RE `B_Hero_Default`'s handling of the Health Component's `OnDeathStarted`
event, and Lyra's base characters in general, see
[Deep Dive: Lyra’s Shooter Mannequin](/UE5/LyraStarterGame/ShooterMannequin).

###### Lyra's `B_Hero_Default` Event Graph

![OnDeathStarted.png](./screenshots/B_Hero_Default__EventGraph__OnDeathStarted.png)


## 3.3 How do I Heal it !?

To heal the actor, apply a Gameplay Effect that increases the `Healing` attribute
of the actor's `HealthSet`.  When it executes, it will increase the `Health` by the `Healing`
amount (up to `MaxHealth`).

An example Gameplay Effect that heals an actor is `GE_Heal_Instant`.

For more details, see `GE_Heal_Instant` and read the code for `ULyraHealExecution` which
is what actually applies the healing effect in Lyra.


# 4 Example Code

I've published some example code to help with this.  This code WILL NOT COMPILE.
The point is not for this to be plug and play for you.  The point is to be an example
of how you can do this yourself.

- [
[h](https://github.com/x157/Lyra-ActorWithAbilities/blob/main/Source/XCL/XCLActorWithAbilities.h)
|
[cpp](https://github.com/x157/Lyra-ActorWithAbilities/blob/main/Source/XCL/XCLActorWithAbilities.cpp)
]
`AXCLActorWithAbilities`
- [
[h](https://github.com/x157/Lyra-ActorWithAbilities/blob/main/Source/XCL/XCLActorWithAbilitiesAndHealth.h)
|
[cpp](https://github.com/x157/Lyra-ActorWithAbilities/blob/main/Source/XCL/XCLActorWithAbilitiesAndHealth.cpp)
]
`AXCLActorWithAbilitiesAndHealth`
- [
[h](https://github.com/x157/Lyra-ActorWithAbilities/blob/main/Source/XCL/XCLTargetDummyHealthSet.h)
|
[cpp](https://github.com/x157/Lyra-ActorWithAbilities/blob/main/Source/XCL/XCLTargetDummyHealthSet.cpp)
]
`UXCLTargetDummyHealthSet`
- [
[h](https://github.com/x157/Lyra-ActorWithAbilities/blob/main/Source/XCL/XCLTargetDummyActor.h)
|
[cpp](https://github.com/x157/Lyra-ActorWithAbilities/blob/main/Source/XCL/XCLTargetDummyActor.cpp)
]

`AXCLTargetDummyActor`

As described here, `AXCLActorWithAbilities` and `AXCLActorWithAbilitiesAndHealth` should pose no surprises at all.

`UXCLTargetDummyHealthSet` is a simple derivation of `ULyraHealthSet` with the only difference being that I never allow the `Health` attribute to drop below `1`.  In this way, the Target Dummy will never die, and I can hit it as many times as I want.

`AXCLTargetDummyActor` is a derivation of `AXCLActorWithAbilitiesAndHealth`.  It adds a skeletal mesh and it defines the override of `UXCLTargetDummyHealthSet` in the `ObjectInitializer` that it passes to its `Super` (`AXCLActorWithAbilitiesAndHealth`).

Thus, the Target Dummy has health and can be damaged and healed, but it can never die, because of the special overridden Health Set it uses which does not allow Health to drop to zero.


# 5 What this looks like in Editor

![Target Dummy BP](./screenshots/TargetDummyBP.png)

Red numbers highlight the vital components:

1. Ability System Component
2. Health Set 
3. Combat Set
4. Health Component

The Health Set has a red arrow showing that the default value is the `XCL Target Dummy Health Set`,
which is as we expect given the code.

There are a few things you see here that aren't in the example.
These do not affect damage or healing:

- The `XCLActorWidget` is the health bar widget in the video example.
- The `Interaction Component` is an XCL Interaction Component which allows the player of my game to interact with this actor.

The `AS_XAI_TargetDummy` asset shown there is a Lyra Ability Set.  The only thing defined there
is a Gameplay Effect that is a periodic +20 Health/second heal.  That way when I send my Target Dummy
down to `1` HP, it fully regenerates in 5 seconds.


# 6 Summary

You have a HUGE amount of control over how these calculations are done and what the resulting
values are.  To exercise this control, you must learn GAS, in particular:

Gameplay Attributes are what defines the actor's health (or shields, or mana, or whatever),
and Gameplay Effects are how you modify those values during game play.

- [Attributes and Attribute Sets](https://docs.unrealengine.com/5.0/en-US/gameplay-attributes-and-attribute-sets-for-the-gameplay-ability-system-in-unreal-engine/) (Epic Documentation)
- [Attributes and Gameplay Effects](https://docs.unrealengine.com/5.0/en-US/gameplay-attributes-and-gameplay-effects-for-the-gameplay-ability-system-in-unreal-engine/) (Epic Documentation)

Attributes can contain **way more info** than just the health.

Making something "be alive" is only the beginning.  `:-)`
