import pytest

from .conversion import *

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

        # ignore divisiones
        ('(c3) lyr(a) (,)', '1---c---'),
        ('(c3) lyr(a) (;)', '1---c---'),
        ('(c3) lyr(a) (:)',  '1---c---'),
        ('(c3) lyr(a) (::)', '1---c---'),
        ('(c3) lyr(a) (,) lyr(b) (,) (::)', '1---c---d---'),
        ('(c3) lyr(a,h)', '1---c-k---'),
        ('(c3) lyr(a;h)', '1---c-k---'),
        ('(c3) lyr(a:h)', '1---c-k---'),
        ('(c3) lyr(a::h)', '1---c-k---'),

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
        # In gabc flat/natural applies up to the cancel or end of the word,
        # in Volpiano (at least in the CANTUS network) up to the cancel
        ('(c3) lyr(gxg) lyr(g)', '1---ij---Ij---'),
        # flat on pitches other than b has no effect
        # special case is the note e, see the next test
        # TODO: this is suboptimal behavior, but should be harmless for our datasets
        ('(c4) (dxd) (fxf) (gxg) (hxh) (jxj)', '1---d---f---g---h---k---'),
        # natural
        # TODO: this is unexpected - flat/natural in the middle of a neume
        #   breaks the neume in two
        pytest.param('(c4) lyr(ixiiyi)', '1---ijIj---', marks=pytest.mark.xfail),
        ('(c3) ly(gxg)ric(gyg)', '1---ij--Ij---'),

        # euouae
        ('(c4) A(h)men.(h) (::) E(h) u(h) o(f) u(gh) a(g) e.(f.) (::)', '1---h--h---'),
        ('(c4) A(h)men.(h) (::) E(h) u(h) o(f) u(gh) a(g) e(f.) (::)', '1---h--h---'),
        ('(c4) A(h)men.(h) (::) E(h) U(h) O(f) U(gh) A(g) E.(f.) (::)', '1---h--h---'),
        ('(c4) A(h)men.(h) (::) E(h)u(h)o(f)u(gh)a(g)e.(f.) (::)', '1---h--h---'),
        ('(c4) A(h)men.(h) (::) <eu>any(i) text(i)</eu> (::)', '1---h--h---'),
    ]
)
def test_gabc2volpiano(gabc, volpiano):
    assert gabc2volpiano(gabc) == volpiano

def test_gabc2volpiano_unsupported_flat():
    gabc = '(c4) lyr(exe)'
    with pytest.raises(RuntimeError) as excinfo:
        gabc2volpiano(gabc)

    assert str(excinfo.value) == 'Flat on unsupported pitch E'

@pytest.mark.parametrize(
    'given,expected',
    [
        ('', ''),
        ('(c4) (c)', '(c4) (c)'),
        ("header: value;\n%%", '%%'),
    ]
)
def test_strip_gabc_header(given, expected):
    assert strip_gabc_header(given) == expected

@pytest.mark.parametrize(
    'lilypond,volpiano',
    [
        ("\\score { \\relative c' { c4 } }", '1---c---'),
        ("\\score { \\relative c' { c2 } }", '1---c---'),
        ("\\score { \\relative c' { c } }", '1---c---'),
        ("\\score { \\relative c' { d4 } }", '1---d---'),
        ("\\score { \\relative c'' { c4 } }", '1---k---'),
        ("\\score { \\relative c'' { bes4 } }", '1---ij---'),
        ("\\score { \\relative c' { c4 d e f g a b c } }", '1---c--d--e--f--g--h--j--k---'),
        ("\\score { \\relative c' { c4( d) } }", '1---cd---'),
        ("\\score { \\relative c' { c4( d e) } }", '1---cde---'),

        ("\\score { \\relative c' { \\key f \\major c4 }", '1---c---'),

        ("\\score { \\relative c' { c4 c } }", '1---c--c---'),
        ("\\score { \\relative c' { c4 c } \\addlyrics { a -- men } }", '1---c--c---'),
        ("\\score { \\relative c' { c4 c } \\addlyrics { hic sum } }",  '1---c---c---'),
        ("\\score { \\relative c' { c4 c c c } \\addlyrics { hic sum, a -- men } }",  '1---c---c---c--c---'),
        ("\\score { \\relative c' { c4 c c c } \\addlyrics { a -- men, hic sum } }",  '1---c--c---c---c---'),
        ("\\score { \\relative c' { c4 c c c } \\addlyrics { a -- men, a -- men } }",  '1---c--c---c--c---'),
        ("\\score { \\relative c' { c4 c( d) c c } \\addlyrics { a -- men, a -- men } }",  '1---c--cd---c--c---'),
        ("\\score { \\relative c' { c4 } \\addlyrics { a -- men } }", '1---c---'),
        ("\\score { \\relative c' { c4 c c } \\addlyrics { a -- men } }", '1---c--c---c---'),
        ("\\score { \\relative c' { \\[ c4( d \\] \\[ c b) \\] c } \\addlyrics { a -- men } }", '1---cd-cb--c---'),
        ("\\score { \\relative c' { \\neviditelna c c4 } }", '1---c---'),
        ("\\score { \\relative c' { a \\neviditelna c a \\neviditelna d a } }", '1---a--a--a---'),
    ]
)
def test_lilypond2volpiano(lilypond, volpiano):
    assert lilypond2volpiano(lilypond) == volpiano

