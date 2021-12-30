
# Vector helpers added by this mod

## Helpers which return many positions for a shape, e.g. a line

### Line functions

These may be deprecated since raycasting has been added to minetest.
See e.g. `minetest.line_of_sight`.

* `vector.line([pos, dir[, range][, alt]])`: returns a table of vectors
    * `dir` is either a direction (when range is a number) or
      the start position (when range is the end position).
    * If alt is true, an old path calculation is used.
* `vector.twoline(x, y)`: can return e.g. `{{0,0}, {0,1}}`
    * This is a lower-level function than `vector.line`; it can be used for
      a 2D line.
* `vector.threeline(x, y, z)`: can return e.g. `{{0,0,0}, {0,1,0}}`
    * Similar to `vector.twoline`; this one is for the 3D case.
    * The parameters should be integers.
* `vector.rayIter(pos, dir)`: returns an iterator for a for loop
    * `pos` can have non-integer values
* `vector.fine_line([pos, dir[, range], scale])`: returns a table of vectors
    * Like `vector.line` but allows non-integer positions
    * It uses `vector.rayIter`.


### Flood Fill

* `vector.search_2d(go_test, x0, y0, allow_revisit, give_map)`: returns e.g.
  `{{0,0}, {0,1}}`
    * This function uses a Flood Fill algorithm, so it can be used to detect
      positions connected to each other in 2D.
    * `go_test(x, y)` should be a function which returns true iff the algorithm
      can "fill" at the position `(x, y)`.
    * `(x0, y0)` defines the start position.
    * If `allow_revisit` is false (the default), the function
      invokes `go_test` only once at every potential position.
    * If `give_map` is true (default is false), the function returns the
      marked table, whose indices are 2D vector indices, instead of a list of
      2D positions.
* `vector.search_3d(can_go, startpos, apply_move, moves)`: returns FIXME
    * FIXME


### Other Shapes

* `vector.explosion_table(r)`: returns e.g. `{{pos1}, {pos2, true}}`
    * The returned list of positions and boolean represents a sphere;
      if the boolean is true, the position is on the outer side of the sphere.
    * It might be used for explosion calculations; but `vector.explosion_perlin`
      should make more realistic holes.
* `vector.explosion_perlin(rmin, rmax[, nparams])`: returns e.g.
  `{{pos1}, {pos2, true}}`
    * This function is similar to `vector.explosion_table`; the positions
      do not represent a sphere but a more complex hole which is calculated
      with the help of perlin noise.
    * `rmin` and `rmax` represent the minimum and maximum radius,
      and `nparams` (which has a default value) are parameters for the perlin
      noise.
* `vector.circle(r)`: returns a table of vectors
    * The returned positions represent a circle of radius `r` along the x and z
      directions; the y coordinates are all zero.
* `vector.ring(r)`: returns a table of vectors
    * This function is similar to `vector.circle`; the positions are all
      touching each other (i.e. they are connected on whole surfaces and not
      only infinitely thin edges), so it is called `ring` instead of `circle`
    * `r` can be a non-integer number.
* `vector.throw_parabola(pos, vel, gravity, point_count, time)`
    * FIXME: should return positions along a parabola so that moving objects
      collisions can be calculated
* `vector.triangle(pos1, pos2, pos3)`: returns a table of positions, a number
  and a table with barycentric coordinates
    * This function calculates integer positions for a triangle defined by
      `pos1`, `pos2` and `pos3`, so it can be used to place polygons in
      minetest.
    * The returned number is the number of positions.
    * The barycentric coordinates are specified in a table with three elements;
      the first one corresponds to `pos1`, etc.


## Helpers for various vector calculations

* `vector.sort_positions(ps[, preferred_coords])`
    * Sorts a table of vectors `ps` along the coordinates specified in the
      table `preferred_coords` in-place.
    * If `preferred_coords` is omitted, it sorts along z, y and x in this order,
      where z has the highest priority.
* `vector.maxnorm(v)`: returns the Tschebyshew norm of `v`
* `vector.sumnorm(v)`: returns the Manhattan norm of `v`
* `vector.pnorm(v, p)`: returns the `p` norm of `v`
* `vector.inside(pos, minp, maxp)`: returns a boolean
    * Returns true iff `pos` is within the closed AABB defined by `minp`
      and `maxp`.
* `vector.minmax(pos1, pos2)`: returns two vectors
    * This does the same as `worldedit.sort_pos`.
    * The components of the second returned vector are all bigger or equal to
      those of the first one.
* `vector.move(pos1, pos2, length)`: returns a vector
    * Go from `pos1` `length` metres to `pos2` and then round to the nearest
      integer position.
    * Made for rubenwardy
* `vector.from_number(i)`: returns `{x=i, y=i, z=i}`
* `vector.chunkcorner(pos)`: returns a vector
    * Returns the mapblock position of the mapblock which contains
      the integer position `pos`
* `vector.point_distance_minmax(p1, p2)`: returns two numbers
    * Returns the minimum and maximum of the absolute component-wise distances
* `vector.collision(p1, p2)` FIXME
* `vector.update_minp_maxp(minp, maxp, pos)`
    * Can change `minp` and `maxp` so that `pos` is within the AABB defined by
      `minp` and `maxp`
* `vector.unpack(v)`: returns three numbers
    * Returns `v.z, v.y, v.x`
* `vector.get_max_coord(v)`: returns a string
    * Returns `"x"`, `"y"` or `"z"`, depending on which component has the
      biggest value
* `vector.get_max_coords(v)`: returns three strings
    * Similar to `vector.get_max_coord`; it returns the coordinates in the order
      of their component values
    * Example: `vector.get_max_coords{x=1, y=5, z=3}` returns `"y", "z", "x"`
* `vector.serialize(v)`: returns a string
    * In comparison to `minetest.serialize`, this function uses a more compact
      string for the serialization.


## Minetest-specific helper functions

* `vector.straightdelay([length, vel[, acc]])`: returns a number
    * Returns the time an object takes to move `length` if it has velocity `vel`
      and acceleration `acc`
* `vector.sun_dir([time])`: returns a vector or nil
    * Returns the vector which points to the sun
    * If `time` is omitted, it uses the current time.
    * This function does not yet support the moon;
      at night it simply returns `nil`.


## Helpers which I don't recommend to use now

* `vector.pos_to_string(pos)`: returns a string
    * It is similar to `minetest.pos_to_string`; it uses a different format:
      `"("..pos.x.."|"..pos.y.."|"..pos.z..")"`
* `vector.zero`
    * The zero vector `{x=0, y=0, z=0}`
* `vector.quickadd(pos, [z],[y],[x])`
    * Adds values to the vector components in-place


## Deprecated helpers

* `vector.plane`
    * should be removed soon; it should have done the same as vector.triangle

