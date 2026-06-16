#import "@preview/touying:0.7.4": *
#import "@preview/cetz:0.5.2" as cetz

// STYLE FUNCTIONS

// stroke associated to status
#let get-stroke(
  status, 
  colors: (
    initial: 1.5pt + black, 
    temp: 1pt + blue, 
    result: 1.5pt + red, 
    help: 1pt + gray,
  ),
) = {
  assert(
    status in ("initial", "temp", "help", "result"), 
    message: "status must be \"initial\", \"temp\", \"help\" or \"result\""
  )
  return colors.at(status)
}


// makes the color change for following slides
#let update-color(
  status, 
  last: true
) = {
  let status-color = get-stroke(status)
  if status == "initial" {
    cetz.draw.set-style(stroke: status-color) 
  }
  else if status == "temp" {
    cetz.draw.set-style(stroke: status-color.thickness + status-color.paint.lighten(70%))
  }
  else if status == "help" {
    cetz.draw.set-style(stroke: status-color.thickness + status-color.paint)
  }
  else {
    cetz.draw.set-style(stroke: get-stroke("initial"))
  }

  if status != "initial" {
    (only(auto, cetz.draw.set-style(stroke: get-stroke(status))),)
  }
}

// selects cetz layer from status
#let on-layer(
  status, 
  body, 
  is-point: false
) = {
  if is-point {
    return cetz.draw.on-layer(2, body)
  } else {
    if status == "temp" {
    return cetz.draw.on-layer(-1, body)
  } else if status in ("initial", "result") {
    return cetz.draw.on-layer(1, body)
  } else {
    return cetz.draw.on-layer(0, body)
  }
  }
}

// CUSTOM CETZ FIGURES

// point marked by a small circle
#let point(
  coords, 
  radius: 4pt, 
  fill: white, 
  status: "temp", 
  ..args
) = {
  update-color(status)
  on-layer(status, cetz.draw.circle(coords, radius: radius, fill: fill, ..args), is-point: true)
}

#let inner-point(
  coords, 
  radius: 4pt, 
  fill: white, 
  status: "temp", 
  ..args
) = {
  on-layer(status, cetz.draw.circle(coords, radius: radius, fill: fill, ..args), is-point: true)
}

// segment with start and end points
#let segment(
  start, 
  end, 
  status: "temp", 
  last: true, 
  ..args
) = {
  update-color(status)
  cetz.draw.group(..args, {
    on-layer(status, cetz.draw.line(start, end))
    inner-point(start, name: "start", status: status)
    inner-point(end, name: "end", status: status)
  })
}

// half-line with start point
#let segline(
  start, 
  end, 
  status: "temp", 
  ..args
) = {
  update-color(status)
  cetz.draw.group(..args, {
    on-layer(status, cetz.draw.line(start, end))
    inner-point(start, name: "start", status: status)
    cetz.draw.content(end, "", name: "end")
  })
}

// circle 
#let circle(
  status: "temp", 
  ..args
) = {
  update-color(status)
  on-layer(status, cetz.draw.circle(..args))
}

// line
#let line(
  start, 
  end, 
  extend: (1,1), 
  status: "temp", 
  ..args
) = {
  let extend = if type(extend) == array {extend} else {(extend, extend)}
  assert(
    extend.at(0) >= 1 and extend.at(1) >= 1, 
    message: "extend should be an pair of integers >= 1"
  )
  update-color(status)
  cetz.draw.get-ctx(ctx => {
    let (ctx, a, b) = cetz.coordinate.resolve(ctx, start, end)
    let v = cetz.vector.scale(cetz.vector.sub(b,a), extend.at(1))
    let w = cetz.vector.scale(cetz.vector.sub(a,b), extend.at(0) - 1)
    on-layer(status, cetz.draw.line(cetz.vector.add(a,w), cetz.vector.add(a,v), ..args))
  })
}

// tick
#let tick(
  start, 
  end, 
  length: 6pt, 
  number: 1, 
  spacing: 4pt, 
  status: "help", 
  ..args
) = {
  let mid-pt = (start, 50%, end)
  for i in range(number) {
    let tmp-pt = (mid-pt, spacing * (i - 1 + (1 - number) / 2), start)
    line((tmp-pt, length, 90deg, start), (tmp-pt, length, -90deg, start), status: status, ..args)
  }
}

// angle tick
#let angle-tick(
  origin, 
  a, 
  b, 
  length: 4pt, 
  status: "help", 
  ..args
) = {
  update-color(status)
  on-layer(status, cetz.draw.group(..args, {
    cetz.draw.hide(cetz.angle.angle(origin, a, b, name: "_eucl_tmp_angle"))
    cetz.draw.line(("_eucl_tmp_angle.center", length, origin), ("_eucl_tmp_angle.center", -4.5pt-length, origin))
  }))
}

// right angle
#let right-angle(
  origin, 
  a, 
  b, 
  length: .5, 
  offset: .2, 
  status: "help", 
  ..args
) = {
  update-color(status)
  on-layer(status, cetz.draw.get-ctx(ctx => {
    let (ctx, origin, a, b) = cetz.coordinate.resolve(ctx, origin, a, b)
    let v = cetz.vector.norm(cetz.vector.sub(a, origin))
    let w = cetz.vector.norm(cetz.vector.sub(b, origin))
    let o = cetz.vector.add(origin, cetz.vector.add(cetz.vector.scale(v, offset), cetz.vector.scale(w, offset)))
    cetz.draw.line(cetz.vector.add(o, cetz.vector.scale(w, length)), o, cetz.vector.add(o, cetz.vector.scale(v, length)), ..args)
  }))
}


// allows compatibility between Touying and Cetz
#let eucslide-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true, ))

// wrap slide function inside canvas
#let eucslide(body) = slide[
  #eucslide-canvas({
    body
  })
]
