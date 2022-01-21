
# -*- python -*-

import re

import suxsom

class Article(sux):

    @classmethod
    def owner(cls):
        return "article"

    @classmethod
    def from_file(cls, path, prefix):
        if path.startswith(prefix):
            shortpath = path[ len(prefix): ]
        else:
            shortpath = path

        with open(path, "r") as fh:
            line1 = fh.getline()
            if line1 == "META\n":
                meta = cls.load_metainfo(fh)
            else:
                meta = suxsom.meta.Meta({ "title": line1 })

            return cls.from_string(fh.read(), shortpath, meta, cls.figure_out_last_modified(path, prefix))

    @classmethod
    def from_string(cls, s, name, meta=None, last_modified=None, **kwargs):
        if meta is None:
            meta = suxsom.meta.Meta()
        meta["content"] = s

        return Article(name=name,
                       owner=self.owner(),
                       meta=meta,
                       last_modified=last_modified,
                       **kwargs)

    def load_metainfo(cls, fh):
        meta = {}
        while True:
            line = fh.readline().rstrip()
            if re.search(r'\S', line):
                break
            match = re.match(r'(.*?): (.*)', line)
            key, value = match.groups()
            meta[key.lower()] = value

        return suxsom.meta.Meta(meta)
