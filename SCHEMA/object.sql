CREATE TABLE `object` (
  id integer PRIMARY KEY,
  name varchar(64) NOT NULL,
  owner varchar(64) NOT NULL,
  last_modified integer NOT NULL,    -- epoch seconds
  UNIQUE(name, owner)
)
