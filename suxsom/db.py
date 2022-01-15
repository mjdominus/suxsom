
from pathlib import Path
import sqlite3
import sys

import suxsom.sux

class DB():
    def __init__(self, path=None):
        if path is None:
            path = self.default_path()

        self.conn = sqlite3.connect(str(path))

    def default_path(self):
        return "suxsom.db"

    def create_tables(self, d=None):
        if d is None:
            d=Path("SCHEMA")
        for f in d.glob("*.sql"):
            table = f.stem
            print(f"creating table {table}", file=sys.stderr)
            sql = f.read_text()
            self.conn.execute(sql)

    def find_sux_by_id(self, id):
        c = self.conn.cursor()
        c.execute("select * from sux where id = ?", (id, ))
        rec = c.fetchone()
        if rec is None:
            return None
        from pprint import pprint
        pprint(rec)

    def find_sux_by_name(self, owner, name):
        c = self.conn.cursor()
        c.execute("select * from sux where owner = ? and name = ?", (owner, name))
        rec = c.fetchone()
        if rec is None:
            return None
        o = suxsom.sux.sux(name, owner)
        o.from_rec(rec)
        return o

    def save_sux(self, o):
        o.set_last_modified()
        if o.id is None:
            print("creating sux")
            self.conn.execute("""
            insert into sux(name, owner, last_modified)
            values (?, ?, ?)
            """, (o.name, o.owner, o.last_modified))
            c = self.conn.cursor()
            c.execute("""
            select id from sux
            where name = ? and owner = ?
            """, (o.name, o.owner))
            o.id, = c.fetchone()
            self.conn.commit()

        # now the sux has an ID
        self.conn.execute("""
            update sux set name = ?, owner = ?, last_modified = ?
            where id = ?
        """, (o.name, o.owner, o.last_modified, o.id))
        self.save_sux_metadata(o)
        self.conn.commit()

        return o.id

    def save_sux_metadata(self, o):
        pass
