extends Control
class_name RatingDialog

const MAX_MISTAKES_A = 2
const MAX_MISTAKES_B = 4
const MAX_MISTAKES_C = 6

@export var lbl_rating: Label

func _ready() -> void:
	visible = false

func rate(mistakes: int) -> int:	
	var rating: int = 0
	var rating_text: String = ""
	
	if mistakes <= MAX_MISTAKES_A:
		rating = 1
		rating_text = "A"
	elif mistakes <= MAX_MISTAKES_B:
		rating = 2
		rating_text = "B"
	elif mistakes <= MAX_MISTAKES_C:
		rating = 3
		rating_text = "C"
	else:
		rating = 4
		
	# Show UI
	visible = true
	lbl_rating.text = "Rating: " + rating_text
	if rating > 3:
		lbl_rating.text = "You need more practice."
		
	return rating
