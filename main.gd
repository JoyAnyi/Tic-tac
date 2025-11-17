extends Node

@export var cross_scence : PackedScene
@export var circle_scene : PackedScene

var player : int
var moves : int
var temp_marker
var winner : int
var player_panel_position : Vector2i
var grid_data : Array
var grid_position : Vector2i 
var board_size: int 
var cell_size : int
var row_sum : int
var col_sum : int
var diagonal1_sum : int
var diagonal2_sum : int
func _ready():
	board_size = $Board.texture.get_width()
	print(board_size)
	#Divide boad size by 2 to get the size of the individual cell
	cell_size = board_size / 3
	#print(cell_size)
	#Get coordinates of small panel on right side of window
	player_panel_position = $PlayerPanel.get_position()
	new_game()
func _process(delta: float):
	pass
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
#Checks if mouse is on the game board
			if event.position.x < board_size:
				#convert mouse position into grid location
				grid_position = Vector2i(event.position/cell_size)
				#print(event.position)
				#print(grid_pos)
				if grid_data[grid_position.y][grid_position.x] == 0:
					moves +=1
					grid_data[grid_position.y][grid_position.x] = player
					#Place that placer's marker
					create_marker(player, grid_position * cell_size + Vector2i(cell_size/2, cell_size/2))
					if check_win() !=0:
						get_tree().paused = true
						$GameOverMenu.show()
						if winner == 1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 1 wins!!!! 🎉"
						elif winner == -1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 2 wins!!!! 🎉"
					#check if the board has been filled
					elif moves == 9:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu.get_node("ResultLabel").text = "It's a tie 🪢"
					player *= -1
					temp_marker.queue_free()
					#Update the player marker
					create_marker(player,player_panel_position + Vector2i(cell_size/2, cell_size/2),true)
					print(grid_data)
func new_game():
	player = 1
	moves = 0
	winner = 0
	grid_data = [
	[0,0,0],
	[0,0,0],
	[0,0,0]
	]
	
	row_sum = 0
	col_sum = 0
	diagonal1_sum = 0 
	diagonal2_sum = 0
	#clear existing markers
	get_tree().call_group("crosses", "queue_free")
	get_tree().call_group("circles", "queue_free")
#Create a marker to show starting players turn
	create_marker(player,player_panel_position + Vector2i(cell_size/2, cell_size/2),true)
	$GameOverMenu.hide()
	get_tree().paused = false
func create_marker(player, position, temp=false):
	#Create a marker node and add it as a child
	if player == 1:
		var cross = cross_scence.instantiate()
		cross.position = position
		add_child(cross)
		if temp: temp_marker = cross
		
		
	else:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
		
func check_win():
	#add up the marker in each row, column and diagonal.
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
	
	#check if either players has all of the markers in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3: 
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3: 
			winner = -1
	return winner


func _on_game_over_menu_restart() -> void:
	new_game()
