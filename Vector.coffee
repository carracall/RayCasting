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
