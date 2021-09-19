from music21 import converter, volpiano
import chant21

def gabc2volpiano(gabc):
    """convert gabc to Volpiano"""
    chant = converter.parse('gabc: ' + gabc)
    return volpiano.fromStream(chant)
