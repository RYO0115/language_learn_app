import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from language_learn.core.base_model import Base


@pytest.fixture
def db():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
