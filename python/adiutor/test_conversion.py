import pytest

from .conversion import gabc2volpiano

@pytest.mark.parametrize(
    'gabc,volpiano',
    [
        # chant structure
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

        # flat
        ('(c4) lyr(ixi)', '1---ij---'),
        ('(c3) lyr(gxg)', '1---ij---'),
        ('(c3) lyr(gxghg)', '1---ijkj---'),
        ('(c3) ly(gxg)ric(g)', '1---ij--j---'),
        # TODO: in gabc flat/natural applies up to the cancel or end of the word,
        #   in Volpiano (at least in the CANTUS network) up to the cancel
        ('(c3) lyr(gxg) lyr(g)', '1---ij---Ij---'),
        # natural
        # TODO: this is unexpected - flat/natural in the middle of a neume
        #   breaks the neume in two
        # ('(c4) lyr(ixiiyi)', '1---ijIj---'),
    ]
)
def test_gabc2volpiano(gabc, volpiano):
    assert gabc2volpiano(gabc) == volpiano

def test_gabc2volpiano_unsupported_flat():
    # note: (dxd) or (gxg) would pass without notice, as chant21
    # only generates flat accidentals for pitches B and E!
    gabc = '(c4) lyr(exe)'

    with pytest.raises(RuntimeError) as excinfo:
        gabc2volpiano(gabc)

    assert str(excinfo.value) == 'Flat on unsupported pitch E'
