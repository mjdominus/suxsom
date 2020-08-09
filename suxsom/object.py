
import time

class object():
    def __init__(self, name, owner, last_modified=None, meta=None, id=None):
        self.id = id
        self.name = name
        self.owner = owner
        self.set_last_modified(last_modified)
        if meta is None:
            meta = {}
        self.meta = meta

    def from_rec(self, rec):
        self.id, self.name, self.owner, self.last_modfied = rec

    def set_last_modified(self, last_modified=None):
        if last_modified is None:
            self.last_modified = time.time()
        else:
            self.last_modified = last_modified

    def __str__(self):
        return f"<object #{self.id} '{self.name}' from '{self.owner}'>"

    def __repr__(self):
        return self.__str__()
