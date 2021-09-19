import pytest

from .conversion import gabc2volpiano

@pytest.mark.parametrize(
    'gabc,volpiano',
    [
        ('(c3)', '1---'),
        ('(c3) (a)', '1---c-'),
        ('(c3) lyr(a)', '1---c---'), # Why?
        ('(c3) ly(a)ric(b)', '1---c--d---'),
        ('(c3) ly(a) ric(b)', '1---c---d---'),
        ('(c3) lyr(ab)', '1---c---d-'), # TODO: neume not handled as such

        # divisiones
        ('(c3) lyr(a) (,)', '1---c---'),
        ('(c3) lyr(a) (;)', '1---c---'),
        ('(c3) lyr(a) (:)',  '1---c------3'),
        ('(c3) lyr(a) (::)', '1---c------4'),

        # clefs
        ('(c1) lyr(d)', '1---c---'),
        ('(c2) lyr(d)', '1---h---'),
        ('(c3) lyr(d)', '1---f---'),
        ('(c4) lyr(d)', '1---d---'),
        ('(f1) lyr(d)', '1---f---'),
        ('(f2) lyr(d)', '1---c---'),
        ('(f3) lyr(d)', '1---b---'),
        ('(f4) lyr(d)', '1---9---'),
    ]
)
def test_gabc2volpiano(gabc, volpiano):
    assert gabc2volpiano(gabc) == volpiano
