extends Node
class_name  MusicConstants

const TONES_COUNT = 12
const BASE_OCTAVE = 4

# Enum
enum ENotes { C, Cs, D, Ds, E, F, Fs, G, Gs, A, As, B }
enum EScaleTypes { Major, MinorNatural }

# Progression
const PROGRESSIONS: Dictionary = {
	EScaleTypes.Major : [2, 2, 1, 2, 2, 2, 1],
	EScaleTypes.MinorNatural : [2, 1, 2, 2, 1, 2, 2],
}

# Names
const TONE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
const PROGRESSION_NAMES: Dictionary = \
{
	EScaleTypes.Major : "Major",
	EScaleTypes.MinorNatural : "Minor - Natural",
}
