
import time

class Sux():
    @classmethod
    def typ(cls):
        raise Exception("Abstract class", cls)

    def __init__(self, name, owner, meta=None, last_modified=None, id=None):
        self.id = id
        self.type = self.typ()
        self.name = name
        self.owner = owner
        self.set_last_modified(last_modified)
        if meta is None:
            meta = {}
        self.meta = meta

    def from_rec(self, rec):
        self.id, self.name, typ, self.owner, self.last_modfied = rec
        if typ != self.typ():
            raise Exception(f"Can't load {self} from record {rec.id}: it has type {typ} but {self.typ()} is required")

    def set_last_modified(self, last_modified=None):
        if last_modified is None:
            self.last_modified = time.time()
        else:
            self.last_modified = last_modified

    def __str__(self):
        return f"<sux #{self.id} ({self.type}) '{self.name}' from '{self.owner}'>"

    def __repr__(self):
        return self.__str__()


# This should be in the test suite, not here
# But I don't want to figure out pytest right now
class TestSux(Sux):
    @classmethod
    def typ(cls):
        return "test type"
