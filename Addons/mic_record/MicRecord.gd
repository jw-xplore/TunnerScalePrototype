extends Control

var effect: AudioEffect
var recording: AudioStreamWAV

var stereo := true
var mix_rate := 44100  # This is the default mix rate on recordings.
var format := AudioStreamWAV.FORMAT_16_BITS  # This is the default format on recordings.

# Spectrum analyzer
var spectrum: AudioEffectSpectrumAnalyzerInstance
const VU_COUNT = 2048
const FREQ_MAX = 2000.0
const MIN_DB = 60


func _ready() -> void:
	var idx := AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	spectrum = AudioServer.get_bus_effect_instance(idx, 1)


func _process(delta: float) -> void:
	#pass
	processSound()
	# Show input frequency
	#print("Input fq: " + $AudioStreamRecord.)

func _on_record_button_pressed() -> void:
	if effect.is_recording_active():
		recording = effect.get_recording()
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		effect.set_recording_active(false)
		recording.set_mix_rate(mix_rate)
		recording.set_format(format)
		recording.set_stereo(stereo)
		$RecordButton.text = "Record"
		$Status.text = ""
	else:
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		effect.set_recording_active(true)
		$RecordButton.text = "Stop"
		$Status.text = "Status: Recording..."


func _on_play_button_pressed() -> void:
	print_rich("\n[b]Playing recording:[/b] %s" % recording)
	print_rich("[b]Format:[/b] %s" % ("8-bit uncompressed" if recording.format == 0 else "16-bit uncompressed" if recording.format == 1 else "IMA ADPCM compressed"))
	print_rich("[b]Mix rate:[/b] %s Hz" % recording.mix_rate)
	print_rich("[b]Stereo:[/b] %s" % ("Yes" if recording.stereo else "No"))
	var data := recording.get_data()
	print_rich("[b]Size:[/b] %s bytes" % data.size())
	$AudioStreamPlayer.stream = recording
	$AudioStreamPlayer.play()


func _on_play_music_pressed() -> void:
	if $AudioStreamPlayer2.playing:
		$AudioStreamPlayer2.stop()
		$PlayMusic.text = "Play Music"
	else:
		$AudioStreamPlayer2.play()
		$PlayMusic.text = "Stop Music"


func _on_save_button_pressed() -> void:
	var save_path: String = $SaveButton/Filename.text
	recording.save_to_wav(save_path)
	$Status.text = "Status: Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]


func _on_mix_rate_option_button_item_selected(index: int) -> void:
	match index:
		0:
			mix_rate = 11025
		1:
			mix_rate = 16000
		2:
			mix_rate = 22050
		3:
			mix_rate = 32000
		4:
			mix_rate = 44100
		5:
			mix_rate = 48000
	if recording != null:
		recording.set_mix_rate(mix_rate)


func _on_format_option_button_item_selected(index: int) -> void:
	match index:
		0:
			format = AudioStreamWAV.FORMAT_8_BITS
		1:
			format = AudioStreamWAV.FORMAT_16_BITS
		2:
			format = AudioStreamWAV.FORMAT_IMA_ADPCM
	if recording != null:
		recording.set_format(format)


func _on_stereo_check_button_toggled(button_pressed: bool) -> void:
	stereo = button_pressed
	if recording != null:
		recording.set_stereo(stereo)


func _on_open_user_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


# Notes detection handling
func processSound():
	var prev_hz := 0.0
	
	var totalEnergy = 0.0
	var energies = []
	
	var largestRange = 0
	var largestRangeFq = 0

	for i in range(1, VU_COUNT + 1):
		var hz := i * FREQ_MAX / VU_COUNT
		var magnitude := spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy := clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		energies.append(energy)
		prev_hz = hz
		
		# Sum frequencies
		totalEnergy += energy
		
		if largestRange < energy:
			largestRange = energy
			largestRangeFq = hz
			
	#print("Fr sum res: " + str(res))
	#print("largestRangeFq: " + str(largestRangeFq) + "Left [" + )
	playedNote(largestRangeFq)

func playedNote(frequency) -> void:
	if frequency <= 0:
		return
	
	var fq = log(frequency / 440.0) / log(2) # NOTE: Explore fq and fqToMidi formula
	var fqToMidi = round(69 + 12 * fq)
	
	var note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
	var note = note_names[int(fqToMidi) % 12]
	
	print("Note: " + str(note) + "(" + str(frequency) + "Hz)")
