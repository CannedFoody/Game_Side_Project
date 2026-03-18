extends Area3D
@onready var goal_color_change: Timer = $"../goal_color_change"
@onready var goal_trans: MeshInstance3D = $"../goal_trans"

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball"):
		goal_color_change.start()
		goal_trans.get_active_material(0).albedo_color = Color(0.823, 0.0, 0.573, 1.0)
		body.queue_free()
		GlobalVars.goal_scored = true


func _on_goal_color_change_timeout() -> void:
	goal_trans.get_active_material(0).albedo_color = Color("00a53d")
		
