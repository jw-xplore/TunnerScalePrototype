extends Node
class_name ScalesManager

# Tones and scales
const INITIAL_OCTAVE = 4

var last_notes_i: Array[int] = []

func generate_scale(key: String, type: MusicConstants.EScaleTypes) -> Array[String]:
	var notes: Array[String] = []
	var keyPos = MusicConstants.TONE_NAMES.find(key)
	var offset = keyPos
	var octave = INITIAL_OCTAVE
	
	notes.append(MusicConstants.TONE_NAMES[keyPos] + str(octave))
	
	var note_i_pos: int = keyPos + (octave - INITIAL_OCTAVE) * MusicConstants.TONES_COUNT
	last_notes_i.clear()
	last_notes_i.append(note_i_pos)
	
	for i in MusicConstants.PROGRESSIONS[type]:
		keyPos = (keyPos + i) % MusicConstants.TONES_COUNT
		offset += i
		var note = MusicConstants.TONE_NAMES[keyPos]
		octave = INITIAL_OCTAVE + floor(offset / MusicConstants.TONES_COUNT)
		notes.append(note + str(octave))
		
		note_i_pos += i
		last_notes_i.append(note_i_pos)
		
	#print("Notes: " + str(notes))	
	var reversed: Array[int] = []
	reversed.append_array(last_notes_i)
	reversed.reverse()
	reversed.remove_at(reversed.size() - 1)
	reversed.remove_at(0)
	
	last_notes_i.append_array(reversed)
	print("last_notes_i: " + str(last_notes_i))
	
	return notes
