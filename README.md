# Godot Sailing Game

A sailing game prototype built in Godot 4 with realistic wind and boat physics.

## Real Sailing Mechanics

This version includes:

- **Wind system**: True wind vector in the world with gusts
- **Apparent wind**: Computed from boat velocity and true wind
- **Sail force model**: Drive and drift based on wind angle and sail trim
- **Boat heel**: The hull tilts (rotates on Z) based on lateral force
- **Velocity-based movement**: Boat accelerates and decelerates realistically
- **Water drag**: Realistic deceleration when sails are eased out

## How It Works

1. **Wind** is fixed in world space and can gust
2. **Apparent wind** = true wind − boat velocity
3. **Sail force** depends on sail angle relative to apparent wind
4. **Close to wind** (within ~30°) gives poor drive
5. **Broad reach** gives maximum drive and heel
6. **Trim (W/S)** controls sail angle and power
7. **Steer (A/D)** with rudder; boat heels as it turns

## Controls

- **W / S**: Trim sail in and out
- **A / D**: Steer left and right

## Files

- `project.godot` – project settings
- `scenes/main.tscn` – main scene
- `scripts/ocean_mesh.gd` – ocean mesh with waves
- `scripts/boat.gd` – boat physics with wind and heel
- `scripts/wind_system.gd` – wind control (can change wind at runtime)
- `scripts/camera_controller.gd` – follow camera
- `shaders/ocean.gdshader` – water shader

## Next Steps

- Add UI to show wind direction and boat speed
- Add islands and racing buoys
- Add multiple sails (jib, main, spinnaker)
- Add wave impact on boat physics
- Add AI competitors
