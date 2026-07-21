class_name GameEnums
extends Node

## Global Enums for Hardcore Factions mechanics

enum DamageType {
	PHYSICAL,
	MAGIC,
	TRUE_DAMAGE,
	ENVIRONMENTAL,
	POISON,
	FIRE,
	FALL
}

enum FactionType {
	WILDERNESS,
	SAFEZONE,
	WARZONE,
	FACTION_CLAIM
}

enum AbilitySlot {
	SLOT_1,
	SLOT_2,
	SLOT_3,
	PASSIVE
}

enum PlayerState {
	IDLE,
	WALKING,
	RUNNING,
	CASTING,
	STUNNED,
	DEAD
}
