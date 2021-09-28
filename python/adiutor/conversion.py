from music21 import clef, converter, volpiano
import chant21

def gabc2volpiano(gabc):
    """convert gabc to Volpiano"""
    chant = converter.parse('gabc: ' + gabc)

    return '1---' + chant21_to_volpiano(chant)[0]

def chant21_to_volpiano(score, bIsFlat = False):
    """convert Stream loaded using chant21 to Volpiano"""
    r = []

    for el in score:
        elClasses = el.classes

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
        elif 'Flat' in elClasses or 'Natural' in elClasses:
            continue
        else:
            if 'Word' in elClasses and _contains_no_notes(el):
                continue

            word_volpiano, bIsFlat = chant21_to_volpiano(el, bIsFlat)
            r.append(word_volpiano)

            if 'Word' in elClasses or 'Syllable' in elClasses or 'Neume' in elClasses:
                r.append('-')

    return ''.join(r), bIsFlat

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
