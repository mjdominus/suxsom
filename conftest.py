
from suxsom.db import DB
import pytest

@pytest.fixture
def suxdb(tmpdir):
    db = DB(tmpdir / "test.db")
    db.create_tables()
    return db
