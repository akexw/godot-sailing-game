extends CanvasLayer

var boat: Boat
var wind_system: Node3D

func _ready() -> void:
	boat = get_tree().get_first_node_in_group("boat")
	wind_system = get_tree().get_first_node_in_group("wind_system")

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not boat:
		return

	var screen_size = get_viewport_rect().size
	var margin = 20.0
	
	# Speed display
	var speed = boat.boat_velocity.length()
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin), "Speed: %.1f kt" % speed, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	
	# Sail trim
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 30), "Trim: %.0f%%" % (boat.sail_trim * 100), HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	
	# Wind direction indicator
	var wind_dir = wind_system.wind_direction if wind_system else Vector3.ZERO
	var wind_angle_deg = rad_to_deg(atan2(wind_dir.x, -wind_dir.z))
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 60), "Wind: %.0f°" % wind_angle_deg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	
	# Wind compass
	draw_wind_compass(Vector2(screen_size.x - 120, margin + 40))
	
	# Race info
	if has_node("/root/Main/RaceManager"):
		var race_mgr = get_node("/root/Main/RaceManager")
		var waypoint_dist = race_mgr.get_distance_to_waypoint(boat.global_position)
		draw_string(ThemeDB.fallback_font, Vector2(margin, screen_size.y - 60), "Distance to waypoint: %.1f m" % waypoint_dist, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		
		if race_mgr.current_waypoint < race_mgr.waypoints.size():
			var waypoint_heading = race_mgr.get_waypoint_heading(boat.global_position)
			draw_string(ThemeDB.fallback_font, Vector2(margin, screen_size.y - 30), "Target: %.0f°" % waypoint_heading, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

func draw_wind_compass(center: Vector2) -> void:
	var radius = 30.0
	var wind_dir = wind_system.wind_direction if wind_system else Vector3.ZERO
	var wind_angle = atan2(wind_dir.x, -wind_dir.z)
	
	# Draw circle
	draw_circle(center, radius, Color.DARK_GRAY)
	draw_circle(center, radius, Color.WHITE, false, 2.0)
	
	# Draw cardinal directions
	draw_string(ThemeDB.fallback_font, center + Vector2(0, -radius - 15), "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)
	
	# Draw wind arrow
	var wind_end = center + Vector2(sin(wind_angle), -cos(wind_angle)) * (radius - 5)
	draw_line(center, wind_end, Color.LIGHT_BLUE, 3.0)
	draw_circle(wind_end, 4.0, Color.LIGHT_BLUE)
