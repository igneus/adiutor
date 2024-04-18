import pytest

from . import volpiano_derivates as vd

@pytest.mark.parametrize(
    'volpiano,expected',
    [
        ('1---', ''),
        ('1---c', 'c'),
        ('1---c-d', 'c-d'),
        ('1---c--d', 'c-d'),
        ('1---cd', 'c-d'),
        ('1---c-c', 'c'),
        ('1---cdc', 'c-d-c'),
        ('1---cijc', 'c-ij-c'),
    ]
)
def test_pitch_series(volpiano, expected):
    assert vd.pitch_series(volpiano) == expected

@pytest.mark.parametrize(
    'volpiano,expected',
    [
        ('1---', ''),
        ('1---c', ''),
        ('1---c-c', ''),
        ('1---c-d', '+2'),
        ('1---d-c', '-2'),
        ('1---c-c-d', '+2'),
        ('1---cd-dhij-h', '+2+5+2-2'),
    ]
)
def test_interval_series(volpiano, expected):
    assert vd.interval_series(volpiano) == expected

@pytest.mark.parametrize(
    'volpiano,expected',
    [
        ('1---cd-dhij-h', '+2+5+2-2'),
        ('cd-dhij-h', '+2+5+2-2'), # works without clef
    ]
)
def test_snippet_interval_series(volpiano, expected):
    assert vd.snippet_interval_series(volpiano) == expected

ambitus_examples = [
    ('1---c', 'c', 'c', 0),
    ('1---c--c', 'c', 'c', 0),
    ('1---c--d', 'c', 'd', 2),
    ('1---c-d-e-d-c-d-c', 'c', 'e', 4),
    ('1---c-f', 'c', 'f', 5),
]

@pytest.mark.parametrize(
    'volpiano,min_note,max_note,ambitus',
    ambitus_examples
)
def test_min_note(volpiano, min_note, max_note, ambitus):
    assert vd.min_note(volpiano) == min_note

@pytest.mark.parametrize(
    'volpiano,min_note,max_note,ambitus',
    ambitus_examples
)
def test_max_note(volpiano, min_note, max_note, ambitus):
    assert vd.max_note(volpiano) == max_note

@pytest.mark.parametrize(
    'volpiano,min_note,max_note,ambitus',
    ambitus_examples
)
def test_ambitus(volpiano, min_note, max_note, ambitus):
    assert vd.ambitus(volpiano) == ambitus
