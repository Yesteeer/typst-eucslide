#import "@preview/touying:0.7.4": *

// TOUYING SLIDE STYLING

// a simple slide
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

// shows the construction step
#let show-step(self) = {
  let n = self.subslide
  if n > 1 and n != self.repeat [
    Étape #(n - 1)
  ] else if n != 1 [
    Construction en #(n - 2) étapes
  ]
}

// a slide for each section
#let new-section-slide-fn = (config: config-page(header: none), body) => touying-slide-wrapper(self => {
  touying-slide(self: self, config: config, align(
    center + horizon,
    text(2em, weight: "bold", utils.display-current-heading(level: 1))
  ))
})

// a slide for each subsection
#let new-subsection-slide-fn = (config: config-page(
    header: [#text(fill: gray, size: .8em)[#utils.display-current-heading(level: 1)] #h(1fr)]
  ), body) => touying-slide-wrapper(self => {
    touying-slide(
      self: self, 
      config: config,
      align(
        center + horizon,
        text(1.2em, weight: "bold")[#utils.display-current-heading(level: 2)]
      )
    )
  }
)

// header style
#let header-fn(steps) = self => [
  #text(fill: gray, size: .8em, utils.display-current-heading(level: 2))
  #h(1fr)
  #if steps [#text(fill: gray, size: .8em, show-step(self))]
]

// euclidea-theme
#let euclidea-theme(
  show-steps: true,
  aspect-ratio: "16-9",
  handout: true,
  lang: "de",
  ..args,
  body
) = {
  set text(size: 20pt)
  set align(center + horizon)
  set text(font: "New Computer Modern Sans", lang: lang)  

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (x: 2cm, top: 2cm, bottom: 2cm),
      header-ascent: 20%,
      header: header-fn(show-steps)
    ),
    config-common(
      slide-fn: slide,
      handout: handout,
      handout-subslides: (1, -1),
      zero-margin-header: false,
      new-section-slide-fn: new-section-slide-fn,
      new-subsection-slide-fn: new-subsection-slide-fn,
    ),
    ..args,
  )
  body
}

