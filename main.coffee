#= require <Vector.coffee>
#= require <Wall.coffee>
#= require <Player.coffee>

mainLoop = (ctx, player, walls, width, height) ->
	# drawBackground(ctx)
	ctx.clearRect(0, 0, width, height)
	player.camera.drawWalls(ctx, walls, width, 1, height)

setup = (canvasID) ->
	canvas = document.getElementById(canvasID)
	console.log canvas, canvasID
	ctx = canvas.getContext("2d")
	return [canvas,ctx]

walls = [new Wall(2,0,3,3),
         new Wall(3,3,3,-3),
         new Wall(3,-3,2,0)]

[c,ctx] = setup("mycanvas")
player = new Player(new Vector(0,0), 0, Math.PI/3,Math.PI/8)

interval=1000
# setInterval((()->mainLoop(ctx, player, walls)), interval)
mainLoop(ctx, player, walls, c.width, c.height)
console.log "end"
console.log "saved"



keyPressed = (e, c, ctx, walls, player) ->
	e = e || window.event
	console.log "key pressed ", e.keyCode
	switch e.keyCode
		when '38'
			# up arrow
			player.moveForward(0.2)
			console.log "moved forward"
			forward()

		when '40'
			# down arrow
			player.moveForward(-0.2)
			console.log "moved backward"
		when '37'
			# left arrow
			player.turnLeft(Math.PI/24)
		when '39'
			# right arrow
			player.turnLeft(-Math.PI/24)
	mainLoop(ctx, player, walls, c.width, c.height)
	console.log "redrawn"
backward = (e)->
	console.log "backward"
	player.moveForward(-0.2)
	mainLoop(ctx, player, walls, c.width, c.height)
forward = (e)->
	console.log "forward"
	player.moveForward(0.2)
	mainLoop(ctx, player, walls, c.width, c.height)
left = (e)->
	console.log "left"
	player.turnLeft(Math.PI/24)
	mainLoop(ctx, player, walls, c.width, c.height)
right = (e)->
	console.log "right"
	player.turnLeft(-Math.PI/24)
	mainLoop(ctx, player, walls, c.width, c.height)
window.addEventListener("keydown",((e)->keyPressed(e, c, ctx, walls, player)),true)
document.getElementById("back").addEventListener("click",backward)
document.getElementById("left").addEventListener("click",left)
document.getElementById("right").addEventListener("click",right)
document.getElementById("forward").addEventListener("click",forward)
