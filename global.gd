extends Node

var game: Game = null

var config := ConfigFile.new()
var music := AudioServer.get_bus_index("Music")
var ui := AudioServer.get_bus_index("UI")
var environment := AudioServer.get_bus_index("Environment")
