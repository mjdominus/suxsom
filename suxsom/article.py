
# -*- python -*-

import re

import suxsom.meta
import suxsom.sux

class article(sux):
    @classmethod
    def owner(cls):
        return "article"

    @classmethod
    def from_file(cls, path, prefix):
        with open(filename, "r") as fh:
            if path.startswith(prefix):
                shortpath = path[ len(prefix): ]
            else:
                shortpath = filename

            meta = suxsom.meta(cls.parse_metainfo(fh))
            content = fh.read()
            last_modified = figure_out_last_modified(filename)
            return suxsom.sux(name=shortpath,
                              owner=self.owner(),
                              last_modified=last_modified,
                              meta=meta)

    def parse_metainfo(cls, fh):
        line1 = fh.readline().rstrip()
        if line1 != "META":
            fh.readline()       # discard blank line
            return suxsom.meta({ "title": line1 })

        meta = {}
        while True:
            line = fh.readline().rstrip()
            match = re.match(r'(.*?): (.*)', line)
            key, value = match.groups()
            meta[key] = value
        return suxsom.meta(meta)
