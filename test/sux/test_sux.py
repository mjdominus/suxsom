
import suxsom

def test_create_bare_sux():
    sux = suxsom.sux.Sux("test item", "test type", "tests")
    assert sux.last_modified is not None
    assert sux.meta is not None

def test_create_fails():
    assert(True)

def test_create_sux_with_meta():
    sux = suxsom.sux.Sux("test item", "tests", "test type", { "key": "value" })
    assert sux.meta["key"] == "value"
