extends Node
class_name ToneRecognition

var effect: AudioEffect

# Spectrum analyzer
var spectrum: AudioEffectSpectrumAnalyzerInstance
const VU_COUNT = 2048
const FREQ_MAX = 2000.0
const MIN_DB = 60

@export_range(0.0, 0.5) var ignore_tone_below_volume = 0.25

var note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
var current_note = note_names[0]
var current_fq = 0

var permissions

# UI
@export var lbl_tone: Label
@export var lbl_record_exist: Label
@export var lbl_spectrum_exist: Label

@export var slider_vol_filter: Slider
@export var lbl_vol_filter: Label

func _ready() -> void:
	# Handle permision
	if Engine.has_singleton("AndroidPermissions"):
		permissions = Engine.get_singleton("AndroidPermissions")
		permissions.init(get_instance_id(), false)
		
	if permissions != null and !permissions.isRecordAudioPermissionGranted():
		permissions.requestRecordAudioPermission()
	
	# Setup bus effects
	var idx := AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	spectrum = AudioServer.get_bus_effect_instance(idx, 1)
	
	# Setup UI
	slider_vol_filter.value = ignore_tone_below_volume
	
	clear_current_note()
	
func _process(delta: float) -> void:
	processSound()
	# UI
	lbl_tone.text = "Tone: " + current_note + " (" + str(current_fq) + " Hz)"
	lbl_record_exist.text = "Record eff.: " + str(effect != null)
	lbl_spectrum_exist.text = "Spectrum eff.: " + str(spectrum != null)

# Notes detection handling
func processSound():
	var prev_hz := 0.0
	
	var totalEnergy = 0.0
	var energies = []
	
	var largestRange = 0
	var largestRangeFq = 0
	var valumeOfLargestRange = 0

	for i in range(1, VU_COUNT + 1):
		var hz := i * FREQ_MAX / VU_COUNT
		var magnitude := spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy := clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		energies.append(energy)
		prev_hz = hz
		
		# Sum frequencies
		totalEnergy += energy
		
		if largestRange < energy:
			valumeOfLargestRange = energy
			largestRange = energy
			largestRangeFq = hz
			
	
	if valumeOfLargestRange >= ignore_tone_below_volume:
		#print("loudest: " + str(valumeOfLargestRange) + " DB") 
		playedNote(largestRangeFq)
	else:
		#print("ignore input")
		pass

func playedNote(frequency) -> void:
	if frequency <= 0:
		return
	
	var fq = log(frequency / 440.0) / log(2) # NOTE: Explore fq and fqToMidi formula
	var fqToMidi = round(69 + 12 * fq)
	
	current_fq = frequency
	current_note = note_names[int(fqToMidi) % 12]


func _on_vol_filter_slider_value_changed(value: float) -> void:
	ignore_tone_below_volume = value
	lbl_vol_filter.text = str(value)

func clear_current_note():
	current_fq = 0
	current_note = ''
