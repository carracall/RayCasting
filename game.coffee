class Unitvector
	constructor : (@_x, @_y)->

class Vector extends Unitvector
	constructor : (@_x,@_y) ->
		@_unit = null
		@_length = null
		@_length2 = null
	clone : () ->
		return new Vector(@_x,@_y)
	cloneAll : () ->
		a = new Vector(@_x,@_y)
		a._unit = @_unit
		a._length = @_length
		a._length2 = @_length2
		return a
	dot : (vec) -> 
		return @_x*vec._x + @_y*vec._y
	cross : (vec) -> 
		return @_x*vec._y - @_y*vec._x
	rot90 : () ->
		#rotate 90 degrees anticlockwise
		x = @_x
		@_x = -@_y
		@_y = x
		return @
	len2 : () ->
		if @_length2 == null
			@_length2 = @_x**2 + @_y**2
		return @_length2
	len : () ->
		if @_length == null
			@_length = Math.sqrt @len2()
		return @_length
	hat : () ->
		# unsafe, need to check if length is not 0 first
		if not @_unit
			@_unit = new Vector(@_x / @len() , @_y / @len())
		return @_unit
	set : (@_x,@_y) ->
		@_unit = null
		@_length = null
		@_length2 = null
		return @
	add: (vec)->
		@set(@_x+vec._x, @_y+vec._y)
		return @
	sub: (vec)->
		@set(@_x-vec._x, @_y-vec._y)
		return @
	mult: (lambda)->
		@set(@_x*lambda, @_y*lambda)
		return @

		# change asp to calc new length

#a = new Vector(1,1)
#console.log a, a.hat(), a.len(), a.dot(a.hat())

class Wall
	@h : 1
	constructor: (x1, y1, x2, y2) ->
		@a = new Vector(x1, y1)
		@b = new Vector(x2, y2)
	getColour: (b)->
		d = Math.floor(255*(b/(b+0.2)))
		h = ["1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]
		c = h[d//16] + h[d%16]
		return "rgb("+c+","+c+","+c+")"


class Camera
	constructor: (@pos, @theta, @ctx, @walls, @width, @height, @pixWidth, @scrHeight, @scrWidth, @scrDist) ->
		@xres = @width//@pixWidth
		@pxlWidth = @scrWidth/@xres
		# @e_theta = new Vector(Math.cos(@theta),Math.sin(@theta))
		@xres = 640
		@width = 640
		@height = 480
		@e_r = new Vector(Math.cos(@theta), Math.sin(@theta))

	_adjust: () ->
		if @theta > Math.PI
			@theta -= 2*Math.PI
		else if @theta < -Math.PI
			@theta += 2*Math.PI
			
	drawWalls: () ->
		@_adjust()
		@ctx.clearRect(0, 0, @width, @height)
		@pxlWidth = @scrWidth/@xres
		console.log "@e_r", @e_r
		e_theta = @e_r.clone().rot90()
		console.log "e_theta", e_theta
		pxlLat = e_theta.clone().mult(-@pxlWidth)
		r = @e_r.clone().mult(@scrDist).add(e_theta.clone().mult(@scrWidth/2))
		console.log "@scrDist", @scrDist
		for i in [1..@xres]
			console.log "r", r, " i: ", i
			[p, closestWall] = @_getIntersection(r.hat())
			if p != null
				n = closestWall.a.clone().sub(closestWall.b).hat().rot90()
				brightness = Math.abs(p.dot(n) / (p.len2()*p.len())) #=|p.n/(|p|^3)|
				@ctx.fillStyle = "#FF0000" #closestWall.getColour(brightness)
				_h = Wall.h*r.len()/p.len()*@height/@scrHeight
				@ctx.fillRect(i-1,(@height-_h)/2,@pixWidth,_h)
				console.log "drawn"
				#ctx.fillRect(ctx.width-pixWidth*(i+1),ctx.height/2-_h,pixWidth,_h*2)
			# iteration step
			r.add(pxlLat)
	_getIntersection: (r) ->
		closestWall = null
		p = null # position vector of the closest point on a wall in the direction of r
		for wall in @walls
			# positions of ends of the walls relative to player (2 copies)
			_a = wall.a.clone().sub(@pos)
			_b = wall.b.clone().sub(@pos)
			if _a.dot(r) > _a.dot(_b.hat()) and _b.dot(r) > _b.dot(_a.hat())
				# need second copy of _a and _b because they will be muted
				__a = _a.clone()
				__b = _b.clone()
				t = Math.abs((_b.cross(r)) / (_b.sub(_a).cross(r)))
				_p = __a.mult(t).add(__b.mult(1-t)) # _b,_a are mutable and have changed value
				if p != null
					if p.len2() > _p.len2()
						closestWall = wall
						p = _p
				else
					p = _p
					closestWall = wall
		return [p,closestWall]


class Player
	constructor: (@position, theta, ctx, walls, width, height, pixWidth, ScrHeight, ScrWidth, ScrDist) ->
		@camera = new Camera(@position, theta, ctx, walls, width, height, pixWidth, ScrHeight, ScrWidth, ScrDist)
	moveForward: (r)->
		@position.add(@camera.e_r.clone().mult(r))
		@camera.drawWalls()
	turnLeft: (dtheta)->
		@camera.theta += dtheta
		@camera.e_r.set(Math.cos(@camera.theta), Math.sin(@camera.theta))
		@camera.drawWalls()
	moveLeft: (r) ->
		@position.add(@camera.e_r.clone().mult(r).rot90())
		@camera.drawWalls()







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

