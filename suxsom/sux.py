
import time

class Sux():
    def __init__(self, name, typ, owner, meta=None, last_modified=None, id=None):
        self.id = id
        self.type = typ
        self.name = name
        self.owner = owner
        self.set_last_modified(last_modified)
        if meta is None:
            meta = {}
        self.meta = meta

    def from_rec(self, rec):
        self.id, self.name, self.type, self.owner, self.last_modfied = rec

    def set_last_modified(self, last_modified=None):
        if last_modified is None:
            self.last_modified = time.time()
        else:
            self.last_modified = last_modified

    def __str__(self):
        return f"<sux #{self.id} ({self.type}) '{self.name}' from '{self.owner}'>"

    def __repr__(self):
        return self.__str__()
