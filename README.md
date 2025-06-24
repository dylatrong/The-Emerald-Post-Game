# The Emerald Post

A retro-style first-person shooter built with the Godot Engine, featuring dynamic enemy AI and a fast-paced combat system. This project was originally ported from Godot 3.x and has been rebuilt with a modern, feature-rich character controller and combat loop in Godot 4.

---

## Key Features

* **Advanced First-Person Controller:**
	* Smooth, responsive movement with acceleration and sprinting.
	* Multi-jump system with a configurable double jump.
	* Coyote time and jump buffering for forgiving and fluid platforming.
	* A temporary hover mechanic for added air control.

* **Dynamic Combat System:**
	* Real-time, projectile-based laser gun with unlimited ammo.
	* Player health and damage system.
	* Full audio feedback for shooting, taking damage, and enemy interactions.

* **Advanced Enemy AI:**
	* **Melee Enemy:** A persistent pursuer that uses a vision system to detect the player. It will only attack after it has a clear line of sight.
	* **Ninja Enemy:** A more intelligent, ranged opponent that uses a state machine to dynamically switch between chasing, strafing to evade shots, and attacking with projectiles.
	* Enemies provide vocal feedback when hit and have unique death sounds.

* **3D In-World HUD:**
	* A minimalist HUD with 3D models for the player's gun and crosshair.
	* A real-time 3D health bar that dynamically scales based on the player's current health.

* **Game Loop:**
	* A complete game loop where the player respawns at the start of the level and all enemies are reset upon player death.

---

## How to Play

* **Movement:** WASD
* **Look:** Mouse
* **Jump / Double Jump:** Spacebar
* **Sprint:** Shift
* **Fire Laser:** Left Mouse Button

---

## Getting Started for Developers

This project is managed with Git and is set up for collaboration.

**Prerequisites:**
* [Godot Engine v4.4.1](https://godotengine.org/) or later.
* [Git](https://git-scm.com/) installed on your system.
* (Recommended) [GitHub Desktop](https://desktop.github.com/) for a user-friendly Git interface.

**Cloning the Repository:**
1.  Ensure you have been invited to the private repository as a collaborator.
2.  Open GitHub Desktop and go to `File > Clone Repository...` or use the following command in your terminal:
	```bash
	git clone [https://github.com/YourUsername/The-Emerald-Post-Game.git](https://github.com/YourUsername/The-Emerald-Post-Game.git)
	```
3.  Navigate to the folder where you cloned the project.
4.  Open the Godot Project Manager, click **"Import"**, and select the `project.godot` file from the cloned folder.

**Standard Workflow:**
1.  **Pull:** Before starting work, always **Pull Origin** to get the latest changes from the team.
2.  **Work:** Make your edits in the Godot editor.
3.  **Commit:** Save your progress with a clear, descriptive commit message.
4.  **Push:** **Push Origin** to upload your commits and share your work with the team.

---
*This README was created on June 24, 2025.*
