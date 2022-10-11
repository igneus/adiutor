"""
Mapping of a subset of the application's database model.
"""

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, Table, Column, Integer, String, ForeignKey
from sqlalchemy.orm import declarative_base, relationship

from . import conversion

def db_url_rails_to_sqlalchemy(rails_db_url):
    """Transform Rails db connection URL to the format expected by SQLAlchemy"""
    return rails_db_url.replace('postgres://', 'postgresql+psycopg2://')

load_dotenv()
db_url = db_url_rails_to_sqlalchemy(os.getenv('APP_DATABASE_URL'))
engine = create_engine(db_url, future=True)

Base = declarative_base()

class Chant(Base):
    __tablename__ = 'chants'

    id = Column(Integer, primary_key=True)
    corpus_id = Column(Integer, ForeignKey('corpuses.id'))
    source_language_id = Column(Integer, ForeignKey('source_languages.id'))

    source_code = Column(String)
    volpiano = Column(String)
    pitch_series = Column(String)
    interval_series = Column(String)

    corpus = relationship('Corpus', back_populates='chants')
    source_language = relationship('SourceLanguage', back_populates='chants')

    def volpiano_convertor(self):
        return getattr(conversion, self.source_language.system_name + '2volpiano')

class Corpus(Base):
    __tablename__ = 'corpuses'

    id = Column(Integer, primary_key=True)
    system_name = Column(String)

    chants = relationship('Chant', back_populates='corpus')

class SourceLanguage(Base):
    __tablename__ = 'source_languages'

    id = Column(Integer, primary_key=True)
    system_name = Column(String)

    chants = relationship('Chant', back_populates='source_language')
