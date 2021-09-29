"""
CLI entrypoint for executing tasks which were more convenient to write in Python than in Ruby
due to the libraries and tools available.
"""

from os.path import dirname, realpath
import sys

import click
from sqlalchemy import select
from sqlalchemy.orm import Session

my_python_root = dirname(dirname(realpath(__file__)))
sys.path.append(my_python_root)

from adiutor import conversion, model, volpiano_derivates
from adiutor.model import Chant, SourceLanguage


@click.group()
def cli():
    pass


@cli.command(help='Generate Volpiano (and related fields) for all chants')
@click.argument('chant_id', required=False)
@click.option('--missing', help='Only for Chants still missing Volpiano', is_flag=True)
@click.option('--raise-exceptions', help='On exception just crash', is_flag=True)
def volpiano(chant_id=None, missing=False, raise_exceptions=False):
    stmt = select(Chant, SourceLanguage).join(SourceLanguage)

    if chant_id:
        stmt = stmt.where(Chant.id == chant_id)

    if missing:
        stmt = stmt.where(Chant.volpiano == None)

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
