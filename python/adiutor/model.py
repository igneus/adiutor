"""
Mapping of a subset of the application's database model.
"""

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, Table, Column, Integer, String, ForeignKey
from sqlalchemy.orm import declarative_base, relationship

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

    source_language = relationship('SourceLanguage', back_populates='chants')

class SourceLanguage(Base):
    __tablename__ = 'source_languages'

    id = Column(Integer, primary_key=True)
    system_name = Column(String)

    chants = relationship('Chant', back_populates='source_language')
