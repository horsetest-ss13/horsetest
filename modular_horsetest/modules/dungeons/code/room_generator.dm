/// Room-based dungeon generator
/// Creates distinct rooms connected by snaking corridors for traditional dungeon layouts

#define ROOM_TILE_WALL 0
#define ROOM_TILE_FLOOR 1
#define ROOM_TILE_CORRIDOR 2
#define ROOM_TILE_DOOR 3
#define ROOM_TILE_ENTRANCE 4
#define ROOM_TILE_EXIT 5

/datum/dungeon_room
	var/x1  // Left edge
	var/y1  // Bottom edge
	var/x2  // Right edge
	var/y2  // Top edge
	var/center_x
	var/center_y
	var/room_type = "normal" // normal, entrance, exit

/datum/dungeon_room/New(rx1, ry1, rx2, ry2)
	x1 = rx1
	y1 = ry1
	x2 = rx2
	y2 = ry2
	center_x = round((x1 + x2) / 2)
	center_y = round((y1 + y2) / 2)

/datum/dungeon_room/proc/get_width()
	return x2 - x1 + 1

/datum/dungeon_room/proc/get_height()
	return y2 - y1 + 1

/datum/dungeon_room/proc/intersects(datum/dungeon_room/other, padding = 1)
	return (x1 - padding <= other.x2 && x2 + padding >= other.x1 && y1 - padding <= other.y2 && y2 + padding >= other.y1)

/datum/dungeon_room/proc/distance_to(datum/dungeon_room/other)
	return sqrt((center_x - other.center_x) ** 2 + (center_y - other.center_y) ** 2)

/datum/room_dungeon_generator
	var/width = 30
	var/height = 30
	var/list/rooms = list()
	var/list/grid = list()
	var/min_room_size = 3
	var/max_room_size = 6
	var/max_rooms = 12
	var/datum/dungeon_room/entrance_room
	var/datum/dungeon_room/exit_room
	var/generation_complete = FALSE

/datum/room_dungeon_generator/New(gen_width = 30, gen_height = 30, room_count = 10)
	width = gen_width
	height = gen_height
	max_rooms = room_count
	initialize_grid()

/datum/room_dungeon_generator/proc/initialize_grid()
	grid = list()
	for(var/x in 1 to width)
		grid["[x]"] = list()
		for(var/y in 1 to height)
			grid["[x]"]["[y]"] = ROOM_TILE_WALL

/datum/room_dungeon_generator/proc/set_tile(x, y, tile_type)
	if(x < 1 || x > width || y < 1 || y > height)
		return FALSE
	grid["[x]"]["[y]"] = tile_type
	return TRUE

/datum/room_dungeon_generator/proc/get_tile(x, y)
	if(x < 1 || x > width || y < 1 || y > height)
		return ROOM_TILE_WALL
	return grid["[x]"]["[y]"]

/datum/room_dungeon_generator/proc/generate()
	// Generate tightly packed rooms
	generate_packed_rooms()

	if(length(rooms) < 2)
		return FALSE

	// Entrance is first room (bottom-left area)
	entrance_room = rooms[1]
	entrance_room.room_type = "entrance"

	// Exit is a random room that is not too close to entrance
	var/list/valid_exit_rooms = list()
	var/min_distance = 10 // Minimum distance from entrance
	for(var/datum/dungeon_room/room in rooms)
		if(room == entrance_room)
			continue
		var/dist = entrance_room.distance_to(room)
		if(dist >= min_distance)
			valid_exit_rooms += room
	// If no rooms are far enough, just pick any room that's not the entrance
	if(!length(valid_exit_rooms))
		for(var/datum/dungeon_room/room in rooms)
			if(room != entrance_room)
				valid_exit_rooms += room
	exit_room = pick(valid_exit_rooms)
	exit_room.room_type = "exit"

	// Carve out all rooms
	for(var/datum/dungeon_room/room in rooms)
		carve_room(room)

	// Connect rooms with snaking corridors
	connect_rooms_snaking()

	// Add doors at room entrances
	add_doors()

	// Place entrance marker
	set_tile(entrance_room.center_x, entrance_room.center_y, ROOM_TILE_ENTRANCE)
	// Place exit marker
	set_tile(exit_room.center_x, exit_room.center_y, ROOM_TILE_EXIT)

	generation_complete = TRUE
	return TRUE

