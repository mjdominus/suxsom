CREATE TABLE `object` (
  id integer PRIMARY KEY,
  name varchar(64),
  owner varchar(64),
  last_modified integer    -- epoch seconds
)
