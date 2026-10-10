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
	
	# display wind speed
	var wind_speed: float = boat.true_wind.length()
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 180), "Wind speed: %.1f kt" % wind_speed, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

	# Use boat's wind direction (true wind) for display
	var true_wind_dir: Vector3 = boat.wind_direction
	var true_wind_angle_deg: float = rad_to_deg(atan2(true_wind_dir.x, true_wind_dir.z))
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 60), "True Wind: %.0f°" % true_wind_angle_deg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	
	# Calculate apparent wind angle relative to boat
	var apparent_wind: Vector3 = boat.compute_apparent_wind()
	var local_apparent_wind: Vector3 = boat.transform.basis.inverse() * apparent_wind
	var apparent_wind_angle_deg: float = rad_to_deg(atan2(local_apparent_wind.x, -local_apparent_wind.z))
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 90), "App Wind: %.0f°" % apparent_wind_angle_deg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

	# Display boat heading
	var boat_heading_deg: float = rad_to_deg(boat.current_heading)
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 120), "Heading: %.0f°" % boat_heading_deg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	
	# wind to heading angle as computed by boat
	var disp_angle_diff: float = boat.anglediff
	draw_string(ThemeDB.fallback_font, Vector2(margin, margin + 210), "AD: %.2f radd" % disp_angle_diff, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.BLACK)
	
	

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
	
	# True wind direction in world space
	var true_wind_dir: Vector3 = boat.wind_direction
	var true_wind_angle: float = atan2(true_wind_dir.x, true_wind_dir.z)
	
	# Add PI to show where wind comes FROM instead of where it goes TO
	var wind_from_angle: float = true_wind_angle + PI
	
	# Boat heading in world space
	var boat_heading: float = boat.current_heading
	
	# Compass rose angle relative to boat heading (boat always points up)
	var compass_rotation: float = boat_heading
	
	# Draw compass circle
	draw_circle(center, radius, Color.DARK_GRAY)
	draw_circle(center, radius, Color.WHITE, false, 2.0)
	
	# Draw boat heading indicator (always pointing up)
	draw_line(center, center + Vector2(0, -radius + 5), Color.RED, 3.0)
	draw_circle(center + Vector2(0, -radius + 5), 4.0, Color.RED)
	
	# Draw cardinal directions rotated relative to boat heading
	var north_angle: float = compass_rotation
	var east_angle: float = compass_rotation + PI * 0.5
	var south_angle: float = compass_rotation + PI
	var west_angle: float = compass_rotation + PI * 1.5
	
	var north_pos: Vector2 = center + Vector2(sin(north_angle), -cos(north_angle)) * (radius - 12)
	var east_pos: Vector2 = center + Vector2(sin(east_angle), -cos(east_angle)) * (radius - 12)
	var south_pos: Vector2 = center + Vector2(sin(south_angle), -cos(south_angle)) * (radius - 12)
	var west_pos: Vector2 = center + Vector2(sin(west_angle), -cos(west_angle)) * (radius - 12)
	
	draw_string(ThemeDB.fallback_font, north_pos, "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, east_pos, "E", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.GRAY)
	draw_string(ThemeDB.fallback_font, south_pos, "S", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.GRAY)
	draw_string(ThemeDB.fallback_font, west_pos, "W", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.GRAY)
	
# Wind arrow shows where wind COMES FROM (add PI to direction)
	# Same convention as the N/E/S/W labels: world bearing + boat heading
	var wind_angle_relative: float = wind_from_angle + boat_heading
	var wind_end: Vector2 = center + Vector2(sin(wind_angle_relative), -cos(wind_angle_relative)) * (radius - 5)
	draw_line(center, wind_end, Color.LIGHT_BLUE, 3.0)
	draw_circle(wind_end, 4.0, Color.LIGHT_BLUE)
