extends Node
#
#var mob_paths = [
	##"res://enemy.tscn",
	#"res://peixe.tscn"	
#]


@export var mob_scene: PackedScene
@onready var heartsContainer = $HUD/HeartsContainer

var default_lifes = 3
var score
var lifes = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	heartsContainer.setMaxHearts(lifes)	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_hit() -> void:
	lifes -= 1
	heartsContainer.updateHearts(lifes)	
	
	if lifes == 0:
		game_over()

func game_over() -> void:
	$Player.hide()
	$ScoreTimer.stop()
	$MobTimer.stop()
	
	$HUD.show_game_over()
	$Musica.stop()
	$SomDeMorte.play()	


func new_game():
	score = 0
	lifes = default_lifes
	
	$Musica.play()
	$Player.start($StartPosition.position)
	$StartTimer.start()
		
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
		
	get_tree().call_group("mobs", "queue_free") # destroi todos os inimigos


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout() -> void:
	var mob = get_enemy()
	
	var viewport_rect = get_viewport().get_visible_rect()  # Obtém o tamanho da tela
	
	# Definir posição inicial na borda direita da tela
	var spawn_x = viewport_rect.position.x  # Posição no final da tela (esquerda)
	var spawn_y = randf_range(0, viewport_rect.size.y)  # Posição aleatória na altura da tela

	mob.position = Vector2(spawn_x, spawn_y)  # Define a posição do mob
	
	var direction = Vector2(1, randf_range(-0.5, 0.5)).normalized()  # Movendo da direita para a direita
	
	mob.rotation = direction.angle()
	
	var velocity = randf_range(150.0, 350.0)  # Define a velocidade aleatória
	mob.linear_velocity = direction * velocity  # Aplica a velocidade ao mob
	
	add_child(mob)

func get_enemy():
	var enemy = mob_scene.instantiate()
	return enemy
	#var random_index = randi() % mob_paths.size()
	#var selected_scene = load(mob_paths[random_index])  # Carrega a cena	
	#return selected_scene.instantiate()
	
