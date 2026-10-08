extends Control

var boat: Boat
var wind_system: Node3D

func _ready() -> void:
	boat = get_tree().get_first_node_in_group("boat") as Boat
	wind_system = get_tree().get_first_node_in_group("wind_system")
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not boat:
		return

	var screen_size: Vector2 = get_viewport_rect().size
	var margin: float = 20.0

	var speed: float = boat.boat_velocity.length()
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin), "Speed: %.1f kt" % speed, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 30), "Trim: %.0f%%" % (boat.sail_trim * 100), HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

	# Use boat's wind direction (true wind) for display
	var true_wind_dir: Vector3 = boat.wind_direction
	var true_wind_angle_deg: float = rad_to_deg(atan2(true_wind_dir.x, -true_wind_dir.z))
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 60), "True Wind: %.0f°" % true_wind_angle_deg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

	# Calculate apparent wind angle relative to boat
	var apparent_wind: Vector3 = boat.compute_apparent_wind()
	var local_apparent_wind: Vector3 = boat.transform.basis.inverse() * apparent_wind
	var apparent_wind_angle_deg: float = rad_to_deg(atan2(local_apparent_wind.x, -local_apparent_wind.z))
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 90), "App Wind: %.0f°" % apparent_wind_angle_deg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

	# Display boat heading
	var boat_heading_deg: float = rad_to_deg(boat.current_heading)
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 120), "Heading: %.0f°" % boat_heading_deg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

	draw_wind_compass(Vector2(screen_size.x - 120, margin + 40))

	if has_node("/root/Main/RaceManager"):
		var race_mgr: Node = get_node("/root/Main/RaceManager")
		var waypoint_dist: float = race_mgr.get_distance_to_waypoint(boat.global_position)
		draw_string(ThemeDB.fallback_font, Vector2(margin, screen_size.y - 60), "Distance to waypoint: %.1f m" % waypoint_dist, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		if race_mgr.current_waypoint < race_mgr.waypoints.size():
			var waypoint_heading: float = race_mgr.get_waypoint_heading(boat.global_position)
			draw_string(ThemeDB.fallback_font, Vector2(margin, screen_size.y - 30), "Target: %.0f°" % waypoint_heading, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

func draw_wind_compass(center: Vector2) -> void:
	var radius: float = 30.0
	var true_wind_dir: Vector3 = boat.wind_direction
	var true_wind_angle: float = atan2(true_wind_dir.x, -true_wind_dir.z)
	# Rotate wind angle by boat heading to make compass rotate with boat
	var boat_heading: float = boat.current_heading
	var wind_angle_relative: float = true_wind_angle - boat_heading

	draw_circle(center, radius, Color.DARK_GRAY)
	draw_circle(center, radius, Color.WHITE, false, 2.0)
	# North arrow points up relative to boat heading
	draw_string(ThemeDB.fallback_font, center + Vector2(0, -radius - 15), "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)

	# Wind arrow rotates relative to boat heading
	var wind_end: Vector2 = center + Vector2(sin(wind_angle_relative), -cos(wind_angle_relative)) * (radius - 5)
	draw_line(center, wind_end, Color.LIGHT_BLUE, 3.0)
	draw_circle(wind_end, 4.0, Color.LIGHT_BLUE)
