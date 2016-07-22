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

