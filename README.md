# nextdisplay
a 3D/VR desktop environment for computers built in lua

[![forthebadge](https://forthebadge.com/images/badges/built-by-developers.svg)](https://forthebadge.com)

# Installation
```
git clone https://github.com/krishpranav/nextdisplay
```

# Starting
```
arcan ./nextdisplay
```

# Clients
```
ARCAN_CONNPATH=name
```

# Roadmap
- [ ] Devices
  - [x] Simulated (3D-SBS)
  - [x] Simple (Monoscopic 3D)
  - [x] Single HMD
  - [ ] Distortion Model
    - [p] Shader Based
    - [ ] Mesh Based
    - [ ] Validation
  - [x] Mouse
  - [x] Keyboard
  - [ ] Front-Camera composition

- [ ] Models
  - [x] Primitives
    - [ ] Cube
      - [x] Basic mesh
      - [x] 1 map per face
      - [ ] cubemapping
    - [x] Sphere
      - [x] Basic mesh
      - [x] Hemisphere
    - [x] Cylinder
      - [x] Basic mesh
      - [x] half-cylinder
    - [x] Rectangle
    - [ ] Border/Background
    - [ ] GlTF2 (.bin)
      - [ ] Simple/Textured Mesh
      - [ ] Skinning/Morphing/Animation
      - [ ] Physically Based Rendering
    - [x] Stereoscopic Mapping
      - [x] Side-by-Side
      - [x] Over-and-Under
      - [x] Swap L/R Eye
      - [ ] Split (left- right sources)
 - [x] Events
      - [x] On Destroy

- [x] Layouters
  - Tiling / Auto
    - [x] Circular Layers
    - [x] Swap left / right
    - [x] Cycle left / right
    - [x] Transforms (spin, nudge, scale)
    - [x] Curved Planes
    - [x] Billboarding
    - [x] Fixed "infinite" Layers
    - [x] Vertical hierarchies
    - [x] Connection- activated models

 - Static / Manual
    - [ ] Curved Plane
    - [ ] Drag 'constraint' solver (collision avoidance)
    - [ ] Draw to Spawn

- [ ] Clients
  - [x] Built-ins (terminal/external connections)
  - [ ] Launch targets
  - [x] Xarcan
  - [x] Wayland-simple (toplevel/fullscreen only)
  - [ ] Wayland-composited (xdg-popups, subsurfaces, xwayland)

- [ ] Tools
  - [ ] Basic 'listview' popup
  - [x] Console
  - [ ] Button-grid / Streamdeck
  - [x] Socket- control IPC

Milestone 2:

- [ ] Advanced Layouters
  - [ ] Room Scale
  - [ ] Portals / Space Switching

- [ ] Improved Rendering
  - [ ] Equi-Angular Cubemaps
  - [ ] Stencil-masked Composition
  - [ ] Surface- projected mouse cursor

- [ ] Devices
  - [ ] Gloves
  - [ ] Eye Tracker
  - [ ] Video Capture Analysis
  - [ ] Positional Tracking / Tools
  - [ ] Dedicated Handover/Leasing
  - [ ] Reprojection
  - [ ] Mouse
  - [ ] Gesture Detection
  - [ ] Sensitivity Controls
  - [ ] Keyboard
    - [ ] Repeat rate controls
    - [ ] Runtime keymap switching
  - [ ] Multiple- HMDs
    - [ ] Passive
    - [ ] Active

- [ ] Clients
  - [ ] Full Wayland-XDG
    - [ ] Custom cursors
    - [ ] Multiple toplevels
    - [ ] Popups
    - [ ] Positioners
  - [ ] Full LWA (3D and subsegments)
    - [ ] Native Nested 3D Clients
    - [ ] Adoption (Crash Recovery, WM swapping)
    - [ ] Clipboard support

- [ ] Convenience
  - [ ] Streaming / Recording

Milestone 3:

- [ ] Devices
  - [ ] Haptics
  - [ ] Multiple, Concurrent HMDs
  - [ ] Advanced Gesture Detection
  - [ ] Kinematics Predictive Sensor Fusion

- [ ] Networking
  - [ ] Share Space
  - [ ] Dynamic Resource Streaming
  - [ ] Avatar Synthesis
  - [ ] Filtered sensor state to avatar mapping
  - [ ] Voice Chat

- [ ] Clients
  - [ ] Alternate Representations
  - [ ] Dynamic LoD

- [ ] Rendering
  - [ ] Culling
  - [ ] Physics / Collision Response
  - [ ] Multi-Channel Signed Distance Fields
