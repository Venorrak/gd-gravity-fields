# Godot Gravity Fields
### ***The code is in addons/gravityfields, any other code is for tests***

### ***For easy installation the addon's zip is in the release section***

## What is it ?
It's a system allowing you to easily have a mario galaxy gravity mechanic in your game.
You can create different zones with their own gravity that will affect the player.


## What you can do
Here is a list of demos :

Parallel Gravity

![](media/Screen%20Recording%202025-08-15%20234537.gif)

Sphere Gravity

![](media/Screen%20Recording%202025-08-15%20234741.gif)

Taurus Gravity

![](media/Screen%20Recording%202025-08-15%20234916.gif)

Pill shaped gravity

![](media/Screen%20Recording%202025-08-15%20235157.gif)

Other shapes

![](media/Screen%20Recording%202025-08-15%20235527.gif)


## How does it work
Before going into it, here's words and definitions:
- Provider -> Node that applies gravity to the body
- Detector -> Area3D detecting body entering and asigning a Provider to it
- Body -> a RigidBody

### GravityBody3D
![Gravity Body](media/Screenshot%202025-08-15%20235819.png)

The GravityBody3D is a RigidBody3D that can be influenced by our custom gravity. If you don't set the base gravity scale to zero, the body will be influenced by both the custom and the project's gravity. Call `get_custom_gravity` instead of `get_gravity` to get the gravity Vector.

### GPath3D & GCurve3D
![GCurve3D](media/Screenshot%202025-08-15%20235616.png)

The GPath3D and the GCurve3D work together as a provider. The gravity applied to the body will be calculated with the position of the body relative to the nearest point on the path. You can set the force of the gravity and chose the number of "faces" your path will have. For example, no faces the "shape" of the gravity will be like a pill. If you have "faces", the "shape" of the gravity will look like [this](#gpath3d).

### GravityPoint3D
![Gravity Point](media/Screenshot%202025-08-15%20235627.png)

The GravityPoint3D is simply used as a provider for a planet like gravity.

### GravityDetector3D
![Gravity Detector line](media/Screenshot%202025-08-15%20235745.png)

The GravityDetector3D is an Area3D that will asign its gravity provider to an entering GravityBody3D.

![Gravity Detector own](media/Screenshot%202025-08-16%20004124.png)

For parallel gravity, you can assign the GravityDetector's provider to itself of leave it to null. When doing that you need to enable space override and then your gravity will go in the direction you set at the strenght you set.

## Custom Gizmo
You will also have a custom gizmo for each GravityProvider

### GPath3D
no faces (Taurus)
![gizmo circle](media/Screenshot%202025-08-15%20233412.png)

3 faces
![gizmo line triangle](media/Screenshot%202025-08-15%20235235.png)

### GravityPoint3D
![gizmo point](media/Screenshot%202025-08-15%20233510.png)

# WIP
This is a work in progress addon and I'd love to get some feedback on it, you can create an issue if you have a suggestion or if you find a bug. Thank you!

# TODO

- shapes
    - odd shapes ?
        - check nearest surface
- investigate player body & all other PhysicsBody
- documentation
