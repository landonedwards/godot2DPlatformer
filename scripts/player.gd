extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_hitbox: Area2D = $AnimatedSprite2D/SwordHitbox

var is_attacking = false
	
func _ready():
	# Start with hitbox disabled
	sword_hitbox.monitoring = false
	sword_hitbox.body_entered.connect(_on_sword_hit)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("attack_right") and not is_attacking:
		attack()
		return
		
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func attack():
	is_attacking = true
	
	# Position hitbox based on which direction player is facing
	if animated_sprite.flip_h:
		is_attacking = true
	animated_sprite.play("attack_right")
	
	# Enable hitbox when sword extends (adjust timing as needed)
	await get_tree().create_timer(0.1).timeout
	enable_sword_hitbox()
	
	# Wait for attack animation duration (5 frames at ~10 FPS = 0.5s)
	await get_tree().create_timer(0.4).timeout
	disable_sword_hitbox()
	is_attacking = false

func enable_sword_hitbox():
	sword_hitbox.monitoring = true

func disable_sword_hitbox():
	sword_hitbox.monitoring = false

func _on_sword_hit(body):
	# Check if it's an enemy
	if body.is_in_group("enemies"):
		body.queue_free()  # Makes enemy disappear
