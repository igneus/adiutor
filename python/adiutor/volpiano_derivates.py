"""
Other types of musical encoding generated from Volpiano.
"""

import functools
import re

from music21 import converter
from music21.interval import Interval
import chant21

def pitch_series(volpiano):
    """
    Series of pitches, disregarding neume/syllable/word boundaries and note repetitions.
    """
    notes = list(filter(lambda x: x != '', re.split(r'(?<!i)-*', re.sub(r'^1---', '', volpiano))))

    non_repeating = functools.reduce(
        lambda memo, x: memo + [x] if len(memo) == 0 or x != memo[-1] else memo,
        notes,
        []
    )

    return '-'.join(non_repeating)

def interval_series(volpiano):
    """
    Series of intervals.
    """

    elements = converter.parse('cantus: ' + volpiano).flatten()
    notes = list(filter(lambda x: 'Note' in x.classes, elements))
    intervals = [Interval(a, b) for a, b in zip(notes, notes[1:])]

    interval_codes = [
        ('-' if x.direction.value < 0 else '+') + re.sub(r'^[^\d]*', '', x.simpleName)
        for x in intervals
    ]

    return ''.join(filter(lambda x: x != '+1', interval_codes))

def snippet_interval_series(volpiano):
    """
    Series of intervals, also for snippets without clef.
    """

    return interval_series(
        volpiano if volpiano.startswith('1') else '1---' + volpiano
    )
