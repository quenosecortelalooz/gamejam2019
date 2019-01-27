extends MarginContainer

onready var tween = $Tween
onready var bar = $Bars/LightBar/TextureProgress

var animated_light = 0


func _ready():
	var lantern_power_max = $"../../.".lantern_power_max
	bar.max_value = lantern_power_max
	update_light(lantern_power_max)


func _on_Level_lanternPowerChanged(lantern_power):
	update_light(lantern_power)


func update_light(new_value):
	tween.interpolate_property(self, "animated_light", animated_light, new_value, 0.1, Tween.EASE_IN, Tween.EASE_IN)
	if not tween.is_active():
		tween.start()


func _process(delta):
	var round_value = round(animated_light)
	bar.value = round_value


func _on_Player_died():
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	tween.interpolate_property(self, "modulate", start_color, end_color, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
