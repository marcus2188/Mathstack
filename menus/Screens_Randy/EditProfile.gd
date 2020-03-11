extends Control

var scene_path_to_load

onready var http : HTTPRequest = $HTTPRequest
onready var username : LineEdit = $TextureRect/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
onready var nickname : LineEdit = $TextureRect/MarginContainer/MarginContainer/VBoxContainer/MenuOptions/HBoxContainer2/LineEdit
onready var class1 : OptionButton = $TextureRect/MarginContainer/MarginContainer/VBoxContainer/MenuOptions/HBoxContainer3/OptionButton 
var new_profile := false
var information_sent := false



var profile := {
	"nickname":{}
	#"class1":{}
} setget set_profile

func _ready():
	for button in $TextureRect/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer2.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
	Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	username.text = Firebase.user_info.email
	

func _on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()


func _on_FadeIn_fade_finished():
	get_tree().change_scene(scene_path_to_load)




func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		#error
		404:
			new_profile = true
			return
		#success
		200:
			if information_sent:
				information_sent = false
			#invvoke set method of the profile
			#loading the response into the fields	
			self.profile = result_body.fields

###
func _on_Button3_pressed():
	
	profile.nickname = { "stringValue": nickname.text }
	#profile.class1 = {"stringValue": class1.get_item_text()}
	match new_profile:
		#calling save method, basically insertion
		true:
			Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, profile, http)
		false:
		#calling update method
			Firebase.update_document("users/%s" % Firebase.user_info.id, profile, http)
	information_sent = true
	
func set_profile(value: Dictionary) -> void:
	profile = value
	nickname.text=profile.nickname.stringValue
	#class1.value=profile.class1.get_item_text
