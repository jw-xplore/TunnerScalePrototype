extends Node
class_name SaveManager

const file_path = "user://savegame.save"
const SPLIT = "_"
var levels_count = 0
var completed_count = 0

var levels_completed = {}

func _ready() -> void:
	print(OS.get_user_data_dir())
	if FileAccess.file_exists(file_path):
		# Setup with existing file
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			levels_completed = json.data
			levels_count = levels_completed.size()
			#print(levels_count)
			
		# Check completed count
		for lvl in levels_completed:
			if levels_completed[lvl] == true:
				completed_count += 1
	else:
		generate_new_save_file()
	#print("levels_count: " + str(levels_count))

func save_name_format(key: String, type: String, level: int) -> String:
	return key + SPLIT + type + SPLIT + str(level)
	
func is_completed(key: String, type: String, level: int) -> bool:
	var pos = save_name_format(key, type, level)
	return levels_completed[pos]

func generate_new_save_file():
	# Create new file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	for key in range(0, MusicConstants.TONE_NAMES.size()):
		for type in range(0, MusicConstants.PROGRESSION_NAMES.size()):
			for level in range(0, Difficulties.LEVELS.size()):
				var ks = MusicConstants.TONE_NAMES[key]
				var ts = MusicConstants.PROGRESSION_NAMES[type]
				var name = save_name_format(ks, ts, level)
				levels_completed[name] = false
				levels_count += 1
				
	var json_string = JSON.stringify(levels_completed, "\t")
	file.store_line(json_string)

func save_progress(lvl_name: String, completed: bool):
	levels_completed[lvl_name] = completed
	
	# Update progress tracking
	if completed == true:
		completed_count += 1
	else:
		completed_count -= 1
	
	# Save progresss
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json_string = JSON.stringify(levels_completed, "\t")
	file.store_line(json_string)
	
