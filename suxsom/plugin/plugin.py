

# abstract class for plugins

class Plugin():
    @classmethod
    def name(cls):
        raise Exception("Abstract class", cls)

    @classmethod
    def expected_input_type(cls):
        raise Exception("Abstract class", cls)

    def __init__(self, ctx):
        self.ctx= ctx

    def find_inputs(self):
        items = self.ctx.find_by_type(self.expected_input_type())
        return items

    def do_one_item(self, item):
        raise Exception("Abstract class", cls)

    def run(self):
        for it in self.find_inputs():
            self.do_one_item(it)

    def __str__(self):
        return f"<plugin #{self.name()}>"

    def __repr__(self):
        return self.__str__()

# This should be in the test suite, not here
# But I don't want to figure out pytest right now
class TestPlugin(Plugin):
    @classmethod
    def typ(cls):
        return "test plugin"
