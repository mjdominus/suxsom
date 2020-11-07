from suxsom.db import DB
import sys

def test_null():
    assert(True)

def test_foo(foo):
    assert(len(foo) == 0)

def test_create_db(tmpdir):
    db = DB(tmpdir / "test.db")
    db.create_tables()
    assert(True)
