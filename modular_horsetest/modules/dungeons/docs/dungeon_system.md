# Procedural Dungeon System

This document explains how the procedural dungeon generation system works.

---

## Overview

The dungeon system creates randomly generated dungeon instances that players can enter through portals. Each dungeon features rooms connected by corridors, enemies, treasure, and an exit ladder.

---

## Core Components

### 1. Dungeon Instance (`/datum/dungeon_instance`)

The main controller that manages a single dungeon's lifecycle.

#### Key Variables

| Variable           | Type   | Description                                             |
| ------------------ | ------ | ------------------------------------------------------- |
| `id`               | string | Unique identifier for the dungeon                       |
| `name`             | string | Display name of the dungeon                             |
| `state`            | string | Current state (idle/generating/active/completed/failed) |
| `difficulty`       | number | Affects enemy count, treasure, and room count           |
| `width` / `height` | number | Size of the dungeon in tiles                            |
| `max_players`      | number | Max players allowed (-1 = infinite)                     |
| `players_inside`   | list   | Tracks all players currently in the dungeon             |
| `spawned_mobs`     | list   | All enemies spawned (for cleanup)                       |
| `spawned_objects`  | list   | All objects spawned (for cleanup)                       |
| `dungeon_area`     | area   | The unique powered area for this dungeon                |

#### State Machine

```text
IDLE → GENERATING → ACTIVE → COMPLETED
                  ↘ FAILED
```

- **IDLE**: Initial state, ready to generate
- **GENERATING**: Currently building the dungeon
- **ACTIVE**: Dungeon is ready and players can enter/exit
- **COMPLETED**: All players left, cleanup scheduled
- **FAILED**: Generation failed

#### Generation Flow

1. **Reserve Space**: Request a turf block from `SSmapping`
2. **Create Area**: Make a unique `/area/dungeon` (powered, has gravity)
3. **Assign Turfs**: Add all turfs to the dungeon area (before placing objects)
4. **Generate Layout**: Use `room_dungeon_generator` to create rooms/corridors
5. **Apply to Turfs**: Convert the grid to actual walls, floors, and doors
6. **Find Special Turfs**: Locate entrance and exit positions
7. **Populate**: Spawn enemies, treasure, and the exit ladder
8. **Add Lighting**: Place floor lights in each room

---

### 2. Room Generator (`/datum/room_dungeon_generator`)

Creates the dungeon layout using a room-based algorithm.

#### Algorithm

1. **Room Placement**: Places rooms in a grid pattern with randomness
2. **Entrance Selection**: First room becomes the entrance
3. **Exit Selection**: Random room that is at least 10 tiles from entrance
4. **Corridor Carving**: Connects rooms with snaking L-shaped corridors
5. **Door Placement**: Adds doors where corridors meet rooms

#### Tile Types

| Constant             | Value | Result                                  |
| -------------------- | ----- | --------------------------------------- |
| `ROOM_TILE_WALL`     | 0     | `/turf/closed/wall`                     |
| `ROOM_TILE_FLOOR`    | 1     | `/turf/open/floor/iron`                 |
| `ROOM_TILE_CORRIDOR` | 2     | `/turf/open/floor/plating`              |
| `ROOM_TILE_DOOR`     | 3     | Plating + `/obj/machinery/door/airlock` |
| `ROOM_TILE_ENTRANCE` | 4     | `/turf/open/floor/iron/dark`            |
| `ROOM_TILE_EXIT`     | 5     | `/turf/open/floor/iron/dark`            |

---

### 3. Dungeon Portal (`/obj/machinery/dungeon_portal`)

The entry point for players to access dungeons.

#### Behavior

- **No active dungeon**: Generates a new dungeon and teleports player in
- **Active dungeon exists**: Teleports player into the existing dungeon
- **Dungeon full**: Shows error message (if `max_players` is set)
- **Cooldown**: 30 seconds after a dungeon is destroyed before a new one can be created

#### Portal Variants

| Type       | Difficulty | Size  |
| ---------- | ---------- | ----- |
| `/easy`    | 1          | 20x20 |
| `/medium`  | 3          | 25x25 |
| `/hard`    | 5          | 30x30 |
| `/extreme` | 10         | 40x40 |

---

### 4. Dungeon Exit (`/obj/structure/dungeon_exit`)

A ladder placed in the exit room that teleports players out.

- Returns player to the portal they entered from
- Removes player from `players_inside` list
- When last player leaves, triggers dungeon completion

---

### 5. Dungeon Area (`/area/dungeon`)

A special area type that ensures the dungeon is fully powered.

#### Properties

- `requires_power = FALSE` - Doesn't need an APC
- `always_unpowered = FALSE` - Not flagged as unpowered
- `power_equip/light/environ = TRUE` - All power channels active
- `static_lighting = TRUE` - Uses static lighting
- `base_lighting_alpha = 180` - Dim ambient light
- `base_lighting_color = "#CCAA88"` - Warm dungeon glow

---

## Difficulty Scaling

| Difficulty | Room Count | Enemy Count | Treasure Crates | Gold Bars |
| ---------- | ---------- | ----------- | --------------- | --------- |
| 1          | 7          | 5-7         | 1               | 2         |
| 3          | 11         | 11-13       | 2               | 4         |
| 5          | 15         | 17-19       | 3               | 6         |
| 10         | 25         | 32-34       | 6               | 11        |

Formulas:

- Rooms: `5 + (difficulty * 2)`
- Enemies: `(difficulty * 3) + rand(2, 4)`
- Treasure: `(difficulty * 0.5) + 1`
- Gold bars: `1 + difficulty`

---

## Cleanup Process

1. Player uses exit ladder → removed from `players_inside`
2. When `players_inside` is empty → `complete_dungeon()` called
3. State set to `COMPLETED`
4. After 30 seconds → `cleanup_after_completion()` runs
5. All spawned mobs and objects are deleted
6. Turf reservation is released
7. Dungeon area is deleted
8. Dungeon instance is deleted
9. Portal cooldown starts (30 seconds)

---

## Multiplayer Support

- Multiple players can enter the same dungeon through the same portal
- `max_players` controls capacity (-1 = unlimited)
- Dungeon stays active until ALL players leave
- Players can join an active dungeon at any time (if not full)

---

## File Structure

```text
modular_horsetest/modules/dungeons/
├── code/
│   ├── dungeon_areas.dm      # Area definition
│   ├── dungeon_instance.dm   # Main dungeon controller + exit ladder
│   ├── dungeon_portal.dm     # Portal machinery
│   └── room_generator.dm     # Procedural generation algorithm
└── docs/
    ├── dungeon_system.md     # This file
    └── procedural_boss_design.md  # Future boss generation design
```
