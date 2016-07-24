// Generated by CoffeeScript 1.10.0
(function() {
  var Camera, Player, Vector, Wall, keyPressed, player, setup, walls;

  Vector = (function() {
    function Vector(_x, _y) {
      this._x = _x;
      this._y = _y;
      this._unit = null;
      this._length = null;
      this._length2 = null;
    }

    Vector.prototype.clone = function() {
      return new Vector(this._x, this._y);
    };

    Vector.prototype.cloneAll = function() {
      var a;
      a = new Vector(this._x, this._y);
      a._unit = this._unit;
      a._length = this._length;
      a._length2 = this._length2;
      return a;
    };

    Vector.prototype.dot = function(v) {
      return this._x * v._x + this._y * v._y;
    };

    Vector.prototype.cross = function(v) {
      return this._x * v._y - this._y * v._x;
    };

    Vector.prototype.rot90 = function() {
      var x;
      x = this._x;
      this._x = -this._y;
      this._y = x;
      return this;
    };

    Vector.prototype.len2 = function() {
      if (this._length2 === null) {
        this._length2 = Math.pow(this._x, 2) + Math.pow(this._y, 2);
      }
      return this._length2;
    };

    Vector.prototype.len = function() {
      if (this._length === null) {
        this._length = Math.sqrt(this.len2());
      }
      return this._length;
    };

    Vector.prototype.hat = function() {
      if (!this._unit) {
        this._unit = new Vector(this._x / this.len(), this._y / this.len());
      }
      return this._unit;
    };

    Vector.prototype.set = function(_x, _y) {
      this._x = _x;
      this._y = _y;
      this._unit = null;
      this._length = null;
      this._length2 = null;
      return this;
    };

    Vector.prototype.add = function(vec) {
      this.set(this._x + vec._x, this._y + vec._y);
      return this;
    };

    Vector.prototype.sub = function(vec) {
      this.set(this._x - vec._x, this._y - vec._y);
      return this;
    };

    Vector.prototype.mult = function(lambda) {
      this._x *= lambda;
      this._y *= lambda;
      this._length *= lambda;
      this._length2 *= Math.pow(lambda, 2);
      return this;
    };

    return Vector;

  })();

  Wall = (function() {
    Wall.h = 1;

    function Wall(x1, y1, x2, y2) {
      this.a = new Vector(x1, y1);
      this.b = new Vector(x2, y2);
    }

    Wall.prototype.getColour = function(b) {
      var c, d, h;
      d = Math.floor(255 * (b / (b + 0.2)));
      h = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"];
      c = h[Math.floor(d / 16)] + h[d % 16];
      return "rgb(" + c + "," + c + "," + c + ")";
    };

    return Wall;

  })();

  Camera = (function() {
    function Camera(pos, theta1, ctx1, walls1, width1, height1, pixWidth1, scrHeight, scrWidth, scrDist) {
      this.pos = pos;
      this.theta = theta1;
      this.ctx = ctx1;
      this.walls = walls1;
      this.width = width1;
      this.height = height1;
      this.pixWidth = pixWidth1;
      this.scrHeight = scrHeight;
      this.scrWidth = scrWidth;
      this.scrDist = scrDist;
      this.xres = Math.floor(this.width / this.pixWidth);
      this.pxlWidth = this.scrWidth / this.xres;
      this.xres = 640;
      this.width = 640;
      this.height = 480;
      this.e_r = new Vector(Math.cos(this.theta), Math.sin(this.theta));
    }

    Camera.prototype._adjust = function() {
      if (this.theta > Math.PI) {
        return this.theta -= 2 * Math.PI;
      } else if (this.theta < -Math.PI) {
        return this.theta += 2 * Math.PI;
      }
    };

    Camera.prototype.drawWalls = function() {
      var _h, brightness, closestWall, e_theta, i, j, n, p, pxlLat, r, ref, ref1, results;
      this._adjust();
      this.ctx.clearRect(0, 0, this.width, this.height);
      this.pxlWidth = this.scrWidth / this.xres;
      e_theta = this.e_r.clone().rot90();
      pxlLat = e_theta.clone().mult(-this.pxlWidth);
      r = this.e_r.clone().mult(this.scrDist).add(e_theta.clone().mult(this.scrWidth / 2));
      results = [];
      for (i = j = 1, ref = this.xres; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
        console.log("r", r, " i: ", i);
        ref1 = this._getIntersection(r.hat()), p = ref1[0], closestWall = ref1[1];
        if (p !== null) {
          n = closestWall.a.clone().sub(closestWall.b).hat().rot90();
          brightness = Math.abs(p.dot(n) / (p.len2() * p.len()));
          this.ctx.fillStyle = "#FF0000";
          _h = Wall.h * r.len() / p.len() * this.height / this.scrHeight;
          this.ctx.fillRect(i - 1, (this.height - _h) / 2, this.pixWidth, _h);
        }
        results.push(r.add(pxlLat));
      }
      return results;
    };

    Camera.prototype._getIntersection = function(r) {
      var __a, __b, _a, _b, _p, closestWall, j, len, p, ref, t, wall;
      closestWall = null;
      p = null;
      ref = this.walls;
      for (j = 0, len = ref.length; j < len; j++) {
        wall = ref[j];
        _a = wall.a.clone().sub(this.pos);
        _b = wall.b.clone().sub(this.pos);
        if (_a.dot(r) > _a.dot(_b.hat()) && _b.dot(r) > _b.dot(_a.hat())) {
          __a = _a.clone();
          __b = _b.clone();
          t = Math.abs((_b.cross(r)) / (_b.sub(_a).cross(r)));
          _p = __a.mult(t).add(__b.mult(1 - t));
          if (p !== null) {
            if (p.len2() > _p.len2()) {
              closestWall = wall;
              p = _p;
            }
          } else {
            p = _p;
            closestWall = wall;
          }
        }
      }
      return [p, closestWall];
    };

    return Camera;

  })();

  Player = (function() {
    function Player(position, theta, ctx, walls, width, height, pixWidth, ScrHeight, ScrWidth, ScrDist) {
      this.position = position;
      this.camera = new Camera(this.position, theta, ctx, walls, width, height, pixWidth, ScrHeight, ScrWidth, ScrDist);
    }

    Player.prototype.moveForward = function(r) {
      this.position.add(this.camera.e_r.clone().mult(r));
      return this.camera.drawWalls();
    };

    Player.prototype.turnLeft = function(dtheta) {
      this.camera.theta += dtheta;
      this.camera.e_r.set(Math.cos(this.camera.theta), Math.sin(this.camera.theta));
      return this.camera.drawWalls();
    };

    Player.prototype.moveLeft = function(r) {
      this.position.add(this.camera.e_r.clone().mult(r).rot90());
      return this.camera.drawWalls();
    };

    return Player;

  })();

  setup = function(canvasID) {
    var c, ctx, player;
    c = document.getElementById(canvasID);
    console.log(c, canvasID);
    ctx = c.getContext("2d");
    player = new Player(new Vector(0, 0), 0, ctx, walls, c.width, c.height, 1, 1, c.width / c.height, 0.5);
    return player;
  };

  walls = [new Wall(2, 0, 3, 3), new Wall(3, 3, 3, -3), new Wall(3, -3, 2, 0)];

  player = setup("mycanvas");

  player.camera.drawWalls();

  keyPressed = function(e) {
    e = e || window.event;
    switch (e.keyCode) {
      case 38:
        return player.moveForward(0.05);
      case 40:
        return player.moveForward(-0.05);
      case 37:
        return player.turnLeft(Math.PI / 24);
      case 39:
        return player.turnLeft(-Math.PI / 24);
      case 81:
        return player.moveLeft(0.05);
      case 68:
        return player.moveLeft(-0.05);
    }
  };

  window.addEventListener("keydown", keyPressed, true);

}).call(this);
