CREATE TABLE `sux` (
  id integer PRIMARY KEY,
  name varchar(64) NOT NULL,
  type varchar(16) NOT NULL,
  owner varchar(16) NOT NULL,
  last_modified integer NOT NULL,    -- epoch seconds
  UNIQUE(name, owner)
)
