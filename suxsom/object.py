
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

    def set_last_modified(self, last_modified=None):
        if last_modified is None:
            self.last_modified = time.time()
        else:
            self.last_modified = last_modified
