class_name Intent
extends RefCounted
## What a controller wants on one frame. Human input and CPU logic both reduce
## to this, so a fighter never knows which is driving it.

## Screen-relative horizontal direction: -1, 0 or +1.
var x: int = 0
var up: bool = false
var down: bool = false
## Button presses (edges, not holds) on this frame. In command notation these
## are A, B, C and D.
var light: bool = false
var heavy: bool = false
var special: bool = false
var spirit: bool = false
