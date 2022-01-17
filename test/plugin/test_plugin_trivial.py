from suxsom.plugin.plugin import TestPlugin
from suxsom.context import Context
import sys

def test_run_plugin():
    ctx = Context()
    plugin = TestPlugin(ctx)
    print("Plugin test not writtten yet", file=sys.stderr)
    assert(False)
