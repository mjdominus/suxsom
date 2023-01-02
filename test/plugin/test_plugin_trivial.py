from suxsom.plugin.plugin import TestPlugin
from suxsom.plugin.trivial import TrivialPlugin
from suxsom.context import Context
import sys

def test_run_plugin():
    ctx = Context()
    plugin = TrivialPlugin(ctx)
    print("Plugin test not writtten yet", file=sys.stderr)
    assert(False)
