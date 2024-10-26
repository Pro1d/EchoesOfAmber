extends AudioStreamPlayer2D
class_name AreaAmbienceNode

# The ID of the area to which this player corresponds
@export var area_id : int = 0

# True if this audio corresponds to a desolated area.
@export var is_desolated: bool = false

# Nominal volume of the track in DB 
# (will override the default during crossfaces)
@export var nominal_volume_db: float = 0
