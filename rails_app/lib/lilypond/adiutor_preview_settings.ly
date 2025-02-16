% files from the In adiutorium source tree, expected to be on include path
\include "spolecne.ly"
\include "dilyresponsorii.ly"
\include "spolecne/zj19.ly"

\header {
  tagline = ##f
}

\paper {
  left-margin = 0\cm
  right-margin = 0\cm
  top-margin = 0\cm
  bottom-margin = 0\cm

  % A4 width x double A4 height (to fit even our largest pieces on a single page)
  #(set-paper-size '(cons (* 210 mm) (* 2 (* 297 mm))))
}

% responsories from responsoria.ly : generate doxology
doxologieResponsoriumVI = \relative c'' {
  \respVIdoxologie \barFinalis
}

\layout {
  indent = 0
}
