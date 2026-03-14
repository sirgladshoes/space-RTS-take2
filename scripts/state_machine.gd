class_name state_machine extends Node

var current_state: String
var previous_state: String

var transitions: Callable

signal state_switched(current: String, previous: String)

func switch_state(new_state: String):
	previous_state = current_state
	current_state = new_state
	state_switched.emit(current_state, previous_state)

func set_transition_func(transitions_: Callable):
	transitions = transitions_

func _process(_delta: float) -> void:
	if !transitions:
		return
	var transition = transitions.call(current_state)
	if transition:
		switch_state(transition)
