class_name MoveDefinition
extends Resource
## One action, described entirely as data: a normal, a special, a throw, a
## dash, or what a projectile does once released.
##
## Time is in frames (60 per second). Boxes and vectors are in the performer's
## local space: origin at the feet, +x toward the opponent, -y upward.

## Which guard stops the move. Standing guard stops MID and HIGH;
## crouching guard stops MID and LOW; nothing stops HIGH_LOW, which strikes
## high and low together.
enum Height { HIGH, MID, LOW, HIGH_LOW }

## Where a move's spawn appears: at each spawn offset from the performer
## (mirrored by facing) or from its opponent.
enum SpawnOrigin { PERFORMER, TARGET }

@export var id: StringName
## Frames before the first active frame.
@export var startup: int = 5
## Frames during which the hitboxes exist.
@export var active: int = 3
## Frames after the last active frame before the performer can act again.
@export var recovery: int = 10
@export var damage: int = 50
@export var hitstun: int = 15
@export var blockstun: int = 10
## Initial ground-slide speed given to the defender, in px/frame.
@export var knockback: float = 6.0
## Frames both fighters freeze when this move connects.
@export var hitstop: int = 6
@export var height: Height = Height.MID
@export var hitboxes: Array[Rect2] = []
## Grabs instead of striking: cannot be guarded, connects only with a grounded
## opponent who is not stunned, and loses to a strike landing on the same frame.
@export var throw: bool = false
## Nonzero: the defender is knocked down for this many frames (counted once
## grounded, invulnerable throughout) instead of taking hitstun.
@export var knockdown: int = 0
## Frames from the start during which the performer has no hurtbox.
@export var invulnerable: int = 0
## Velocity given on the first frame. For a fighter, x becomes a decelerating
## ground slide and negative y launches it into the air; a launched move keeps
## running after landing, so its recovery happens on the ground. For a spawned
## entity, this is a constant velocity.
@export var motion: Vector2 = Vector2.ZERO
## Released on the first active frame, at spawn_offset: a projectile now,
## a bound spirit later.
@export var spawn: MoveDefinition
@export var spawn_offset: Vector2 = Vector2.ZERO
@export var spawn_origin: SpawnOrigin = SpawnOrigin.PERFORMER
## Several pieces at once, one at each offset; empty means [spawn_offset].
@export var spawn_offsets: Array[Vector2] = []
## Per piece sent (with spawn_offsets): the angle above level it flies at, in
## degrees, at the spawn's own speed (Seimei's birds climbing apart).
@export var spawn_angles: Array[float] = []
## For a spawned move: it travels toward the performer's centreline, from
## whichever side it started on, and stops there for the rest of its life (a
## giant's hand sweeping in to just under its head).
@export var converges: bool = false
## For a spawned move: an unguarded target is seized and carried along,
## held until something else strikes them or the piece expires.
@export var grabs: bool = false
## For a spawned move: a guarded target is not released but pushed along in
## front of it, until it stops.
@export var pushes_on_guard: bool = false
## For a spawned move: downward acceleration each frame, so it flies in an
## arc; it ends when it reaches the ground.
@export var gravity: float = 0.0
## For a spawned move: it is part of its performer (Rokurokubi's head on its
## neck). It is drawn joined to them; a strike on it is a strike on them; and
## it is withdrawn the moment they stop performing the move that sent it.
@export var tethered: bool = false
## For a spawned move: what it leaves on the ground where it lands or strikes
## (a thrown lantern's fire).
@export var leaves: MoveDefinition
## For a spawned move: instead of ending, it turns back when it strikes or
## when it comes down to `turn_height`, and retraces its path to where it
## started, harmless on the way back (Rokurokubi's head).
@export var returns: bool = false
@export var turn_height: float = -80.0
## For a spawned move: it flies on a circle of this radius about a centre at
## `orbit_centre` from where it starts (forward, down), at `orbit_speed`
## radians a frame, over the top toward the opponent. Zero: in a line.
## Damage against a fighter standing on the ground, as a share of its full
## damage: the rising attack is for the air (jumpers, a flying giant's cloud)
## and strikes the grounded only lightly.
@export var grounded_scale: float = 1.0
## A piece that wards off blows: an opponent's strike that meets it stops
## there, harming no one (Seimei's seal).
@export var wards: bool = false
## A fighter this strikes swings at phantoms for this many frames: none of
## its own blows or throws connect (Bewitching Dust).
@export var phantom: int = 0
@export var orbit_radius: float = 0.0
@export var orbit_centre: Vector2 = Vector2.ZERO
@export var orbit_speed: float = 0.0
## A circling piece sized, as it leaves, to come down on the opponent where
## they stand (Rokurokubi's head), rather than always at its full reach.
@export var seeks: bool = false
## Traced from a weapon: for each active frame, the boxes the weapon occupies
## and the damage scale of each ([Rect2, scale] pairs). When present these
## replace `hitboxes` while the move is active; `hitboxes` then holds them
## all, for reach and the like. Built when the fighter is assembled.
@export var frame_strikes: Array = []
## Health restored on the first active frame: to the performer, or, for a
## spirit, to the fighter who summoned it.
@export var heal: int = 0
## On this frame the performer reappears `teleport_distance` beyond the far
## edge of its opponent's body, facing them. -1: no teleport.
@export var teleport_frame: int = -1
@export var teleport_distance: float = 70.0
## The farthest a teleport reaches: with the opponent's near edge further
## than this, the performer only covers this distance and lands before them.
## Zero: no limit.
@export var teleport_range: float = 0.0
## For a spawn over the target: the farthest from the performer it may form;
## beyond, it forms this far ahead. Zero: no limit.
@export var spawn_range: float = 0.0
## Frames before this move can be used again. Zero: no recharge.
@export var cooldown: int = 0
## Frames of armour granted when the move starts: hits still deal damage but
## do not interrupt. Throws ignore armour. A spirit's armour goes to its
## summoner.
@export var armor: int = 0
## On a hit that is not guarded, slows the target's walking and jumping for
## this many frames.
@export var slows: int = 0
## On a hit, holds the target in place, unable to act, for this many frames
## instead of the usual hitstun and knockback (a trap).
@export var paralyse: int = 0
## A counter stance: if struck by a strike while this move is active, the hit
## is ignored and the performer does `counter` instead.
@export var counter: MoveDefinition
## May be performed in the air as well as on the ground.
@export var air: bool = false


func total_frames() -> int:
	return startup + active + recovery


func is_active_on(frame: int) -> bool:
	return frame >= startup and frame < startup + active


## A local box placed in the world for a performer at `origin` facing `facing`.
static func place(local: Rect2, origin: Vector2, facing: int) -> Rect2:
	var x := local.position.x if facing == 1 else -local.position.x - local.size.x
	return Rect2(origin + Vector2(x, local.position.y), local.size)
