#import "@preview/cetz:0.5.2" as cetz
#import "../lib.typ": *
#import euclidea-theme: *

#show: euclidea-theme.with(handout: false)

= Example of euclidian construction

== Construction of 60° angle

#eucslide({
  import cetz.draw: *

  eucl-segline((0,0),(8,0), name: "s1", status: "initial")

  (pause,)
  
  eucl-circle("s1.start", radius: 4.5, name: "c1")
  intersections("inter1", "s1", "c1")

  (pause,)
  
  eucl-point("inter1.0")
  eucl-circle("inter1.0", radius: 4.5, name: "c2")
  intersections("inter2", "c1", "c2")

  eucl-point("inter2.1", status: "result")

  (pause,)

  eucl-line("s1.start","inter2.1", status: "result", extend: (1,1.5))

  (pause,)

  cetz.angle.angle("s1.start","s1.end", "inter2.1", radius: 1.5)
})
