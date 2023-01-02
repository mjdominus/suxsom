
import time

class Sux():
    """*Abstract** A Sux is the object that represents a "product" that is stored in
    the database.

    It has a unique ID, a name, a type (the class that implements it)
    an owner (probably the name of the
    plugin that created it), a metadata dictionary, and a
    last-modified date.
    """

    @classmethod
    def typ(cls):
        raise Exception("Abstract class", cls)

    def __init__(self, name, owner, meta=None, last_modified=None, id=None):

        """Create new sux object, not persistent."""
        self.id = id
        self.type = self.typ()
        self.name = name
        self.owner = owner
        self.set_last_modified(last_modified)
        if meta is None:
            meta = {}
        self.meta = meta

    def persist(self, db):
        return db.save(self)

    def from_rec(self, rec):
        """Given a tuple of id, name, type, owner, and last-modified
        such as one might select from the sux database, construct a sux object
        that represents the sux."""
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
