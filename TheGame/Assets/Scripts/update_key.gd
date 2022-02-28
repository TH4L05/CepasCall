extends Label

func setCurrentKeyAsText(event):
	text = InputMap.get_action_list(event)[0].as_text()
