import pytest

from .volpiano_derivates import *

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
    assert pitch_series(volpiano) == expected

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
    assert interval_series(volpiano) == expected
