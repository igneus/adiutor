"""
Transforms a MEI document to chant21 data structures.
"""

from chant21.chant import Chant, Section, Word, Syllable, Neume, Note
from music21 import mei, pitch


def parse(mei_str):
    conv = mei.MeiToM21Converter(mei_str)
    score = conv.run()

    chant = Chant()

    section = Section()
    chant.append(section)

    word = Word()
    section.append(word)

    for el in score.recurse():
        elClasses = set(el.classes)
        if 'Note' in elClasses:
            if el.lyric or word.first() is None:
                print(el.lyrics)
                if el.lyric and el.lyrics[0].syllabic in ('begin', 'single'):
                    word = Word()
                    section.append(word)
                syllable = Syllable()
                word.append(syllable)
                neume = Neume()
                syllable.append(neume)

            neume.append(el)

    return chant
