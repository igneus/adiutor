"""exploratory tests verifying assumptions about music21"""

import pytest

from music21 import converter, volpiano
import chant21

shared_examples = [
    ('1---'),
    ('1---a-'),
    ('1---a-b-'),

    # Volpiano parser does not reflect syllable and word boundaries;
    # chant21 Volpiano parser shares weaknesses of the music21 built-in one
    # and additionally does not handle neumes correctly
    # ('1---a--b-'), # TODO: does not work
    # ('1---a---b-'), # TODO: does not work
    # ('1---ab-'), # TODO: does not work with chant21
]

@pytest.mark.parametrize(
    'input',
    shared_examples + [
        ('1---ab-'),
    ]
)
def test_volpiano_input_output_coherent(input):
    parsed = converter.parse('volpiano: ' + input)
    # parsed.show('text')
    reserialized = volpiano.fromStream(parsed)
    assert reserialized == input

@pytest.mark.parametrize(
    'input',
    shared_examples
)
def test_chant21_volpiano_input_output_coherent(input):
    parsed = converter.parse('cantus: ' + input)
    # parsed.show('text')
    reserialized = volpiano.fromStream(parsed)
    assert reserialized == input
