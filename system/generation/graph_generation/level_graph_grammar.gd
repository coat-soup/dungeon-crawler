extends Resource
class_name LevelGraphGrammar

@export var weight : float = 1.0
@export var nodes : Array[String]
# nodes array example format:
# start:1
# branch:0,2,4
# room:1
# secret:3
# end:1

#                  
#                    v--> room <-- secret
# makes: start <--> branch <--> end


# -1 is input, -2 is output
