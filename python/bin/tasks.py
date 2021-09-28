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

from adiutor import conversion, model
from adiutor.model import Chant, SourceLanguage


@click.group()
def cli():
    pass


@cli.command(help='Generate Volpiano for all gabc chants')
@click.argument('chant_id', required=False)
def volpiano(chant_id=None):
    stmt = select(Chant).join(SourceLanguage).where(SourceLanguage.system_name == 'gabc')

    if chant_id:
        stmt = stmt.where(Chant.id == chant_id)

    with Session(model.engine) as session:
        for row in session.execute(stmt):
            chant = row[0]
            print(chant.id)
            try:
                volpiano_code = conversion.gabc2volpiano(chant.source_code)
            except Exception as e:
                print(e)
                continue

            chant.volpiano = volpiano_code
            session.commit()


cli()
