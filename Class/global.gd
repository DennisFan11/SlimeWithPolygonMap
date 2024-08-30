extends Node
var MainGame:Main_game
var MapNode:Map_node
var ParticleNode:Particle_node
var ToolNode:Node2D




enum {COPPER, IORN, COAL, ROCK, LUMIUM, BIOMASS}
var item_count = BIOMASS+1
const colors = {
	IORN: Color("7f7f7f"),
	COPPER: Color("ae5e3e"),
	LUMIUM: Color("0c8599"),
	ROCK: Color("846358"),
	COAL: Color("191919")
}
