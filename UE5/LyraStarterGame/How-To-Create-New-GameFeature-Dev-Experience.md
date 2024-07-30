---
title: How to Create a GameFeature Experience
description: Create a new GameFeature Experience including all of its prerequisite data assets
back_links:
  - link: /UE5/
    name: UE5
  - link: /UE5/LyraStarterGame/
    name: LyraStarterGame
---


# Create Your Dev Experience

The first time you create an experience is the hardest.  It's much easier for additional ones as you can reuse a lot of the work you do here.

For this reason we'll start with the "Dev" experience, e.g. one you don't actually care about except to test that things are working.

**Note: Default objects need to be based on Lyra code rather than on vanilla engine code.**

The order in which you create these matters; some reference others.


## Player Pawn

| Data Asset | Base Class |
| --- | --- |
| `Characters/B_XG_Character_Base` | `Lyra.Characters/Heros/B_Hero_Default` |
| `Characters/B_XG_Character_Humanoid` | `Characters/B_XG_Character_Base` |

Make sure you also take an extensive look at `ShooterCore.Game/B_Hero_ShooterMannequin` to see how Epic set up their player pawn.  There are things in there you likely don't need, but there are also things you'll most certainly want to copy/extend.

In XistGame, `B_XG_Character_Humanoid` is the player pawn.  It extends from `B_XG_Character_Base` which contains the pertinent parts of Epic's ShooterGame character.

