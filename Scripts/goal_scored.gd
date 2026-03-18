extends Label

var tween_running = false

func _ready() -> void:
	self.modulate = Color(1, 1, 1, 0)

func _process(delta: float) -> void:
	if GlobalVars.goal_scored and not tween_running:
		goal_scored()

func goal_scored():
	tween_running = true
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
	
	# After fade in, wait 1 second, then fade out
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	
	# When done, allow new tweens
	tween.finished.connect(self._on_tween_finished)

func _on_tween_finished():
	tween_running = false
	GlobalVars.goal_scored = false  # optionally reset
