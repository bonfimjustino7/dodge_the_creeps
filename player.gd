extends Area2D

signal hit

@export var speed = 400
var screen_size

@onready var effects = $Effects
var safe_life = false
var has_hiting = false



func _ready() -> void:
	screen_size = get_viewport_rect().size
	effects.play("RESET")
	has_hiting = false
	safe_life = false
	

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("mover_direita"):
		velocity.x += 1
	if Input.is_action_pressed("mover_esquerda"):
		velocity.x -= 1
	if Input.is_action_pressed("mover_baixo"):
		velocity.y += 1
	if Input.is_action_pressed("mover_cima"):
		velocity.y -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk2"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "jump"
		$AnimatedSprite2D.flip_v = velocity.y > 0
	

func _on_body_entered(body: Node2D):	
	if safe_life:
		return

	#print_debug(body.name)
	if body.is_in_group("reward"):
		effects.play("blink_safe")
		print_debug("Iniciou safe")
		$SafeTimer.start()
		safe_life = true
		$HitTimer.stop()
	else:		
		has_hiting = true
		effects.play("blink")
		hit.emit()

#func blink_hit():
	#effects.play("blink")

func start(pos):
	position = pos
	show()

func _on_hit_timer_timeout() -> void:	
	effects.play("RESET")
	has_hiting = false
#
func _on_safe_timer_timeout() -> void:
	safe_life = false
	effects.play("RESET")
	print_debug("Finalizou safe")
