CREATE TABLE `meta` (
  id integer PRIMARY KEY,
  sux_id integer,
  k varchar(64) NOT NULL,
  v blob,
  UNIQUE(sux_id, k),
  FOREIGN KEY(sux_id) REFERENCES sux(id)
)
