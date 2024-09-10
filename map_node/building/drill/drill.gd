extends Building

func _ready():
	Set_BodyArea2D($BodyArea2D)
	Set_LandingGears($LandingGearL,$LandingGearR)
	Set_stat(PREVIEW)
