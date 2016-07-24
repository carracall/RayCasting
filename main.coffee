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
player.camera.drawWalls()

keyPressed = (e) ->
	e = e || window.event
	switch e.keyCode
		when 38
			# up arrow
			player.moveForward(0.05)
		when 40
			# down arrow
			player.moveForward(-0.05)
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
window.addEventListener("keydown",keyPressed,true)
