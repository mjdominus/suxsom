
class SuxNotFound(Exception):
    pass

class Context():
    """A Context seems to be an in-memory list of products.
    Don't need it, get rid of it.  Just query the fucking database.

    Or maybe this is a wrapper providing a more abstract
    API for the  database object?
    """

    def __init__(self):
        raise Exception("Why aren't you just using the database?")

    def failed(self, fail_ok, msg):
        if fail_ok:
            return None
        else:
            raise SuxNotFound(msg)

    def find_by_name(self, owner, name, fail_ok=True):
        for sux in self.i:
            if sux.owner == owner and self.name == name:
                return sux
        return self.failed(fail_ok, f"Context has no sux '{name}' owned by '{owner}'")

    def find_by_owner(self, owner):
        found = [ sux for sux in self.i if sux.owner == owner ]
        return found

    def find_by_types(self, types):
        found = [ sux for sux in self.i if sux.type in types ]
        return found
