
import suxsom

test_type = "test type"

def test_create_bare_sux():
    sux = suxsom.sux.TestSux("test item", "tests")
    assert sux.last_modified is not None
    assert sux.meta is not None
    assert sux.type == test_type

def test_create_fails():
    assert(True)

def test_create_sux_with_meta():
    sux = suxsom.sux.TestSux("test item", "tests", { "key": "value" })
    assert sux.meta["key"] == "value"
