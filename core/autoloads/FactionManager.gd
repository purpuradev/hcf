extends Node

## Global manager for HCF Faction registrations, DTR tracking, and member relations

var factions: Dictionary = {} # String -> FactionResource
var player_factions: Dictionary = {} # String (player_id/name) -> String (faction_id)

func _ready() -> void:
	# Register default system factions
	_create_system_faction("safezone", "Safezone", GameEnums.FactionType.SAFEZONE, Color.GREEN)
	_create_system_faction("warzone", "Warzone", GameEnums.FactionType.WARZONE, Color.RED)
	_create_system_faction("wilderness", "Wilderness", GameEnums.FactionType.WILDERNESS, Color.DARK_GRAY)

func _process(delta: float) -> void:
	for faction in factions.values():
		if faction is FactionResource:
			faction.process_dtr_regen(delta)

func _create_system_faction(id: String, faction_name: String, _type: GameEnums.FactionType, color: Color) -> void:
	var fac = FactionResource.new()
	fac.faction_id = id
	fac.faction_name = faction_name
	fac.max_dtr = 999.0
	fac.dtr = 999.0
	fac.color = color
	factions[id] = fac

func register_faction(faction: FactionResource) -> void:
	factions[faction.faction_id] = faction

func get_faction(faction_id: String) -> FactionResource:
	return factions.get(faction_id, null)

func is_friendly_fire(player_a_id: String, player_b_id: String) -> bool:
	if player_a_id.is_empty() or player_b_id.is_empty():
		return false
	var fac_a = player_factions.get(player_a_id, "")
	var fac_b = player_factions.get(player_b_id, "")
	return not fac_a.is_empty() and fac_a == fac_b
