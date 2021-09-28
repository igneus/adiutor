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

    syllables = lyrics_syllables(music)
    word_lengths = lyrics_word_lengths(syllables)

    chant = Chant()

    section = Section()
    chant.append(section)

    word = Word()
    section.append(word)

    in_slur = False

    for i in music_content.iter_depth():
        if isinstance(i, ly.music.items.Note):
            if not in_slur:
                if len(word_lengths) > 0:
                    if word_lengths[0] == 0:
                        word_lengths = word_lengths[1:]
                        word = Word()
                        section.append(word)

                    if len(word_lengths) >= 1:
                        word_lengths[0] -= 1

                syllable = Syllable()
                word.append(syllable)

                neume = Neume()
                syllable.append(neume)

            neume.append(_chant21_note(i))

        if isinstance(i, ly.music.items.Slur):
            if i.event == 'stop':
                in_slur = False
            else:
                in_slur = True

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

def lyrics_syllables(ly_score):
    r = []
    word_continues = False
    for i in ly_score.iter_depth():
        if isinstance(i, ly.music.items.LyricText):
            s = str(i.token)
            if word_continues:
                r[-1].append(s)
            else:
                r.append([s])
            word_continues = False
        elif isinstance(i, ly.music.items.LyricItem) and i.token == '--':
            word_continues = True

    return r

def lyrics_word_lengths(syllables):
    return [len(i) for i in syllables]
