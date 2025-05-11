CREATE TABLE `sux` (
  id integer PRIMARY KEY,
  name varchar(64) NOT NULL,
  type varchar(16) NOT NULL,
  owner_id integer NOT NULL,
  last_modified integer NOT NULL,    -- epoch seconds
  UNIQUE(name, owner);
  FOREIGN KEY(owner_id) REFERENCES plugin(id)
)
