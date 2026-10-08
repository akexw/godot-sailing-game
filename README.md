# Godot Sailing Game

A small sailing game prototype built in Godot 4 with a procedural ocean mesh and a simple floating boat.

## Real sailing model

This version is closer to real sailing behavior:

- the boat only gains drive when the wind is coming from the correct side of the hull
- pointing too directly into the wind gives poor propulsion
- falling off the wind or sailing across the beam gives better speed
- rudder steering and sail trim both affect movement and drift

## Controls

- W / S: trim the sail in and out
- A / D: steer left and right

## Included files

- `project.godot` – project configuration
- `scenes/main.tscn` – main scene with ocean and boat
- `scripts/ocean_mesh.gd` – ocean plane setup and wave height logic
- `scripts/boat.gd` – more realistic sailing behavior and floating
- `scripts/camera_controller.gd` – follow camera
- `shaders/ocean.gdshader` – ocean animation shader

## Next ideas

- add true wind and apparent wind vectors
- add boat roll and heel from sail force
- add islands and collisions
- add AI rivals and finish line