If you do copy things from `B_Hero_ShooterMannequin`, make sure you apply [this bug fix](https://youtu.be/8qTc2IcG31g).  You'll also have to remove the `ShooterCore`-specific code and references they use there.

### XistGame Player Pawn Inheritance

- `Lyra.Characters/Heros/B_Hero_Default`
  - `XistGame.Characters/B_XG_Character_Base`
    - `XistGame.Characters/B_XG_Character_Humanoid`

### Things I copied from B_Hero_ShooterMannequin

I found these things to be interesting general-purpose items and decided to add them to `B_XG_Character_Base` as they apply to all characters in team-based games, not just shooters.

#### Events

- `OnBeginPlay`
  - Initialize team
  - Wait for pawn to fully init before showing in game
- `LyraHealthComponent.OnHealthChanged`
  - Report damage to `AIPerceptionStimuliSource` component
- `PawnCosmeticsComponent.OnCharacterPartsChanged`
  - Set team colors
  - Note I applied [this bug fix](https://youtu.be/8qTc2IcG31g)
- `ListenForTeam`
  - Set team colors whenever team changes
- `PawnExtComponent.OnPawnReadyToInitialize`
  - Show pawn
- 

#### Functions

- `ConstructionScript`
  - Set up character to use default "unarmed" animation layer
- `CreateOrUpdateOutlineIfNeeded`
  - Init or update character team outline color
    - Using `Lyra.Game/Effects/Materials/PostProcess/MPP_Outline_Inst`
- `OnTeamOrCosmeticsChanged`
  - Update character team outline color
  - Update character team mesh color
- `OnRep_PlayerInfo`
  - Update team color

### Things I did not copy from B_Hero_ShooterMannequin

- Inventory
  - Characters spawn with empty inventory
- Weapon slot hotkeys
  - All of the "swap weapon" hotkeys are `ShooterCore`-specific and have been removed
- UI elements


## Lyra Ability Set

| Data Asset | Base Class |
| --- | --- |
| `Characters/DA_XG_AbilitySet_Humanoid` | C++ `LyraAbilitySet` |

Copy paste `Granted Gameplay Abilities`:

```text
((Ability=BlueprintGeneratedClass'"/Game/Characters/Heroes/Abilities/GA_Hero_Jump.GA_Hero_Jump_C"',InputTag=(TagName="InputTag.Jump")))
```

- Gameplay Abilities:
  - Granted Gameplay Abilities:
    - 0:
      - Ability: `Lyra.Characters/Heroes/Abilities/GA_Hero_Jump`
      - Ability Level: 1
      - Input Tag: `InputTag.Jump`


## Lyra Ability Tag Relationship Mapping

| Data Asset | Base Class |
| --- | --- |
| `Game/DA_XG_TagRelationships` | C++ `LyraAbilityTagRelationshipMapping` |

Note that XistGame doesn't actually use these yet, I'm just having them here as an example of the kinds of relationships tags can have since these actions make sense that they're cancelling/blocking whatever.  Feel free to leave the relationships blank if you really want a blank project, or keep these for the sake of illustration.

Just copy this and paste it into `Ability Tag Relationships` if you want the default 4.

```text
((AbilityTag=(TagName="Ability.Type.Action"),ActivationBlockedTags=(GameplayTags=((TagName="Status.Death.Dead"),(TagName="Status.Death.Dying")))),(AbilityTag=(TagName="Ability.Type.Action.Melee"),AbilityTagsToBlock=(GameplayTags=((TagName="Ability.Type.Action.Emote"))),AbilityTagsToCancel=(GameplayTags=((TagName="Ability.Type.Action.Emote")))),(AbilityTag=(TagName="Ability.Type.Action.Drop"),AbilityTagsToBlock=(GameplayTags=((TagName="Ability.Type.Action.Emote"))),AbilityTagsToCancel=(GameplayTags=((TagName="Ability.Type.Action.Emote")))),(AbilityTag=(TagName="Ability.Type.Action.Emote"),ActivationBlockedTags=(GameplayTags=((TagName="Movement.Mode.Falling")))))
```

- Ability
  - Ability Tag Relationships:
    - 0: `Ability.Type.Action`
      - Activation Blocked Tags:
        - `Status.Death.Dead`
        - `Status.Death.Dying`
    - 1: `Ability.Type.Action.Melee`
      - Ability Tags to Block
        - `Ability.Type.Action.Emote`
      - Ability Tags to Cancel
        - `Ability.Type.Action.Emote`
    - 2: `Ability.Type.Action.Drop`
      - Ability Tags to Block
        - `Ability.Type.Action.Emote`
      - Ability Tags to Cancel
        - `Ability.Type.Action.Emote`
    - 3: `Ability.Type.Action.Emote`
      - Activation Blocked Tags:
        - `Movement.Mode.Falling`


## Lyra Input Config

| Data Asset | Base Class |
| --- | --- |
| `Input/DA_XG_InputData_Humanoid` | C++ `LyraInputConfig` |

Duplicate `Lyra.Input/InputData_Hero` to your new file name, then edit it and remove any inputs you don't want.


## Lyra Pawn Data

| Data Asset | Base Class |
| --- | --- |
| `Characters/DA_XG_PawnData_Humanoid` | C++ `LyraPawnData` |

Configure this asset:

- Lyra
  - Pawn
    - Pawn Class: `B_XG_Character_Humanoid`
  - Abilities
    - Ability Sets:
      - 0: `DA_XG_AbilitySet_Humanoid`
    - Tag Relationship Mapping: `DA_XG_TagRelationships`
  - Input
    - Input Config: `DA_XG_InputData_Humanoid`
  - Camera
    - Default Camera Mode: `Lyra.CM_ThirdPerson`


## Input Mapping Context

| Data Asset | Base Class |
| --- | --- |
| `Input/IMC_XG_Default_KBM` | C++ `InputMappingContext` |

Duplicate `Lyra.Input/Mappings/IMC_Default_KBM`

Edit `IMC_XG_Default_KBM` and remove any of the default input mappings that you don't want/need in your game.


## Lyra Experience Action Set

| Data Asset | Base Class |
| --- | --- |
| `Experiences/LAS_XG_SharedInput` | C++ `LyraExperienceActionSet` |

Copy+Paste Config `Actions to Perform`:

```text
(GameFeatureAction_AddInputContextMapping'"/XistGame/Experiences/LAS_XG_SharedInput.LAS_XG_SharedInput:GameFeatureAction_AddInputContextMapping_0"',GameFeatureAction_AddInputBinding'"/XistGame/Experiences/LAS_XG_SharedInput.LAS_XG_SharedInput:GameFeatureAction_AddInputBinding_0"')
```

Configure this asset:

- Actions to Perform
  - Actions
    - 0: `Add Input Mapping`
      - Input
        - Input Mappings
          - 0:
            - Input Mapping: `IMC_XG_Default_KBM`
            - Priority: 1
    - 1: `Add Input Binds`
      - Input
        - Input Configs
          - 0: `DA_XG_InputData_Humanoid`
- Feature Dependencies
  - Game Features to Enable
    - 0: `XistGame` (mod name)


## Lyra Team Creation Component

| Data Asset | Base Class |
| --- | --- |
| `Game/B_XG_TeamSetup_TwoTeams` | C++ `LyraTeamCreationComponent` |

Duplicate `ShooterCore.Game/B_TeamSetup_TwoTeams`

I changed team 1 to be green instead of red.


## Lyra Pick Random Manny or Quinn Character

| Data Asset | Base Class |
| --- | --- |
| `Characters/Cosmetics/B_XG_PickRandomCharacter` | C++ `ULyraControllerComponent_CharacterParts` |

Duplicate `ShooterCore.Characters/Cosmetics/B_PickRandomCharacter`

- Fix `BeginPlay` bug in Lyra BP
  - It needs to call the parent `BeginPlay` before it does anything else


## Gameplay Experience

| Data Asset | Base Class |
| --- | --- |
| `Experiences/B_XG_Experience_Dev` | C++ `LyraExperienceDefinition` |

Duplicate `ShooterCore.Experiences/B_ShooterGame_Elimination`

Configure this asset:

- Gameplay
  - Game Features to Enable:
    - 0: `XistGame` (mod name)
  - Default Pawn Data: `DA_XG_PawnData_Humanoid`
  - Action Sets:
    - 0: `LAS_XG_SharedInput`
- Actions
  - Actions:
    - 0: `Add Components`
      - Add `B_XG_TeamSetup_TwoTeams` to `LyraGameState`
        - *replace existing `B_TeamSetup_TwoTeams`*
        - Server only
      - Add `B_XG_PickRandomCharacter` to `Controller`
        - *replace existing bugged `B_PickRandomCharacter`*
        - Server only


请注意，`B_PickRandomCharacter` 已添加到基础 `AController` 类中。

它专门用于 `AController`，以便机器人 (`AAIController`) 和玩家(`APlayerController`) 都可以获得随机生成 Manny 或 Quinn 的功能。

虽然 `AController` 本身不支持模块化游戏玩法，但我们仍然能够将组件注入从其派生的类中，包括 Lyra 使用的模块化派生类。


## 世界：开发地图

| Data Asset | Base Class |
| --- | --- |
| `Maps/L_XG_DevMap` | C++ `World` |

配置此资产（其“世界设置”）：

- 游戏模式
- 默认游戏体验：“B_XG_Experience_Dev”（mod 自定义）

现在你不需要太多东西。一架飞机、一盏灯和一个 C++ `LyraPlayerStart` 演员就可以了。


### 更新项目设置

现在您应该更新项目设置以使用 `L_XG_DevMap` 作为默认设置，如果这是您想要的设置。

### 谢谢

快速向 `braheem`@github 致谢，他发现[错误](https://github.com/x157/x157.github.io/issues/1)在上述过程中现已修复。谢谢！

# 流程完成

您现在拥有自己的体验，您可以根据自己的需要进行修改。它的所有依赖项都在您自己的项目中，因此您也可以更改它们。

[返回 LyraStarterGame](/UE5/LyraStarterGame/)


