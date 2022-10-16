"""
CLI entrypoint for executing tasks which were more convenient to write in Python than in Ruby
due to the libraries and tools available.
"""

from os.path import dirname, realpath
import sys
import logging

import click
from sqlalchemy import and_, select
from sqlalchemy.orm import Session

my_python_root = dirname(dirname(realpath(__file__)))
sys.path.append(my_python_root)

from adiutor import conversion, model, volpiano_derivates
from adiutor.model import Chant, Corpus, SourceLanguage


@click.group()
def cli():
    pass


@cli.command(help='Generate Volpiano (and related fields) for all chants')
@click.argument('chant_id', required=False)
@click.option('--missing', help='Only for Chants still missing Volpiano', is_flag=True)
@click.option('--corpus', help='Only for the specified Corpus')
@click.option('--source-language', help='Only for the specified SourceLanguage')
@click.option('--raise-exceptions', help='On exception just crash', is_flag=True)
@click.option('--verbose', help='Print verbose log', is_flag=True)
def volpiano(chant_id=None, missing=False, corpus=None, source_language=None, raise_exceptions=False, verbose=False):
    if verbose:
        logging.basicConfig()
        logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

    stmt = select(Chant, SourceLanguage).join(SourceLanguage)

    if chant_id:
        stmt = stmt.where(Chant.id == chant_id)

    if missing:
        stmt = stmt.where(Chant.volpiano == None)

    if corpus:
        stmt = stmt.join(Corpus, and_(Chant.corpus_id == Corpus.id, Corpus.system_name == corpus))

    if source_language:
        stmt = stmt.where(SourceLanguage.system_name == source_language)

    with Session(model.engine) as session:
        for row in session.execute(stmt):
            chant = row[0]
            print(chant.id)
            try:
                convertor = chant.volpiano_convertor()
                volpiano_code = convertor(chant.source_code)
            except Exception as e:
                if raise_exceptions:
                    raise e
                print(e)
                continue

            chant.volpiano = volpiano_code
            chant.pitch_series = volpiano_derivates.pitch_series(volpiano_code)
            chant.interval_series = volpiano_derivates.interval_series(volpiano_code)
            session.commit()


cli()
