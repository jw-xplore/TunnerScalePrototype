extends Node
class_name ScalesManager

# Tones and scales
const NOTES_COUNT = 12
const INITIAL_OCTAVE = 4
var note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

enum ENotes { C, Cs, D, Ds, E, F, Fs, G, Gs, A, As, B }
enum EScaleTypes { Major, MinorNatural}

var scales: Dictionary = \
{
	EScaleTypes.Major : [2, 2, 1, 2, 2, 2, 1],
	EScaleTypes.MinorNatural : [2, 1, 2, 2, 1, 2, 2],
}

func generate_scale(key: String, type: EScaleTypes) -> Array[String]:
	var notes: Array[String] = []
	var keyPos = note_names.find(key)
	var offset = keyPos
	var octave = INITIAL_OCTAVE
	
	notes.append(note_names[keyPos] + str(octave))
	
	for i in scales[type]:
		keyPos = (keyPos + i) % NOTES_COUNT
		offset += i
		var note = note_names[keyPos]
		octave = INITIAL_OCTAVE + floor(offset / NOTES_COUNT)
		notes.append(note + str(octave))
		
	print("Notes: " + str(notes))	
	return notes
