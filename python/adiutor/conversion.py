import re

from music21 import clef, converter, volpiano, mei
import chant21

from . import lilypond21

def gabc2volpiano(gabc):
    """convert gabc to Volpiano"""
    chant = converter.parse('gabc: ' + strip_gabc_header(gabc))

    return '1---' + chant21_to_volpiano(chant)[0]

def lilypond2volpiano(lilypond):
    """convert ('In adiutorium' subset of) LilyPond to Volpiano"""
    chant = lilypond21.parse(lilypond)

    return '1---' + chant21_to_volpiano(chant)[0]

def mei2volpiano(mei_str):
    """convert MEI to Volpiano"""
    conv = mei.MeiToM21Converter(mei_str)
    score = conv.run()

    for stream in score.recurse(streamsOnly=True):
        stream.removeByClass('Barline')

    return volpiano.fromStream(score)

def chant21_to_volpiano(score, bIsFlat = False):
    """convert Stream loaded using chant21 to Volpiano"""
    r = []

    ignoredElements = set(['Flat', 'Natural', 'Pausa', 'Annotation'])

    for el in score:
        elClasses = set(el.classes)

        if 'Note' in elClasses:
            accidental = el.pitch.accidental
            if accidental is None or accidental.name == 'natural':
                if el.pitch.step == 'B' and bIsFlat:
                    bIsFlat = False
                    r.append('I')
            elif accidental.name == 'flat':
                if el.pitch.step != 'B':
                    raise RuntimeError('Flat on unsupported pitch {}'.format(el.pitch.step))
                if not bIsFlat:
                    bIsFlat = True
                    r.append('i')
            else:
                raise RuntimeError("accidental {} unsupported".format(accidental.name))

            r.append(_note(el))
        elif ignoredElements.intersection(elClasses):
            continue
        elif 'Word' in elClasses and _contains_no_notes(el):
            continue
        elif 'Section' in elClasses and _is_euouae(el):
            continue
        else:
            word_volpiano, bIsFlat = chant21_to_volpiano(el, bIsFlat)
            r.append(word_volpiano)

            if set(['Word', 'Syllable', 'Neume']).intersection(elClasses):
                r.append('-')

    return ''.join(r), bIsFlat


GABC_HEADER_RE = re.compile(r'.*(?=%%)', re.MULTILINE|re.DOTALL)


def strip_gabc_header(gabc_source):
    """removes gabc header"""
    return GABC_HEADER_RE.sub('', gabc_source)

lastClef = clef.TrebleClef()
def _note(n):
    """based on code from music21.volpiano.fromStream"""
    p = n.pitch
    dnn = p.diatonicNoteNum
    distanceFromLowestLine = dnn - lastClef.lowestLine
    indexInPitchString = distanceFromLowestLine + 5
    if indexInPitchString < 0 or indexInPitchString >= len(volpiano.normalPitches):
        raise RuntimeError('pitch {} out of range'.format(p))

    return volpiano.normalPitches[indexInPitchString]

def _contains_no_notes(stream):
    return len(stream.recurse().notes) == 0

EUOUAE_RE = re.compile(r'^euouae\.?$', re.IGNORECASE)

def _is_euouae(section):
    lyrics_ignore_spaces = ''.join([i.flatLyrics for i in section.words if i.flatLyrics is not None])
    return EUOUAE_RE.match(lyrics_ignore_spaces) or '<eu>' in lyrics_ignore_spaces
