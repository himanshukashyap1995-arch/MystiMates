extends Node

# Autoload singleton: LevelManager
# Configure levels here. Indexing is 1-based for UX (Level 1 -> index 1).
# Types:
#  - "score": uses target_score and moves
#  - "color": uses color_targets { tile_type: count } and moves
#  - "color_multi": uses color_targets { tile_type: count, ... } and moves

var levels: Array = [
	{ "type": "score", "target_score": 100, "moves": 10 },
	{ "type": "score", "target_score": 200, "moves": 15 },
	{ "type": "color", "color_targets": {0: 10}, "moves": 20 },
	{ "type": "color_multi", "color_targets": {0: 8, 2: 8}, "moves": 25 }
]

var current_level: int = 1

func get_level_data(level_index: int) -> Dictionary:
	var idx: int = clampi(level_index - 1, 0, levels.size() - 1)
	return Dictionary(levels[idx])