/datum/room_dungeon_generator/proc/generate_packed_rooms()
	// Place rooms in a grid-like pattern with small gaps
	// Smaller dungeons get tighter spacing
	var/grid_spacing_x = max(5, round(width / 5))
	var/grid_spacing_y = max(5, round(height / 5))

	var/start_x = 3
	var/start_y = 3

	var/rooms_placed = 0
	var/grid_cols = max(2, round((width - 4) / grid_spacing_x))
	var/grid_rows = max(2, round((height - 4) / grid_spacing_y))

	for(var/col in 0 to grid_cols - 1)
		for(var/row in 0 to grid_rows - 1)
			if(rooms_placed >= max_rooms)
				break

			// Add some randomness to positions
			var/base_x = start_x + (col * grid_spacing_x) + rand(-1, 1)
			var/base_y = start_y + (row * grid_spacing_y) + rand(-1, 1)

			var/room_w = rand(min_room_size, max_room_size)
			var/room_h = rand(min_room_size, max_room_size)

			var/rx1 = base_x
			var/ry1 = base_y
			var/rx2 = min(rx1 + room_w - 1, width - 2)
			var/ry2 = min(ry1 + room_h - 1, height - 2)

			// Make sure room is valid
			if(rx1 < 2)
				rx1 = 2
			if(ry1 < 2)
				ry1 = 2
			if(rx2 >= width - 1)
				rx2 = width - 2
			if(ry2 >= height - 1)
				ry2 = height - 2

			if(rx2 <= rx1 || ry2 <= ry1)
				continue

			var/datum/dungeon_room/new_room = new(rx1, ry1, rx2, ry2)

			// Check for overlap (with minimal padding)
			var/valid = TRUE
			for(var/datum/dungeon_room/existing in rooms)
				if(new_room.intersects(existing, 1))
					valid = FALSE
					break

			if(valid)
				rooms += new_room
				rooms_placed++

		if(rooms_placed >= max_rooms)
			break

/datum/room_dungeon_generator/proc/carve_room(datum/dungeon_room/room)
	for(var/x in room.x1 to room.x2)
		for(var/y in room.y1 to room.y2)
			set_tile(x, y, ROOM_TILE_FLOOR)

/datum/room_dungeon_generator/proc/connect_rooms_snaking()
	// Connect rooms in order, but make corridors snake around
	for(var/i in 1 to length(rooms) - 1)
		var/datum/dungeon_room/room_a = rooms[i]
		var/datum/dungeon_room/room_b = rooms[i + 1]
		carve_snaking_corridor(room_a.center_x, room_a.center_y, room_b.center_x, room_b.center_y)

	// Add extra connections to make it more maze-like
	var/extra = round(length(rooms) / 3)
	for(var/i in 1 to extra)
		var/datum/dungeon_room/room_a = pick(rooms)
		var/datum/dungeon_room/room_b = pick(rooms)
		if(room_a != room_b)
			carve_snaking_corridor(room_a.center_x, room_a.center_y, room_b.center_x, room_b.center_y)

/datum/room_dungeon_generator/proc/carve_snaking_corridor(x1, y1, x2, y2)
	var/current_x = x1
	var/current_y = y1

	// Add some zigzag to the corridor
	var/segments = rand(2, 4)
	var/dx = x2 - x1
	var/dy = y2 - y1

	for(var/seg in 1 to segments)
		var/target_x
		var/target_y

		if(seg == segments)
			target_x = x2
			target_y = y2
		else
			// Intermediate waypoints with some randomness
			var/progress = seg / segments
			target_x = x1 + round(dx * progress) + rand(-2, 2)
			target_y = y1 + round(dy * progress) + rand(-2, 2)
			target_x = clamp(target_x, 2, width - 1)
			target_y = clamp(target_y, 2, height - 1)

		// Alternate between horizontal-first and vertical-first
		if(seg % 2 == 1)
			// Horizontal then vertical
			while(current_x != target_x)
				if(get_tile(current_x, current_y) == ROOM_TILE_WALL)
					set_tile(current_x, current_y, ROOM_TILE_CORRIDOR)
				current_x += (target_x > current_x) ? 1 : -1
			while(current_y != target_y)
				if(get_tile(current_x, current_y) == ROOM_TILE_WALL)
					set_tile(current_x, current_y, ROOM_TILE_CORRIDOR)
				current_y += (target_y > current_y) ? 1 : -1
		else
			// Vertical then horizontal
			while(current_y != target_y)
				if(get_tile(current_x, current_y) == ROOM_TILE_WALL)
					set_tile(current_x, current_y, ROOM_TILE_CORRIDOR)
				current_y += (target_y > current_y) ? 1 : -1
			while(current_x != target_x)
				if(get_tile(current_x, current_y) == ROOM_TILE_WALL)
					set_tile(current_x, current_y, ROOM_TILE_CORRIDOR)
				current_x += (target_x > current_x) ? 1 : -1

	// Set the final tile
	if(get_tile(current_x, current_y) == ROOM_TILE_WALL)
		set_tile(current_x, current_y, ROOM_TILE_CORRIDOR)

