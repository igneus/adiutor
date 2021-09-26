import pytest

from .conversion import gabc2volpiano

@pytest.mark.parametrize(
    'gabc,volpiano',
    [
        ('(c3)', '1---'),
        ('(c3) (a)', '1---c---'),
        ('(c3) lyr(a)', '1---c---'), # Why?
        ('(c3) ly(a)ric(b)', '1---c--d---'),
        ('(c3) ly(a) ric(b)', '1---c---d---'),
        ('(c3) ly(a)ric(b) ly(c)ric(d)', '1---c--d---e--f---'),
        ('(c3) lyr(ab)', '1---cd---'),
        # ('(c3) lyr(a b)', '1---c-d---'), # there doesn't seem to be any construct in gabc interpreted by chant21 as separating neumes on the same syllable

        # ignore divisiones
        ('(c3) lyr(a) (,)', '1---c---'),
        ('(c3) lyr(a) (;)', '1---c---'),
        ('(c3) lyr(a) (:)',  '1---c---'),
        ('(c3) lyr(a) (::)', '1---c---'),
        ('(c3) lyr(a) (,) lyr(b) (,) (::)', '1---c---d---'),

        # clefs
        ('(c1) lyr(d)', '1---c---'),
        ('(c2) lyr(d)', '1---h---'),
        ('(c3) lyr(d)', '1---f---'),
        ('(c4) lyr(d)', '1---d---'),
        ('(f1) lyr(d)', '1---f---'),
        ('(f2) lyr(d)', '1---c---'),
        ('(f3) lyr(d)', '1---b---'),
        ('(f4) lyr(d)', '1---9---'),
        ('(c1) lyr(d) (c2) lyr(d)', '1---c---h---'),
    ]
)
def test_gabc2volpiano(gabc, volpiano):
    assert gabc2volpiano(gabc) == volpiano
