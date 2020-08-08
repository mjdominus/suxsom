CREATE TABLE `meta` (
  obj_id integer,
  k varchar(64) NOT NULL,
  v blob,
  FOREIGN KEY(obj_id) REFERENCES object(id)
)
