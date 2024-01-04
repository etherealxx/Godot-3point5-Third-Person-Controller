tool
extends Spatial

export var android_mode: bool = false setget setAndroidMode

func setAndroidMode(value):
	android_mode = value
	var settings = ProjectSettings
	if Engine.editor_hint:
		if value: # true android
			settings.set_setting("display/window/size/width", 540)
			settings.set_setting("display/window/size/height", 960)
		else:
			settings.set_setting("display/window/size/width", 1024)
			settings.set_setting("display/window/size/height", 600)
		settings.save()
	
func _set(property, value):
	if property == "android_mode":
		android_mode = value
		setAndroidMode(value)
