import pytest
from sqlalchemy.orm import Session

from .model import engine, Chant

def test_smoke():
    """
    Test that we can connect to the db and run a simple query.

    TODO we are connecting to the development db - don't touch it; configure test db if need be
    """

    with Session(engine) as session:
        assert session.query(Chant).count() >= 0
