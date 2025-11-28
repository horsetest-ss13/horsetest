/datum/horse_breed
	var/name = "Mixed Breed"
	var/description = "A horse of mixed or unknown breeding."
	var/min_temperament = 20
	var/max_temperament = 60
	var/min_intelligence = 20
	var/max_intelligence = 60
	var/min_speed = 20
	var/max_speed = 60
	var/ideal_temperament = 30  // Lower is calmer
	var/ideal_intelligence = 50
	var/ideal_speed = 50
	var/rarity = 5
	var/list/breed_colors = list("#8b6f47", "#4a3625")
/datum/horse_breed/arabian
	name = "Arabian"
	description = "An ancient breed known for exceptional intelligence, endurance, and spirit. Highly prized and rare."
	min_temperament = 40  // More spirited
	max_temperament = 70
	min_intelligence = 50  // Very smart
	max_intelligence = 85
	min_speed = 45  // Fast
	max_speed = 75
	ideal_temperament = 55
	ideal_intelligence = 80
	ideal_speed = 75
	rarity = 9  // Very rare
	breed_colors = list("#D4AF7A", "#2C1810")  // Sandy gold with dark mane
/datum/horse_breed/thoroughbred
	name = "Thoroughbred"
	description = "The premier racing breed, bred for incredible speed and competitive spirit."
	min_temperament = 50  // High-strung
	max_temperament = 80
	min_intelligence = 30
	max_intelligence = 60
	min_speed = 60  // Very fast
	max_speed = 95
	ideal_temperament = 65
	ideal_intelligence = 45
	ideal_speed = 90
	rarity = 7  // Fairly rare
	breed_colors = list("#4A2511", "#1A0A05")  // Dark bay/brown
/datum/horse_breed/percheron
	name = "Percheron"
	description = "A large, powerful working breed. Calm and steady, but not particularly fast."
	min_temperament = 5
	max_temperament = 30
	min_intelligence = 15
	max_intelligence = 45
	min_speed = 5
	max_speed = 25
	ideal_temperament = 15
	ideal_intelligence = 35
	ideal_speed = 20
	rarity = 3  // Common working horse
	breed_colors = list("#654321", "#3D2817")  // Deep brown
/datum/horse_breed/mustang
	name = "Mustang"
	description = "A wild breed descended from escaped horses. Hardy, independent, and spirited."
	min_temperament = 45  // Wild spirit
	max_temperament = 75
	min_intelligence = 40  // Clever survivors
	max_intelligence = 70
	min_speed = 35  // Decent speed
	max_speed = 65
	ideal_temperament = 60
	ideal_intelligence = 60
	ideal_speed = 55
	rarity = 4  // Somewhat common in certain regions
	breed_colors = list("#8B7355", "#5C4033")  // Dun/buckskin
/datum/horse_breed/quarter_horse
	name = "Quarter Horse"
	description = "The most popular breed. Well-balanced, trainable, and versatile."
	min_temperament = 20  // Calm and trainable
	max_temperament = 50
	min_intelligence = 30
	max_intelligence = 65
	min_speed = 30
	max_speed = 60
	ideal_temperament = 30
	ideal_intelligence = 50
	ideal_speed = 50
	rarity = 2  // Very common
	breed_colors = list("#A0826D", "#6B4423")  // Sorrel/chestnut
/proc/get_random_horse_breed()
	var/list/breed_types = list(
		/datum/horse_breed/quarter_horse,
		/datum/horse_breed/percheron,
		/datum/horse_breed/mustang,
		/datum/horse_breed/thoroughbred,
		/datum/horse_breed/arabian
	)
	return pick(breed_types)
/proc/get_breed_datum(breed_type)
	if(!breed_type)
		return new /datum/horse_breed()
	return new breed_type()
