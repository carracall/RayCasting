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

