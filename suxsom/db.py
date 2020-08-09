
from pathlib import Path
import sqlite3
import sys

import suxsom.object

class db():
    def __init__(self):
        self.conn = sqlite3.connect("suxsom.db")

    def create_tables(self, d=None):
        if d is None:
            d=Path("SCHEMA")
        for f in d.glob("*.sql"):
            table = f.stem
            print(f"creating table {table}", file=sys.stderr)
            sql = f.read_text()
            self.conn.execute(sql)

    def find_obj_by_id(self, id):
        c = self.conn.cursor()
        c.execute("select * from object where id = ?", (id, ))
        rec = c.fetchone()
        if rec is None:
            return None
        from pprint import pprint
        pprint(rec)

    def find_obj_by_name(self, owner, name):
        c = self.conn.cursor()
        c.execute("select * from object where owner = ? and name = ?", (owner, name))
        rec = c.fetchone()
        if rec is None:
            return None
        o = suxsom.object.object(name, owner)
        o.from_rec(rec)
        return o

    def save_obj(self, o):
        o.set_last_modified()
        if o.id is None:
            print("creating")
            self.conn.execute("""
            insert into object(name, owner, last_modified)
            values (?, ?, ?)
            """, (o.name, o.owner, o.last_modified))
            c = self.conn.cursor()
            c.execute("""
            select id from object
            where name = ? and owner = ?
            """, (o.name, o.owner))
            o.id, = c.fetchone()
            self.conn.commit()

        # now the object has an ID
        self.conn.execute("""
            update object set name = ?, owner = ?, last_modified = ?
            where id = ?
        """, (o.name, o.owner, o.last_modified, o.id))
        self.save_obj_metadata(o)
        self.conn.commit()

        return o.id

    def save_obj_metadata(self, o):
        pass
