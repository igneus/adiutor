% files from the In adiutorium source tree, expected to be on include path
\include "spolecne.ly"
\include "dilyresponsorii.ly"

\header {
  tagline = ##f
}

\paper {
  left-margin = 0\cm
  right-margin = 0\cm
  top-margin = 0\cm
  bottom-margin = 0\cm
}

% responsories from responsoria.ly : generate doxology
doxologieResponsoriumVI = \relative c'' {
  \respVIdoxologie \barFinalis
}

\layout {
  indent = 0
}
