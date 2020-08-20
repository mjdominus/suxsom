CREATE TABLE `meta` (
  sux_id integer,
  k varchar(64) NOT NULL,
  v blob,
  FOREIGN KEY(sux_id) REFERENCES sux(id)
)
