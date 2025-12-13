# Procedural Boss Generation System

## Inspired by Dwarf Fortress Forgotten Beasts

This document outlines a design for randomly generated bosses similar to how Dwarf Fortress creates its Forgotten Beasts - unique, terrifying creatures with procedurally generated appearances, abilities, and behaviors.

---

## Core Concept

Each generated boss is a unique creature with:

- **Random Body Form** - The base creature type
- **Random Materials** - What the creature is made of
- **Random Appendages** - Extra limbs, wings, tentacles, etc.
- **Random Abilities** - Special attacks and powers
- **Random Behavior** - Combat AI patterns
- **Generated Name** - A unique procedural name

---

## Component Tables

### 1. Base Body Forms

The fundamental shape of the creature.

| ID  | Form       | Base HP | Base Size  | Movement  |
| --- | ---------- | ------- | ---------- | --------- |
| 1   | Humanoid   | 200     | Medium     | Walk      |
| 2   | Quadruped  | 250     | Large      | Walk Fast |
| 3   | Serpentine | 180     | Long       | Slither   |
| 4   | Arachnid   | 220     | Medium     | Climb     |
| 5   | Blob       | 300     | Variable   | Ooze      |
| 6   | Worm       | 350     | Huge       | Burrow    |
| 7   | Crab-like  | 280     | Large      | Sideways  |
| 8   | Bird-like  | 150     | Medium     | Fly       |
| 9   | Fish-like  | 200     | Medium     | Swim      |
| 10  | Insectoid  | 180     | Small-Huge | Varies    |

### 2. Material Composition

What the creature is made of affects resistances and visual appearance.

| ID  | Material     | Damage Resist | Special               |
| --- | ------------ | ------------- | --------------------- |
| 1   | Flesh        | None          | Bleeds                |
| 2   | Stone        | Brute 50%     | Slow                  |
| 3   | Metal (Iron) | Brute 75%     | Magnetic              |
| 4   | Metal (Gold) | Brute 50%     | Valuable drops        |
| 5   | Crystal      | Laser 90%     | Reflects light        |
| 6   | Fire/Magma   | Burn Immune   | Burns melee attackers |
| 7   | Ice          | Burn 200%     | Freezing aura         |
| 8   | Shadow       | Brute 25%     | Harder to see         |
| 9   | Bone         | Brute 30%     | Undead                |
| 10  | Slime/Ooze   | Brute 50%     | Splits when damaged   |
| 11  | Plant Matter | Burn 150%     | Regenerates           |
| 12  | Chitin       | Brute 40%     | Acid resistant        |

### 3. Appendages (Roll 1-3 times)

Extra body parts that affect abilities and attacks.

| ID  | Appendage         | Effect                           |
| --- | ----------------- | -------------------------------- |
| 1   | Extra Arms (2-6)  | More melee attacks               |
| 2   | Tentacles (4-12)  | Grab attacks, longer reach       |
| 3   | Wings             | Can fly                          |
| 4   | Tail (Spiked)     | Rear attack                      |
| 5   | Tail (Prehensile) | Can grab                         |
| 6   | Horns             | Charge attack                    |
| 7   | Stinger           | Poison attacks                   |
| 8   | Extra Eyes        | Cannot be flanked                |
| 9   | Extra Mouths      | Bite attacks from all directions |
| 10  | Spines/Quills     | Damages melee attackers          |
| 11  | Shell/Carapace    | +50% armor                       |
| 12  | Pincers           | Crushing grab attacks            |

### 4. Special Abilities (Roll 2-4 times)

Unique powers the boss can use.

| ID  | Ability            | Description                   | Cooldown |
| --- | ------------------ | ----------------------------- | -------- |
| 1   | Fire Breath        | Cone of fire damage           | 10s      |
| 2   | Poison Spit        | Ranged poison attack          | 8s       |
| 3   | Acid Spray         | Damages armor and flesh       | 12s      |
| 4   | Web Spray          | Immobilizes targets           | 15s      |
| 5   | Freezing Aura      | Slows nearby enemies          | Passive  |
| 6   | Teleport           | Short range blink             | 5s       |
| 7   | Summon Minions     | Spawns 2-4 lesser creatures   | 30s      |
| 8   | Roar/Scream        | AoE stun                      | 20s      |
| 9   | Regeneration       | Heals over time               | Passive  |
| 10  | Invisibility       | Becomes unseen                | 25s      |
| 11  | Charge             | Rushes at target, high damage | 8s       |
| 12  | Earthquake         | AoE knockdown                 | 15s      |
| 13  | Vampiric Touch     | Heals from damage dealt       | Passive  |
| 14  | Phase Shift        | Temporarily invulnerable      | 20s      |
| 15  | Electric Discharge | Chain lightning               | 12s      |
| 16  | Petrifying Gaze    | Turns target to stone         | 30s      |

### 5. Behavior Patterns

How the boss fights.

