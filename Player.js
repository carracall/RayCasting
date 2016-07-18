// Generated by CoffeeScript 1.10.0
(function() {
  var Camera, Player;

  Camera = (function() {
    function Camera(pos, theta, alpha1, phi1) {
      this.pos = pos;
      this.theta = theta;
      this.alpha = alpha1;
      this.phi = phi1;
    }

    Camera.prototype._adjust = function() {
      if (this.theta > Math.PI) {
        return this.theta -= Math.PI;
      } else if (this.theta < -Math.PI) {
        return this.theta += Math.PI;
      }
    };

    Camera.prototype.drawWalls2 = function(ctx, walls, xres, pixWidth) {
      var _h, brightness, end, i, n, p, rayAng, results, step;
      this._adjust();
      step = this.alpha * 2 / xres;
      rayAng = this.theta - this.alpha;
      end = this.theta + this.alpha;
      i = 0;
      results = [];
      while (rayAng < end) {
        p = this._getIntersection(rayAng, walls);
        if (p !== null) {
          n = closestWall.a.clone().sub(closestWall.b).hat().rot90();
          brightness = Math.abs(p.dot(n) / (p.len2() * p.len()));
          ctx.fillStyle = closestWall.getColour(brightness);
          _h = Math.atan(Wall.h / 2 / p.len()) / this.phi;
          ctx.fillRect(ctx.width - pixWidth * (i + 1), ctx.height / 2 - _h, pixWidth, _h * 2);
        }
        rayAng += step;
        results.push(i += 1);
      }
      return results;
    };

    Camera.prototype.drawWalls = function(ctx, walls, xres, pixWidth, height) {
      var _h, brightness, closestWall, end, i, n, p, rayAng, ref, results, step;
      console.log("height: ", height);
      console.log("width: ", xres);
      this._adjust();
      step = this.alpha * 2 / xres;
      rayAng = this.theta + this.alpha;
      end = this.theta - this.alpha;
      i = 0;
      results = [];
      while (rayAng > end) {
        ref = this._getIntersection(rayAng, walls), p = ref[0], closestWall = ref[1];
        if (p !== null) {
          console.log("not null");
          n = closestWall.a.clone().sub(closestWall.b).hat().rot90();
          console.log(p, n);
          brightness = Math.abs(p.dot(n) / (p.len2() * p.len()));
          ctx.fillStyle = "#FF0000";
          _h = height * Math.atan(Wall.h / 2 / p.len()) / this.phi;
          ctx.fillRect(i, 0, 1, _h);
          console.log("drawn");
        }
        rayAng -= step;
        results.push(i += 1);
      }
      return results;
    };

    Camera.prototype._getIntersection = function(rayAng, walls) {
      var __a, __b, _a, _b, _p, closestWall, j, len, p, r, t, wall;
      r = new Unitvector(Math.cos(rayAng), Math.sin(rayAng));
      closestWall = null;
      p = null;
      for (j = 0, len = walls.length; j < len; j++) {
        wall = walls[j];
        _a = wall.a.clone().sub(this.pos);
        _b = wall.b.clone().sub(this.pos);
        if (_a.dot(r) > _a.dot(_b.hat()) && _b.dot(r) > _b.dot(_a.hat())) {
          __a = _a.clone();
          __b = _b.clone();
          t = Math.abs((_b.cross(r)) / (_b.sub(_a).cross(r)));
          console.log("t = ", t);
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
    function Player(position, viewDirection, alpha, phi) {
      this.position = position;
      this.camera = new Camera(this.position, viewDirection, alpha, phi);
    }

    return Player;

  })();

}).call(this);
