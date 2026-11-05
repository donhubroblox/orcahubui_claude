"""Runs tests/smoke.lua against OrcaHub.lua inside a mocked Roblox environment.

Usage: pip install lupa && python3 tests/run.py
"""
import json
import os
import sys

import lupa

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    lua = lupa.LuaRuntime(unpack_returned_tuples=True)
    g = lua.globals()
    files = {}

    def to_py(v):
        if lupa.lua_type(v) == "table":
            keys = list(v.keys())
            if keys and all(isinstance(k, int) for k in keys):
                return [to_py(v[i]) for i in range(1, len(keys) + 1)]
            return {str(k): to_py(v[k]) for k in keys}
        return v

    def to_lua(v):
        if isinstance(v, dict):
            return lua.table_from({k: to_lua(x) for k, x in v.items()})
        if isinstance(v, list):
            return lua.table_from([to_lua(x) for x in v])
        return v

    g.TEST_MOBILE = "--mobile" in sys.argv
    mock = lua.execute(open(os.path.join(ROOT, "tests", "mock_roblox.lua")).read())
    mock.json_encode = lambda v: json.dumps(to_py(v))
    mock.json_decode = lambda s: to_lua(json.loads(s))

    g.writefile = lambda p, c: files.__setitem__(p, c)
    g.readfile = lambda p: files[p]
    g.isfile = lambda p: p in files
    g.isfolder = lambda p: True
    g.makefolder = lambda p: None
    g.delfile = lambda p: files.pop(p, None)
    g.listfiles = lambda folder: lua.table_from([k for k in files if k.startswith(folder + "/") and k.endswith(".json")])

    wrap = lua.eval("function(f) return function(...) return f(...) end end")
    for name in ("writefile", "readfile", "isfile", "isfolder", "makefolder", "delfile", "listfiles"):
        g[name] = wrap(g[name])

    source = open(os.path.join(ROOT, "OrcaHub.lua")).read()
    g.MOCK = mock
    g.LIB = lua.eval("function(src) return function() return assert(load(src, '=OrcaHub.lua'))() end end")(source)
    lua.execute(open(os.path.join(ROOT, "tests", "smoke.lua")).read())


if __name__ == "__main__":
    try:
        main()
    except lupa.LuaError as e:
        print("LUA ERROR:", e)
        sys.exit(1)
