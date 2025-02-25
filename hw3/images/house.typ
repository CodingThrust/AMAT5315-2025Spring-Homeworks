#import "@preview/cetz:0.2.2": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  for (i, loc) in ((0, 2), (-1, 1), (1, 1), (-1, -1), (1, -1)).enumerate(){
    circle(loc, radius: 0.3, name: str(i))
    content(loc, [#i])
  }
  for (i, j) in ((0, 1), (0, 2), (1, 2), (1, 3), (2, 4), (3, 4)){
    line(str(i), str(j))
  }
})