class Vector
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
	dot : (v) ->
		return @_x*v._x + @_y*v._y
	cross : (v) ->
		return @_x*v._y - @_y*v._x
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
		@_x*=lambda
		@_y*=lambda
		@_length*=lambda
		@_length2*=lambda**2
		return @

		# change asp to calc new length
