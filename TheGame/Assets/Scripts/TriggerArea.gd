extends Spatial

export var scenename :String = "TheWorld"
export var set_barriers :bool
export var barrier_group_name :String
export var cutscene :bool
export var cutscene_number :int
export var god_text :bool
export var godtext_start_line :int
export var godtext_end_line :int
export var show_butterflies:bool
export var enemy_groups :Array
export var area_gruop_number :int
export var set_section :bool
export var enemy_start_attack :bool
export var enabled :bool

var triggername
var barrier_amount :int
var enemy_amount :int
var section_amount :int
var barriergroup = Array()
var enemygroup :Array
var sectiongroup :Array

signal player_is_in_area

#==============================================================================

func start_attack():
	enemygroup = get_tree().get_root().get_node(str(scenename)+"/Enemy/"+str(enemy_groups[area_gruop_number])).get_children()
	for enemy in enemygroup.size():
		enemygroup[enemy].start_attacking()

func set_amount():
	enemy_amount = enemygroup.size()
	print("Enemies in area group: "+str(enemy_amount))
	return enemy_amount

func set_section_amount():
	for g in enemy_groups.size():
		sectiongroup = get_tree().get_root().get_node(str(scenename)+"/Enemy/"+str(enemy_groups[g])).get_children()
		section_amount += sectiongroup.size()
		sectiongroup.clear()
	print("Enemies in level section: "+str(section_amount))
	return section_amount

func set_the_barriers():
	barriergroup.clear()
	if barrier_group_name == "":
		print("no barries set")
		return
	else:
		#barriergroup = get_tree().get_root().get_node(str(scenename)+"/Navigation/NavigationMesh/Barrier/"+str(barrier_group_name)).get_children()
		barriergroup = get_tree().get_root().get_node(str(scenename)+"/Barrier/"+str(barrier_group_name)).get_children()
		for barrier in barriergroup.size():
			barriergroup[barrier].get_node("AnimationPlayer").play("anim_enable")
		return barriergroup

#==============================================================================

func _on_Area_body_entered(body):
	if enabled:
		triggername = self.name
		if body.is_in_group("Player"):
			print("***********************************")
			print("Player entered a trigger area")
			if set_section:
				set_section_amount()
			if set_barriers:
				set_the_barriers()
			if enemy_start_attack:
				set_amount()
				start_attack()
			emit_signal("player_is_in_area",triggername)
			self.queue_free()
		