/datum/room_dungeon_generator/proc/add_doors()
	for(var/x in 2 to width - 1)
		for(var/y in 2 to height - 1)
			if(get_tile(x, y) != ROOM_TILE_CORRIDOR)
				continue

			var/floor_neighbors = 0
			var/corridor_neighbors = 0

			if(get_tile(x - 1, y) == ROOM_TILE_FLOOR)
				floor_neighbors++
			if(get_tile(x + 1, y) == ROOM_TILE_FLOOR)
				floor_neighbors++
			if(get_tile(x, y - 1) == ROOM_TILE_FLOOR)
				floor_neighbors++
			if(get_tile(x, y + 1) == ROOM_TILE_FLOOR)
				floor_neighbors++

			if(get_tile(x - 1, y) == ROOM_TILE_CORRIDOR)
				corridor_neighbors++
			if(get_tile(x + 1, y) == ROOM_TILE_CORRIDOR)
				corridor_neighbors++
			if(get_tile(x, y - 1) == ROOM_TILE_CORRIDOR)
				corridor_neighbors++
			if(get_tile(x, y + 1) == ROOM_TILE_CORRIDOR)
				corridor_neighbors++

			// Door at corridor-to-room transition
			if(floor_neighbors >= 1 && corridor_neighbors >= 1)
				set_tile(x, y, ROOM_TILE_DOOR)

/datum/room_dungeon_generator/proc/apply_to_turfs(turf/bottom_left)
	if(!generation_complete)
		return FALSE

	for(var/x in 1 to width)
		for(var/y in 1 to height)
			var/tile_type = get_tile(x, y)
			var/turf/target = locate(bottom_left.x + x - 1, bottom_left.y + y - 1, bottom_left.z)
			if(!target)
				continue

			if(tile_type == ROOM_TILE_WALL)
				target.ChangeTurf(/turf/closed/wall)
			else if(tile_type == ROOM_TILE_FLOOR)
				target.ChangeTurf(/turf/open/floor/iron)
			else if(tile_type == ROOM_TILE_CORRIDOR)
				target.ChangeTurf(/turf/open/floor/plating)
			else if(tile_type == ROOM_TILE_DOOR)
				target.ChangeTurf(/turf/open/floor/plating)
				new /obj/machinery/door/airlock(target)
			else if(tile_type == ROOM_TILE_ENTRANCE)
				target.ChangeTurf(/turf/open/floor/iron/dark)
			else if(tile_type == ROOM_TILE_EXIT)
				target.ChangeTurf(/turf/open/floor/iron/dark)

	return TRUE

/datum/room_dungeon_generator/proc/get_entrance_position()
	if(!entrance_room)
		return null
	return list(entrance_room.center_x, entrance_room.center_y)

/datum/room_dungeon_generator/proc/get_exit_position()
	if(!exit_room)
		return null
	return list(exit_room.center_x, exit_room.center_y)

/datum/room_dungeon_generator/proc/get_entrance_room()
	return entrance_room

/datum/room_dungeon_generator/proc/get_exit_room()
	return exit_room

/datum/room_dungeon_generator/proc/get_floor_positions()
	var/list/positions = list()
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			var/tile = get_tile(x, y)
			if(tile == ROOM_TILE_FLOOR || tile == ROOM_TILE_CORRIDOR)
				positions += list(list(x, y))
	return positions

/// Get floor positions that are NOT in the entrance room
/datum/room_dungeon_generator/proc/get_floor_positions_except_entrance()
	var/list/positions = list()
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			// Skip tiles in entrance room
			if(entrance_room && x >= entrance_room.x1 && x <= entrance_room.x2 && y >= entrance_room.y1 && y <= entrance_room.y2)
				continue
			var/tile = get_tile(x, y)
			if(tile == ROOM_TILE_FLOOR || tile == ROOM_TILE_CORRIDOR)
				positions += list(list(x, y))
	return positions
