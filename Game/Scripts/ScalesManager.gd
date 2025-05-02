extends Node
class_name ScalesManager

# Tones and scales
const INITIAL_OCTAVE = 4

func generate_scale(key: String, type: MusicConstants.EScaleTypes) -> Array[String]:
	var notes: Array[String] = []
	var keyPos = MusicConstants.TONE_NAMES.find(key)
	var offset = keyPos
	var octave = INITIAL_OCTAVE
	
	notes.append(MusicConstants.TONE_NAMES[keyPos] + str(octave))
	
	for i in MusicConstants.PROGRESSIONS[type]:
		keyPos = (keyPos + i) % MusicConstants.TONES_COUNT
		offset += i
		var note = MusicConstants.TONE_NAMES[keyPos]
		octave = INITIAL_OCTAVE + floor(offset / MusicConstants.TONES_COUNT)
		notes.append(note + str(octave))
		
	print("Notes: " + str(notes))	
	return notes
