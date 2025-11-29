# Cloth Sim

A 2D physics simulator built in Godot using verlet integration to create realistic cloth and rope simulations.

## Features

- **Interactive point creation** - Click to add points to your simulation
- **Constraint system** - Connect points with sticks that maintain their distance
- **Gravity simulation** - Watch your creations fall and swing naturally
- **Lock points** - Pin points in place to create anchored cloth or hanging ropes
- **Real-time editing** - Cut connections and modify your simulation while it runs
- **Verlet integration** - Stable physics simulation with customizable iteration count

## Controls

| Input | Action |
|-------|--------|
| **Left Click** | Create a new point, or connect the selected point to another point |
| **Middle Click** | Lock/unlock a point (locked points turn pink) |
| **Right Click + Hover** | Cut sticks by hovering over them |
| **Space** | Pause/unpause the simulation |
| **Escape** | Exit the application |

## How to Use

1. **Creating Points**: Left-click anywhere to create a point
2. **Connecting Points**: 
   - Left-click on a point to select it
   - Left-click on another point to connect them with a stick
   - Or left-click on empty space to create a new point and connect to it
3. **Locking Points**: Middle-click on a point to lock it in place (useful for creating anchored cloth)
4. **Cutting Connections**: Hold right-click and hover over a stick to cut it
5. **Running Simulation**: Press Space to start/stop the physics simulation

## Configuration

The simulator includes several customizable parameters:

### Simulator Settings
- **Gravity**: Strength of gravitational pull (default: 980.0)
- **Number of Iterations**: Higher values = more stable simulation at the cost of performance (default: 5)

### Point Settings
- **Point Radius**: Visual size of points (default: 10.0)
- **Point Margin**: Selection area around points (default: 5.0)

### Stick Settings
- **Stick Thickness**: Visual thickness of connections (default: 10.0)
- **Stick Margin**: Cut detection area (default: 10.0)

### Initial Box
- **Initialize Box**: Start with a pre-made cloth grid
- **Grid Spacing**: Distance between grid points (default: 40.0)
- **Grid Width/Height**: Number of points in the grid (default: 10x10)

## Technical Details

The simulation uses **verlet integration**, which stores both current and previous positions for each point. This allows for stable physics simulation without explicitly tracking velocity. The constraint solver runs multiple iterations per frame to reduce jitter and maintain stick lengths accurately.

## Requirements

- Godot 4.x

## Installation

1. Clone this repository
2. Open the project in Godot
3. Run the scene

## License

This project is under the MIT license, see LICENSE for more information.

## Credits

Created using Godot Engine
