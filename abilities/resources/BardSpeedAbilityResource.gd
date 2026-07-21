class_name BardSpeedAbilityResource
extends AbilityResource

## HCF Bard Active Song: Speed Burst

func _init() -> void:
	id = "bard_speed"
	name = "Bard Song: Speed II"
	description = "Grants Speed II burst to nearby team members."
	cooldown = 4.0
	stamina_cost = 10.0

func execute(caster: Node2D) -> bool:
	if not caster or not caster.has_node("BardAuraComponent"):
		return false
	
	var bard_aura = caster.get_node("BardAuraComponent") as BardAuraComponent
	if bard_aura:
		bard_aura.current_aura = "Speed II"
		bard_aura.pulse_aura()
		
		var bus = caster.get_node_or_null("/root/EventBus")
		if bus:
			bus.camera_shake_requested.emit(2.0, 0.1)
		return true
	return false
