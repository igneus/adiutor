"""
Mapping of a subset of the application's database model.
"""

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, Table, Column, Integer, String, ForeignKey
from sqlalchemy.orm import declarative_base, relationship

from . import conversion

load_dotenv()
db_url = os.getenv('APP_DATABASE_URL_PYTHON') or os.getenv('APP_DATABASE_URL')
engine = create_engine(db_url, echo=True, future=True)

Base = declarative_base()

class Chant(Base):
    __tablename__ = 'chants'

    id = Column(Integer, primary_key=True)
    source_language_id = Column(Integer, ForeignKey('source_languages.id'))

    source_code = Column(String)
    volpiano = Column(String)
    pitch_series = Column(String)
    interval_series = Column(String)

    source_language = relationship('SourceLanguage', back_populates='chants')

    def volpiano_convertor(self):
        return getattr(conversion, self.source_language.system_name + '2volpiano')

class SourceLanguage(Base):
    __tablename__ = 'source_languages'

    id = Column(Integer, primary_key=True)
    system_name = Column(String)

    chants = relationship('Chant', back_populates='source_language')
