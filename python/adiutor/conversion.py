from music21 import clef, converter, volpiano
import chant21

def gabc2volpiano(gabc):
    """convert gabc to Volpiano"""
    chant = converter.parse('gabc: ' + gabc)

    return '1---' + chant21_to_volpiano(chant)

def chant21_to_volpiano(score):
    """convert Stream loaded using chant21 to Volpiano"""
    r = []

    for el in score:
        elClasses = el.classes

        if 'Note' in elClasses:
            r.append(_note(el))
        elif 'Flat' in elClasses:
            if el.pitch.step != 'B':
                raise RuntimeError('Flat on unsupported pitch {}'.format(el.pitch.step))
            r.append('i')
        elif 'Natural' in elClasses:
            if el.pitch.step != 'B':
                raise RuntimeError('Natural on unsupported pitch {}'.format(el.pitch.step))
            r.append('I')
        else:
            if 'Word' in elClasses and _contains_no_notes(el):
                continue

            r.append(chant21_to_volpiano(el))

            if 'Word' in elClasses or 'Syllable' in elClasses or 'Neume' in elClasses:
                r.append('-')

    return ''.join(r)

lastClef = clef.TrebleClef()
def _note(n):
    """based on code from music21.volpiano.fromStream"""
    p = n.pitch
    dnn = p.diatonicNoteNum
    distanceFromLowestLine = dnn - lastClef.lowestLine
    indexInPitchString = distanceFromLowestLine + 5
    if indexInPitchString < 0 or indexInPitchString >= len(volpiano.normalPitches):
        raise RuntimeError('pitch out of range')

    return volpiano.normalPitches[indexInPitchString]

def _contains_no_notes(stream):
    return len(stream.recurse().notes) == 0
