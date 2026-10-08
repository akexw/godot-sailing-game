# Godot Sailing Game

A playable sailing game prototype in Godot 4 with real wind physics, boat heel, racing waypoints, and islands.

## Features

### Sailing Physics
- True wind vector with gusts
- Apparent wind calculation from boat velocity
- Realistic sail force model (poor drive close to wind, best on broad reach)
- Boat heel and roll from lateral force
- Water drag and acceleration
- Velocity-based movement

### Gameplay
- **Race mode**: Navigate waypoints around the map
- **Islands**: Static obstacles to sail around
- **HUD**: Speed, sail trim, wind direction, distance to waypoint
- **Wind compass**: Visual wind direction indicator

## Controls

- **W / S**: Trim sail in (W) and out (S)
- **A / D**: Steer left (A) and right (D)

## HUD Display

- **Speed**: Current boat velocity in knots
- **Trim**: Sail trim percentage (0-100%)
- **Wind**: True wind direction
- **Wind compass**: Visual indicator showing wind direction
- **Distance to waypoint**: How far to the next racing buoy
- **Target**: Heading needed to reach the waypoint

## Race Objective

Navigate through a series of waypoints in a counter-clockwise loop:
1. Start near the origin (0, 0)
2. Head to waypoint 1 (100, -100)
3. Head to waypoint 2 (150, 50)
4. Head to waypoint 3 (-50, 150)
5. Head to waypoint 4 (-150, -50)
6. Return to start and repeat

The timer resets each lap.

## Customization

### Wind
Edit `WindSystem` in the scene to change:
- `wind_direction`: Vector3 pointing direction of true wind
- `wind_strength`: Magnitude of wind (default 12 knots)
- `wind_gust_speed`: How fast gusts pulse
- `wind_gust_scale`: Amplitude of wind variation

### Boat
Edit `Boat` node properties:
- `max_speed`: Maximum boat speed (default 20 knots)
- `max_heel_angle`: How much the boat tilts (default 0.45 rad ≈ 26°)
- `water_drag`: How quickly the boat slows without sails (default 0.15)

### Race
Edit `RaceManager` node:
- `waypoints`: Array of Vector3 positions for the race course
- `waypoint_radius`: How close you need to be to "round" a waypoint (default 20m)

## Next Ideas

- Add a more detailed boat model with sails
- Add a spinnaker for downwind sailing
- Add realistic rudder behavior and yaw inertia
- Add multiple difficulty levels with different wind conditions
- Add AI boats as competitors
- Add a weather system with wind shifts
- Add waves that affect boat movement
