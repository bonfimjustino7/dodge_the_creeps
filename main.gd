extends Node
#
#var mob_paths = [
	##"res://enemy.tscn",
	#"res://peixe.tscn"	
#]


@export var mob_scene: PackedScene
@export var reward_scene: PackedScene
@onready var heartsContainer = $HUD/HeartsContainer
@onready var backgroundDefault = $TextureRect.texture
@onready var black_ocean = preload("res://art/785.jpg")

var default_lifes = 5
var score
var lifes
var velocity
var default_velocity = randf_range(150.0, 350.0)  # Define a velocidade aleatória
var is_alternate_state = false  # Estado alternado

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	heartsContainer.setMaxHearts(default_lifes)	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_hit() -> void:
	#$Player.blink_hit()
	$Player/HitSound.play()
	$Player/HitTimer.start()
	
	lifes -= 1
	if lifes >= 0: heartsContainer.updateHearts(lifes)
	
	if lifes == 0:
		game_over()

func game_over() -> void:
	$Player.hide()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$RewardTimer.stop()
	
	$HUD.show_game_over()
	$Musica.stop()
	$SomDeMorte.play()
	$BackgroundTimer.stop()


func new_game():
	score = 0
	velocity = default_velocity
	lifes = default_lifes
	heartsContainer.updateHearts(lifes)
	$TextureRect.texture = backgroundDefault
	
	#$Musica.play()
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$BackgroundTimer.start()
		
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
		
	get_tree().call_group("mobs", "queue_free") # destroi todos os inimigos


func populate_node(node: Node, velocity):
	var viewport_rect = get_viewport().get_visible_rect()  # Obtém o tamanho da tela
	
	# Definir posição inicial na borda direita da tela
	var spawn_x = viewport_rect.position.x  # Posição no final da tela (esquerda)
	var spawn_y = randf_range(0, viewport_rect.size.y)  # Posição aleatória na altura da tela

	node.position = Vector2(spawn_x, spawn_y)  # Define a posição do mob
	
	var direction = Vector2(1, randf_range(-0.5, 0.5)).normalized()  # Movendo da direita para a direita
	
	node.rotation = direction.angle()
	
	node.linear_velocity = direction * velocity  # Aplica a velocidade ao mob
	
	add_child(node)

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	$RewardTimer.start()


func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	populate_node(mob, velocity)
	

func _on_background_timer_timeout() -> void:
	is_alternate_state = !is_alternate_state  # Alterna o estado
	if is_alternate_state:		
		$TextureRect.texture = black_ocean
		velocity =  randf_range(350.0, 450.0)
		$Musica.play()
	else:
		$TextureRect.texture = backgroundDefault
		velocity =  default_velocity
		$Musica.stop()
		
	

func _on_reward_timer_timeout() -> void:
	var reward = reward_scene.instantiate()
	populate_node(reward, default_velocity)