| ID  | Pattern     | Description                           |
| --- | ----------- | ------------------------------------- |
| 1   | Aggressive  | Always charges, high damage           |
| 2   | Defensive   | Waits for attacks, counters           |
| 3   | Hit and Run | Attacks then retreats                 |
| 4   | Summoner    | Focuses on spawning minions           |
| 5   | Ranged      | Keeps distance, uses ranged abilities |
| 6   | Berserk     | Gets stronger as HP drops             |
| 7   | Tactical    | Targets weakest/healers first         |
| 8   | Ambusher    | Hides, surprise attacks               |

---

## Name Generation

### Structure

`[Prefix] [Root] [Suffix]` or `[Descriptor] the [Title]`

### Prefixes

Ghor, Zul, Mok, Thra, Vor, Xen, Kra, Neth, Bal, Gor

### Roots

-moth, -zag, -thul, -rak, -gon, -mar, -vex, -dul, -kesh, -nox

### Suffixes

-or, -ax, -us, -ix, -on, -ar, -ul, -ek, -im, -os

### Descriptors

Writhing, Festering, Howling, Lurking, Consuming, Eternal, Blighted, Ravenous

### Titles

Horror, Devourer, Bane, Nightmare, Scourge, Terror, Abomination, Plague

### Examples

- "Ghormoth the Writhing"
- "Zulthax"
- "Vorkeshan the Devourer"
- "Nethragul"
- "The Lurking Bane of the Deep"

---

## Generation Algorithm

```
PROC generate_boss(difficulty):
    boss = new /datum/procedural_boss

    // Roll base form
    boss.form = pick(BODY_FORMS)
    boss.hp = boss.form.base_hp * (1 + difficulty * 0.5)

    // Roll material
    boss.material = pick(MATERIALS)
    apply_material_modifiers(boss)

    // Roll appendages (1-3 based on difficulty)
    appendage_count = rand(1, min(3, difficulty))
    for(i in 1 to appendage_count):
        boss.appendages += pick(APPENDAGES)

    // Roll abilities (2-4 based on difficulty)
    ability_count = rand(2, 2 + round(difficulty / 2))
    for(i in 1 to ability_count):
        boss.abilities += pick(ABILITIES)

    // Roll behavior
    boss.behavior = pick(BEHAVIORS)

    // Generate name
    boss.name = generate_name()

    // Generate description
    boss.desc = generate_description(boss)

    return boss
```

---

## Implementation Phases

### Phase 1: Core Framework

- Create `/datum/procedural_boss` datum
- Implement the component tables as lists
- Create the generation proc
- Basic mob spawning with generated stats

### Phase 2: Visual Generation

- Create composite sprite system
- Layer base form + material overlay + appendage sprites
- Color tinting based on material

### Phase 3: Ability System

- Implement each ability as a reusable action
- Create cooldown management
- AI integration for ability usage

### Phase 4: Behavior AI

- Implement behavior patterns as AI controllers
- Priority systems for target selection
- Phase transitions (berserk at low HP, etc.)

### Phase 5: Loot & Rewards

- Generate unique drops based on boss components
- Trophy items with boss name
- Rare crafting materials from boss materials

---

## Example Generated Boss

```
Name: Thravexul the Consuming

Form: Blob (Base HP: 300)
Material: Slime/Ooze (Brute resist 50%, splits when damaged)
Appendages:
  - Tentacles (8) - Grab attacks
  - Extra Mouths (3) - Multi-bite
Abilities:
  - Acid Spray (12s cooldown)
  - Summon Minions (spawns mini-oozes)
  - Regeneration (passive)
Behavior: Summoner

Description:
"A vast, pulsating mass of acidic slime writhes before you.
Eight grasping tentacles extend from its amorphous body,
each ending in a gnashing mouth. It is known as Thravexul
the Consuming, and countless adventurers have fed its
endless hunger."

Drops:
- Acidic Ooze Sample (crafting material)
- Trophy: "Mouth of Thravexul" (wall mount)
- Ooze-Coated Equipment (random armor with acid damage)
```

---

## Balance Considerations

1. **Synergy Limits**: Some combinations should be blocked
   - No fire material + ice abilities
   - No flying + burrowing

2. **Difficulty Scaling**:
   - Easy: 1 appendage, 2 abilities
   - Medium: 2 appendages, 3 abilities
   - Hard: 3 appendages, 4 abilities
   - Extreme: 3 appendages, 5 abilities, bonus HP

3. **Counter-play**: Every boss should have weaknesses
   - Fire bosses weak to water/cryo
   - Slime bosses weak to fire
   - Flying bosses can be grounded
   - Regenerating bosses weak to burn/acid

4. **Loot Correlation**: Drops should reflect the boss
   - Material determines resource drops
   - Abilities might drop as learnable items
   - Appendages become trophy decorations

---

## Future Expansions

- **Mutated Bosses**: Previously killed bosses return mutated
- **Boss Pairs**: Two complementary bosses fight together
- **Lair Generation**: Procedural boss rooms matching the boss
- **Legendary Variants**: 1% chance for "Ancient" prefix with bonus powers
- **Player-Created Bosses**: Gene-splicing system to make custom bosses
