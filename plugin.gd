tool
extends EditorPlugin

var exception=["TileMap"]

var plugin
var window

var pressed = false

var ur
var init_pos
var term_pos
var current_object

func _ready():
	ur=get_undo_redo()

func _enter_tree():
	plugin = preload("plugin.tscn").instance()
	plugin.get_node("enable").set_button_icon(preload("icon.png"))
	plugin.get_node("setting").connect("pressed",self,"setting")
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU,plugin)
	window=plugin.get_node("window")
	
	
func _exit_tree():
	plugin.free()

func edit(object):
	current_object = object

func handles(object):
	return object.has_method("set_pos") and !exception.has(object.get_type())

func forward_input_event(event):
	var capture=false
	if current_object and plugin.get_node("enable").is_pressed():
		if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_RIGHT:
			pressed = event.is_pressed()
			if pressed:
				ur.create_action("plugin: following cursor")
				ur.add_undo_method(self,"reset",current_object.get_pos())
				capture=true
			else:
				ur.add_do_method(self,"reset",current_object.get_pos())
				ur.commit_action()
		if pressed and (event.type == InputEvent.MOUSE_BUTTON or event.type == InputEvent.MOUSE_MOTION):
			current_object.set_global_pos(current_object.get_viewport().get_mouse_pos())
			if window.get_node("snap").is_pressed():
				var offset_x=0
				var offset_y=0
				var snap_x=convert(window.get_node("snap_x").get_text(),TYPE_INT)
				var snap_y=convert(window.get_node("snap_y").get_text(),TYPE_INT)
				if window.get_node("offset").is_pressed():
					offset_x=convert(window.get_node("offset_x").get_text(),TYPE_INT)
					offset_y=convert(window.get_node("offset_y").get_text(),TYPE_INT)
				var p=Vector2()
				if snap_x>0:
					p=current_object.get_global_pos()
					var x=snap_x*round((p.x-offset_x)*(1.0/snap_x))+offset_x
					current_object.set_global_pos(Vector2(x,p.y))
				if snap_y>0:
					p=current_object.get_global_pos()
					var y=snap_y*round((p.y-offset_y)*(1.0/snap_y))+offset_y
					current_object.set_global_pos(Vector2(p.x,y))
	return capture

func reset(pos):
	current_object.set_pos(pos)

func setting():
	window.popup_centered()
	