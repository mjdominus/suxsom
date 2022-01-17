
class SuxNotFound(Exception):
    pass

class Context():
    def __init__(self):
        self.i = []

    def failed(self, fail_ok, msg):
        if fail_ok:
            return None
        else:
            raise SuxNotFound(msg)

    def insert(self, sux):
        self.i.append(sux)

    def find_by_name(self, owner, name, fail_ok=True):
        for sux in self.i:
            if sux.owner == owner and self.name == name:
                return sux
        return self.failed(fail_ok, f"Context has no sux '{name}' owned by '{owner}'")

    def find_by_owner(self, owner):
        found = [ sux for sux in self.i if sux.owner == owner ]
        return found

    def find_by_type(self, typ):
        found = [ sux for sux in self.i if sux.type == typ ]
        return found
