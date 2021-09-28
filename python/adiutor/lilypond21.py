"""
Dealing with our subset of LilyPond used to notate chant pieces
of the In adiutorium corpus
"""

from chant21.chant import Chant, Section, Word, Syllable, Neume, Note
import music21.pitch

import ly.document
import ly.music
from ly.pitch.rel2abs import rel2abs


def parse(lilypond_source):
    document = ly.document.Document(lilypond_source)

    # convert relative pitches to absolute
    cursor = ly.document.Cursor(document)
    rel2abs(cursor)

    music = ly.music.document(document)
    music_content = next(music.music_children())

    chant = Chant()

    section = Section()
    chant.append(section)

    word = Word()
    section.append(word)

    for i in music_content.iter_depth():
        if isinstance(i, ly.music.items.Note):
            syllable = Syllable()
            word.append(syllable)

            neume = Neume()
            syllable.append(neume)

            neume.append(_chant21_note(i))

    return chant

def _chant21_note(ly_note):
    note = Note()
    note.pitch = _chant21_pitch(ly_note.pitch)
    return note

def _chant21_pitch(ly_pitch):
    pitch_str = ly_pitch.output()
    pitch = music21.pitch.Pitch(pitch_str[0], octave=ly_pitch.octave + 3)
    if 'es' in pitch_str:
        pitch.accidental = music21.pitch.Accidental('flat')

    return pitch
