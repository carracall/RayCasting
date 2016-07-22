#= require <Vector.coffee>
#= require <Wall.coffee>
#= require <Player.coffee>


setup = (canvasID) ->
	c = document.getElementById(canvasID)
	console.log c, canvasID
	ctx = c.getContext("2d")
	player = new Player(new Vector(0,0), 0, ctx, walls, c.width, c.height, 1, 1, c.width/c.height, 0.5)
	return player

walls = [new Wall(2,0,3,3),
         new Wall(3,3,3,-3),
         new Wall(3,-3,2,0)]

player = setup("mycanvas")

interval=1000
# setInterval((()->mainLoop(ctx, player, walls)), interval)
player.camera.drawWalls()
console.log "end"
console.log "saved"


backward = (e)->
	console.log "backward"
	player.moveForward(-0.2)
forward = (e)->
	console.log "forward"
	player.moveForward(0.2)
left = (e)->
	console.log "left"
	player.turnLeft(Math.PI/24)
right = (e)->
	console.log "right"
	player.turnLeft(-Math.PI/24)

keyPressed = (e) ->
	e = e || window.event
	console.log "key pressed ", e.keyCode
	switch e.keyCode
		when 38
			# up arrow
			player.moveForward(0.05)
			console.log "moved forward"
			forward()

		when 40
			# down arrow
			player.moveForward(-0.05)
			console.log "moved backward"
		when 37
			# left arrow
			player.turnLeft(Math.PI/24)
		when 39
			# right arrow
			player.turnLeft(-Math.PI/24)
		when 81
			# q
			player.moveLeft(0.05)
		when 68
			# d
			player.moveLeft(-0.05)
	console.log "redrawn"
document.getElementById("back").addEventListener("click",backward)
document.getElementById("left").addEventListener("click",left)
document.getElementById("right").addEventListener("click",right)
document.getElementById("forward").addEventListener("click",forward)
window.addEventListener("keydown",keyPressed,true)
