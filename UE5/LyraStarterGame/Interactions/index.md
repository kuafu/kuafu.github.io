---
title: LyraStarterGame Interaction System
description: Overview of the interaction system in LyraStarterGame
back_links:
    - link: /UE5/
      name: UE5
    - link: /UE5/LyraStarterGame/
      name: LyraStarterGame
back_link_title: Interactions
---

# LyraStarterGame 交互系统

参考视频 [YouTube Video: UE5 LyraStarterGame Prototype Interaction System](https://youtu.be/jm0qX5KkLQs) which covers this topic.

官方文档[Official UE5 Lyra Interaction Docs](https://docs.unrealengine.com/5.0/en-US/lyra-sample-game-interaction-system-in-unreal-engine/) 绝对值得一读。然而，在我看来，这些文档显然是由一个对 Lyra 和 Unreal Engine 了解比我多得多的人编写的，因此他们省略了我必须自己找出的大量信息，以真正理解 Lyra 交互系统的工作原理。

Lyra 自带了一个部分实现的原型库存系统。这个库存系统基于 Lyra 交互系统，并在一个 PROTO 目录中展示，以突显它需要一些工作才能使用。

这似乎是深入研究 Lyra 交互的好地方，以了解它们是如何组合在一起的。我从这个练习中的发现如下。

如果您想跳到前面并自己体验 Epic 的库存原型，请查看 如何体验 Epic 的库存原型[How to Experience Epic's Inventory Prototype](#How_to_Experience_Epics_Inventory_Prototype) 部分。

### 完全实现：自动邻近交互(Automatic Proximity Interaction)

截至 UE 5.0.2，Epic 完全实现的唯一类型的交互是，玩家和对象之间只有一种可能的交互，并且该交互是基于玩家与对象的邻近触发的。

例如，对象可能会给您一个武器，或者将您传送到地图的另一部分，或者在您靠近时对您造成伤害或治疗。

如果您不需要以其他方式与对象交互的能力，那么对您而言，Lyra 是完全功能的。

### 部分实现：由玩家启动的单一交互

这是我们在这里讨论的库存原型的主题。

与自动交互的区别在于，在这种情况下，能力不会自动激活，而是等待玩家选择性地激活它。

例如，玩家可以选择切换一个开关，或者就像 Epic 为我们提供的案例中那样，拾起一个石头。


### NOT Implemented: Multiple Interaction Options

If you want to give your player options, like *either* opening a door *or* locking it *or* booby-trapping it *or* insert-your-idea-here, then you will need to extend Lyra to add this functionality.

There is currently no code in Lyra that will allow you to do this, but there is a good starting point that should hopefully not be too difficult to extend.


# Key Concepts

The key concepts you must understand to implement an interaction system that your player chooses when to activate:

- [Gameplay Ability: `GA_Interact`](#GA_Interact)
  - Constantly scans the area around the player for Interactable objects
  - Grants the player other abilities based on the interactables nearby
- [Interactable Object: `B_InteractableRock`](#B_InteractableRock)
  - Example of an interactable object;
    an inert rock the player can interact with to pick it up
- [Gameplay Ability: `GA_Interaction_Collect`](#GA_Interaction_Collect)
  - The ability granted to the player when they are near a rock
  - When the user interacts with the rock, this ability removes the rock
    from the world and places it in the player's inventory


<a id="GA_Interact"></a>
## Gameplay Ability: GA_Interact

Path: `ShooterMaps`/`PROTO`/`InventoryTest`/`Input`/`Abilities`/`GA_Interact`

This ability is granted to the `PlayerState`.  This is what allows the player to interact with objects in the game.

You'll need to grant this ability to your player.  Lyra's prototype does this as follows:

- `B_TestInventoryExperience` add action set:
    - `LAS_InventoryTest` add ability set to `ALyraPlayerState`:
        - `AbilitySet_InventoryTest` add ability:
            - `GA_Interact`

The `ActivateAbility` implementation for this Gameplay Ability:

- Start a [`UAbilityTask_GrantNearbyInteraction`](#UAbilityTask_GrantNearbyInteraction) Gameplay Task *(via the base C++ class, see below)*
- Start a [`UAbilityTask_WaitForInteractableTargets_SingleLineTrace`](#UAbilityTask_WaitForInteractableTargets_SingleLineTrace) Gameplay Task
- Start async loop listening for interaction input key presses

These 3 asynchronous tasks work together to allow interactions to occur. Any time the player gets near an interactable object, the player is granted whatever abilities that interactable object provides (such as "pick me up") by [`UAbilityTask_GrantNearbyInteraction`](#UAbilityTask_GrantNearbyInteraction).

If the player looks at an object and presses the input key while near enough to it, the granted ability is activated (for example the item is removed from the world and placed into the player's inventory) by [`UAbilityTask_WaitForInteractableTargets_SingleLineTrace`](#UAbilityTask_WaitForInteractableTargets_SingleLineTrace).

The key press is detected in the `GA_Interact` event graph.


<a id="ULyraGameplayAbility_Interact"></a>
### Base C++ Class: `ULyraGameplayAbility_Interact`

`GA_Interact` uses `ULyraGameplayAbility_Interact` as its base C++ class.

The base class sets itself to activate on spawn, meaning that this ability automatically activates as soon as it is granted to the player.  It also uses the `LocalPredicted` `NetExecutionPolicy`, so it runs on both the client
and the server.

A [`UAbilityTask_GrantNearbyInteraction`](#UAbilityTask_GrantNearbyInteraction) Gameplay Task is immediately created on the server.


<a id="UAbilityTask_GrantNearbyInteraction"></a>
### Gameplay Task: `UAbilityTask_GrantNearbyInteraction`

This task sets a recurring timer to scan for interactable objects in a sphere around the player every X interval (configurable; default 0.1 seconds).

Each time it scans, it looks for objects that implement the `IInteractableTarget` interface.  This interface may be implemented by either the actor itself or by one of its components that was hit by the `OverlapMultiByChannel` sphere trace.

The sphere trace uses the `Lyra_TraceChannel_Interaction` channel, which is an alias to `ECC_GameTraceChannel1`.

Thus for an object to be interactable, it or one of its components must implement `IInteractableTarget` AND it must overlap with ray traces on `Lyra_TraceChannel_Interaction`.

The task constructs a list of all `FInteractionOption` for all interactable objects detected in each sphere trace. For every `FInteractionOption` detected, it then grants the `PlayerState` whatever Gameplay Ability is defined by that option.

#### Network Gameplay Note

The [Official Lyra Interaction System Docs](https://docs.unrealengine.com/5.0/en-US/lyra-sample-game-interaction-system-in-unreal-engine/)
states:

    You can increase the InteractionScanRate float to be at a larger radius than your InteractionRange, otherwise, replication will not deliver the ability to the client soon enough.

This is a typo.  They intended to say you should increase the `InteractionScanRange` (**Range**, not Rate) to be larger than the `InteractionRange`.

In the prototype sample, Epic is using 500cm as the `InteractionScanRange`, compared to only 200cm for the `InteractionRange`. So the Lyra prototype uses a 2.5x increase in the scan range compared to the activation range.

`InteractionScanRange` is set in `LyraGameplayAbility_Interact.h`, while `InteractionRange` is set in the `GA_Interact` invocation of `Wait for Interactable Targets Single Line Trace`.


<a id="UAbilityTask_WaitForInteractableTargets_SingleLineTrace"></a>
### Gameplay Task: `UAbilityTask_WaitForInteractableTargets_SingleLineTrace`

This task sets a recurring timer to scan for the first interactable object in front of the player within interaction range. It executes by default every 0.1 seconds on a timer.

This is configured in `GA_Interact` on construction to use the `Interactable_BlockDynamic` line trace profile, which is defined in `DefaultEngine.ini` to overlap `WorldDynamic` objects with `Lyra_TraceChannel_Interaction`.

Any time the interactable object changes (either to or from a valid value), the base Gameplay Task class `UAbilityTask_WaitForInteractableTargets` broadcasts the `InteractableObjectsChanged` delegate, which `GA_Interact` uses to determine which interaction option is currently available to the player, if any.


<a id="B_InteractableRock"></a>
## Interactable Object: `B_InteractableRock`

Path: `ShooterMaps`/`PROTO`/`InventoryTest`/`B_InteractableRock`

This is a simple object that the user can pick up and add to their inventory.

### Rock Collection Gameplay Ability

`B_InteractableRock` defines the following settings:

- Interaction Ability to Grant = [`GA_Interaction_Collect`](#GA_Interaction_Collect)
- Item Definition = `TestID_Rock`

This sets up the rock such that when a player gets near it, the `PlayerState` will be automatically granted the [`GA_Interaction_Collect`](#GA_Interaction_Collect) Gameplay Ability.

`TestID_Rock` is a `ALyraInventoryItemDefinition`.  It determines what will be placed in the player's inventory if the rock is picked up. In this case, 1 rock.

This doesn't actually give the rock to the player, it just makes it possible for the player to collect the rock if the player interacts with it.

### Mesh Collision

The rock's static mesh has a custom collision profile such that it is set to overlap with `Lyra_TraceChannel_Interaction`.

This is required so that the rock will be visible to the
<a href="#UAbilityTask_GrantNearbyInteraction">interaction detection trace</a>.


### Base C++ Class: `ALyraWorldCollectable`

`ALyraWorldCollectable` implements the `IInteractableTarget` and `IPickupable` interfaces.

This is a very simple C++ class, all it does is define a Gameplay Ability and an Item ID that are intended to be assigned in Blueprints for each type of item that the user should be able to pick up and put in their inventory.


<a id="GA_Interaction_Collect"></a>
## Gameplay Ability: `GA_Interaction_Collect`

This Gameplay Ability is granted to the `PlayerState` by an interactable object, for example [`B_InteractableRock`](#B_InteractableRock). It is granted the player via [`UAbilityTask_GrantNearbyInteraction`](#UAbilityTask_GrantNearbyInteraction).

This ability is invoked from a Gameplay Event by the `GA_Interact` base class `TriggerInteraction` C++ method.  As such, it only implements the `ActivateAbilityFromEvent` Gameplay Ability event.  The event data contains the `Instigator` (the player's pawn) and `Target` (the actor the player interacted with).

When activated, this Gameplay Ability:

- Deletes the `Target` (the rock)
    - Disable collision
    - Set lifespan = 3 seconds, after which deletion occurs
- Executes Gameplay Cue: `GameplayCue.ShooterGame.Interact.Collect`
- On Server only:
    - Add a rock to `Instigator` (player) inventory via `ULyraInventoryManagerComponent`
        - Which item to add is defined by [`B_InteractableRock`](#B_InteractableRock)
- On Client only:
    - Broadcast Gameplay Message: `Ability.Interaction.Duration.Message`
        - Duration = 0.5
- Plays a pickup animation


<a id="How_to_Experience_Epics_Inventory_Prototype"></a>
# How to Experience Epic's Inventory Prototype

Path: `ShooterMaps`/`PROTO`/`InventoryTest`/`L_InventoryTestMap`

Epic has bundled the interaction and inventory systems into a single prototype map.  The inventory system is built on top of the interaction system.

In their example, you will see the possibility for a single type of interaction: pick up an item, adding it to your inventory. Unlike the other interactions in Lyra, in addition to being in close proximity to the object, this also requires the player to click an interaction button while looking at the object.

There are numerous problems with the setup of this map, the assets it uses, etc.  Hopefully Epic fixes this in a future version.  (As of 5.0.2 it is still broken).

### How to: Quick Hack without any real work

The main problem is that there are many assets that the `AssetManager` cannot locate at run time.  A quick way to get around this, purely for testing within the editor, is to simply open all of the files that are needed by the example.

Open these files in the Editor, and leave them open:

- `ShooterMaps`/`PROTO`/`InventoryTest`/`LAS_InventoryTest`
- `ShooterMaps`/`PROTO`/`InventoryTest`/`Input`/`Abilities`/`AbilitySet_InventoryTest`
- `ShooterMaps`/`PROTO`/`InventoryTest`/`Input`/`Actions`/`InputData_InventoryTest`
- `ShooterMaps`/`PROTO`/`InventoryTest`/`Input`/`Mappings`/`IMC_InventoryTest`

While you have `IMC_InventoryTest` open, you must change the default key binding for the `IA_Interact` input action. Epic set this default as `E`, but that is also used for melee attack, so there is a conflict. I changed it to `T` for demo purposes, which works. Save this change.

With these 4 files open, and the `IA_Interact` input action bound to a unique key, open the `L_InventoryTestMap` and press PIE.  Walk up to one of the big black squares (those are "rocks"), and push `T` or whatever key you mapped to `IA_Interact`.  You should see it hover over your head and disappear as it was picked up and added to your inventory.

Open Map to PIE:
`ShooterMaps`/`PROTO`/`InventoryTest`/`L_InventoryTestMap`


### How to: Actually Fix the Inventory Prototype

UE Forum user
[aFlashyRhino](https://forums.unrealengine.com/u/aFlashyRhino) revealed a detailed account of how to fix this map and its assets to be functional.  If it's still broken in the current version of Unreal Engine when you're reading this, check out Garashka's [Fixing Lyra’s Inventory System](https://garashka.github.io/LyraDocs/lyra/fixing-inventory-system) and [this related forum post](https://forums.unrealengine.com/t/lyra-proto-inventory-system-world-collectable-item-issues/569301/5?u=xi57) for more details.

If you follow that blog you should be able to get the inventory system into a functional state so you can play with it to see how Epic intended for it to be used.

Note that the prototype is nowhere near ready for you to extend and build upon, so you will absolutely want to make your own system and NOT try to use this at all.  It is quite clear that Epic does not intend for anyone to actually use this part of Lyra in its current state. It is only an example.


<br/>
<hr/>
<div class="container">
    <p> 感谢原作者 X157 &copy; 的杰出贡献！Thanks to the original author X157&copy; for his outstanding contribution!<br/>
        原始文档地址：<a href="https://x157.github.io">source</a> | <a href="https://github.com/x157/x157.github.io/issues">issues</a>
    </p>
</div>