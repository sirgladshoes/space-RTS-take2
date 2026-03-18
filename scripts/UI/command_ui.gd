extends Panel

var selected_units: Array[selectable] = []

func show_selected(selected_units_):
	selected_units = selected_units_

func _process(_delta: float) -> void:
	$RichTextLabel.text = ""
	for unit in selected_units:
		var data = unit.display_data
		var text = data.name + ": "
		
		if data.has("inventory"):
			var resources = unit.get_node(data.inventory).get_all_resources()
			for resource in resources:
				var res_name
				match resource:
					"0":
						res_name = "temp"
					"1":
						res_name = "temp2"
				text+=res_name+": "+str(resources[resource])+" "
		
		$RichTextLabel.text+=text+"\n"
