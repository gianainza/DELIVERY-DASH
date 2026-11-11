extends RefCounted
## Shared result data so the end screen knows how the run went.
## Use it with: const GameResult = preload("res://scripts/game_result.gd")
static var won := false
static var delivered := 0
static var stars := 0
