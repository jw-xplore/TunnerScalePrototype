extends Node
class_name ScalesManager

# Tones and scales
const NOTES_COUNT = 12
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
	notes.append(note_names[keyPos])
	
	for i in scales[type]:
		keyPos = (keyPos + i) % NOTES_COUNT
		var note = note_names[keyPos]
		notes.append(note)
		
	print("Notes: " + str(notes))
	return notes
