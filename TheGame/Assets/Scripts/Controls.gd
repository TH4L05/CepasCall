extends Control

var currentButton
var waitingForInput

func _ready():
	start()

func start():
	for child in $GridContainer.get_children():
		if child.get("event") != null:
			setCurrentKeyAsText(child)

func setCurrentKeyAsText(node):
	node.text = InputMap.get_action_list(node.event)[0].as_text()

func _input(event):
	if event is InputEventKey:
		#var input = event.scancode
		if waitingForInput:
			var event_as_text = event.as_text()
			for input_button in [$GridContainer/KeyButton, $GridContainer/KeyButton2, $GridContainer/KeyButton3, $GridContainer/KeyButton4, $GridContainer/KeyButton5, $GridContainer/KeyButton6 ]:
				if input_button.text == event_as_text:
					return
			currentButton.text = event_as_text
			waitingForInput = false
			InputMap.action_erase_events(currentButton.event)
			InputMap.action_add_event(currentButton.event, event)

func _on_KeyButton_modified_Pressed(node):
	if waitingForInput or node != currentButton:
		if currentButton != null:
			setCurrentKeyAsText(currentButton)
			waitingForInput = false
	waitingForInput = !waitingForInput
	if waitingForInput:
		currentButton = node
		currentButton.text = ""