@pytest.mark.parametrize(
    'meiContent,volpiano',
    [
        # single note
        (
            '''<section>
                <measure right="invis">
                    <staff n="1">
                        <layer>
                            <note pname="f" oct="4" dur="4" stem.dir="up" stem.len="0">
                                <verse n="1">
                                    <syl>La</syl>
                                </verse>
                            </note>
                        </layer>
                    </staff>
                </measure>
            </section>''',
            '1---f---'
        ),
        # syllable and word boundaries
        (
            '''<section>
                <measure right="invis">
                    <staff n="1">
                        <layer>
                            <note pname="f" oct="4" dur="4" stem.dir="up" stem.len="0">
                                <verse n="1">
                                    <syl>Post</syl>
                                </verse>
                            </note>
                            <note pname="f" oct="4" dur="4" stem.dir="up" stem.len="0">
                                <verse n="1">
                                    <syl wordpos="i">par-</syl>
                                </verse>
                            </note>
                            <note pname="f" oct="4" dur="4" stem.dir="up" stem.len="0">
                                <verse n="1">
                                    <syl wordpos="t">tum</syl>
                                </verse>
                            </note>
                        </layer>
                    </staff>
                </measure>
            </section>''',
            '1---f---f--f---'
        ),
        # melisma
        (
            '''<section>
                <measure right="invis">
                    <staff n="1">
                        <layer>
                            <note pname="d" oct="4" dur="4" stem.dir="up" stem.len="0">
                                <verse n="1">
                                    <syl>In</syl>
                                </verse>
                            </note>
                            <note pname="c" oct="4" dur="4" stem.dir="up" stem.len="0">
                                <verse n="1">
                                    <syl wordpos="i">con-</syl>
                                </verse>
                            </note>
                            <note pname="a" oct="3" dur="4" stem.dir="up" stem.len="0" />
                            <note pname="c" oct="4" dur="4" stem.dir="up" stem.len="0">
                                <verse n="1">
                                    <syl wordpos="m">cur-</syl>
                                </verse>
                            </note>
                        </layer>
                    </staff>
                </measure>
                <measure right="invis">
                    <staff n="1">
                        <layer>
                            <note pname="d" oct="4" dur="4" stem.dir="up" stem.len="0" />
                            <note pname="d" oct="4" dur="4" stem.dir="up" stem.len="0">
                                <verse n="1">
                                    <syl wordpos="t">sU</syl>
                                </verse>
                            </note>
                        </layer>
                    </staff>
                </measure>
            </section>''',
            '1---d---ca--cd--d---'
        ),
    ]
)
def test_mei2volpiano(meiContent, volpiano):
    meiTemplate = '''<?xml version="1.0" encoding="UTF-8"?>
    <mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="2013">
        <music>
            <body>
                <mdiv>
                    <score>
                        <scoreDef>
                            <staffGrp>
                                <staffDef clef.line="2" clef.shape="G" lines="5" n="1" />
                            </staffGrp>
                        </scoreDef>

                        <!-- the test-case-specific content will be inserted here -->
                        {}
                    </score>
                </mdiv>
            </body>
        </music>
    </mei>'''
    mei = meiTemplate.format(meiContent)

    assert mei2volpiano(mei) == volpiano
