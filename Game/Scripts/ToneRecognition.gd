extends Node
class_name ToneRecognition

var effect: AudioEffect

# Spectrum analyzer
var spectrum: AudioEffectSpectrumAnalyzerInstance
const VU_COUNT = 2200
const FREQ_MAX = 2200
const SINGLE_SAMPLE_RANGE = 0.5 # Hz
const MIN_DB = 60
const C2_MIDI_POS = 36 # Corresponding to 'var fqToMidi = round(69 + 12 * fq)', C7 (highest) = 96
const LOWEST_OCTAVE = 2

@export_range(0.0, 0.5) var ignore_tone_below_volume = 0.25

var note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
var current_note: String = note_names[0]
var current_fq: float = 0
var current_octave: int = 0

var permissions

# UI
@export var lbl_tone: Label
@export var lbl_record_exist: Label
@export var lbl_spectrum_exist: Label
@export var lbl_can_record: Label

@export var slider_vol_filter: Slider
@export var lbl_vol_filter: Label

const energy_boost = 0.001 * 2

func _ready() -> void:
	# Setup bus effects
	var idx := AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	effect.set_recording_active(true)
	
	spectrum = AudioServer.get_bus_effect_instance(idx, 1)
	clear_current_note()
	
	# Setup UI
	if slider_vol_filter != null:
		slider_vol_filter.value = ignore_tone_below_volume
	
	if lbl_record_exist != null:
		lbl_record_exist.text = "Record eff.: " + str(effect != null)
		
	if lbl_spectrum_exist != null:
		lbl_spectrum_exist.text = "Spectrum eff.: " + str(spectrum != null)
	
func _process(delta: float) -> void:
	if (spectrum != null):
		processSound()
	# UI
	if lbl_tone != null:
		lbl_tone.text = "Tone: " + current_note + str(current_octave) + " (" + str(current_fq) + " Hz)"

# Notes detection handling
func processSound():
	var prev_hz: float = 0.0
	var energies: Array[float] = []
	
	# Loop variables
	var hz: float = 0
	var magnitude: float = 0
	var energy: float = 0

	for i in range(1, VU_COUNT + 1):
		hz = float(i) * FREQ_MAX / VU_COUNT
		magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		energy *= (FREQ_MAX - hz) * energy_boost # Boost lower FQ
		energies.append(energy)
		#energies.append(energy * energy_boost(hz, FREQ_MAX, 2))
		prev_hz = hz
			
	var ac = autocorrelation(energies)
	playedNote(ac)

func playedNote(frequency) -> void:
	if frequency <= 0:
		return
	
	var fq = log(frequency / 440.0) / log(2) # NOTE: Explore fq and fqToMidi formula
	var fqToMidi = round(69 + 12 * fq)
	var octave = floor((fqToMidi - C2_MIDI_POS) / 12) + LOWEST_OCTAVE
	
	current_fq = frequency
	current_note = note_names[int(fqToMidi) % 12]
	current_octave = octave
	
func autocorrelation(energies: Array):
	#var correlations = []
	var s: int = energies.size()
	var largest_correlation: float = energies[0] * energies[0]
	var lagest_pos: int = 0
	
	var cor: float
	
	for lag in range(1, energies.size()):
		cor = energies[lag] * energies[(lag * 2) % s]
		if largest_correlation < cor:
			largest_correlation = cor
			lagest_pos = lag
		#correlations.append(cor)
		
	return lagest_pos

func _on_vol_filter_slider_value_changed(value: float) -> void:
	ignore_tone_below_volume = value
	lbl_vol_filter.text = str(value)

func clear_current_note():
	current_fq = 0
	current_note = ''
