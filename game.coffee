class Unitvector
	constructor : (@_x, @_y)->
	dot : (vec) -> 
		return @_x*vec._x + @_y*vec._y
	cross : (vec) -> 
		return @_x*vec._y - @_y*vec._x
	rot90 : () ->
		#rotate 90 degrees anticlockwise
		x = @x
		@x = -@y
		@y = x
		return @

class Vector extends Unitvector
	constructor : (x,y) ->
		@_unit = null
		@_length = null
		@_length2 = null
		super(x,y)
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
			@_unit = new Unitvector(@_x / @len() , @_y / @len())
		return @_unit
	set : (@_x,@_y) ->
		@_unit = null
		@_length = null
		@_length2 = null
		return @
	clone : () ->
		return new Vector(@_x,@_y)
	cloneAll : () ->
		a = new Vector(@_x,@_y)
		a._unit = @_unit
		a._length = @_length
		a._length2 = @_length2
		return a
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
	constructor: (@pos, @theta, @alpha, @phi) ->
	_adjust: () ->
		if @theta > Math.PI
			@theta -= 2*Math.PI
		else if @theta < -Math.PI
			@theta += 2*Math.PI
			
	drawWalls2: (ctx, walls, xres, pixWidth) ->
		@_adjust()
		step = @alpha * 2/xres
		rayAng = @theta - @alpha
		end = @theta + @alpha
		i = 0
		# implement a matrix rotation as alternative to using trig in iteration asp
		while rayAng < end
			p = @_getIntersection(rayAng, walls)
			if p != null
				n = closestWall.a.clone().sub(closestWall.b).hat().rot90()
				brightness = Math.abs(p.dot(n) / (p.len2()*p.len())) #=|p.n/(|p|^3)|
				ctx.fillStyle = closestWall.getColour(brightness)
				_h = Math.atan(Wall.h/2/p.len())/@phi
				ctx.fillRect(ctx.width-pixWidth*(i+1),ctx.height/2-_h,pixWidth,_h*2)
			# iteration step
			rayAng += step
			i+=1
	drawWalls: (ctx, walls, xres, pixWidth, height) ->
		@_adjust()
		step = @alpha * 2/xres
		rayAng = @theta + @alpha
		end = @theta - @alpha
		i = 0
		while rayAng > end
			[p, closestWall] = @_getIntersection(rayAng, walls)
			if p != null
				n = closestWall.a.clone().sub(closestWall.b).hat().rot90()
				brightness = Math.abs(p.dot(n) / (p.len2()*p.len())) #=|p.n/(|p|^3)|
				ctx.fillStyle =  closestWall.getColour(brightness)
				_h = height*Math.atan(Wall.h/2/p.len())/@phi
				ctx.fillRect(i,(height-_h)/2,1,_h)
				#ctx.fillRect(ctx.width-pixWidth*(i+1),ctx.height/2-_h,pixWidth,_h*2)
			# iteration step
			rayAng -= step
			i+=1
	_getIntersection: (rayAng, walls) ->
		r = new Unitvector(Math.cos(rayAng),Math.sin(rayAng))
		closestWall = null
		p = null # position vector of the closest point on a wall in the direction of r
		for wall in walls
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
	constructor: (@position, theta, alpha, phi) ->
		@camera = new Camera(@position, theta, alpha, phi)
	moveForward: (r)->
		@position.add(new Vector(Math.cos(@camera.theta),Math.sin(@camera.theta)).mult(r))
	turnLeft: (dtheta)->
		@camera.theta += dtheta
	





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

