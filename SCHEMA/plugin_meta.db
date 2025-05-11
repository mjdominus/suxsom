CREATE TABLE `plugin_meta` (
  id integer PRIMARY KEY,
  plugin_id integer NOT NULL,
  k varchar(64) NOT NULL,
  v blob,
  UNIQUE(plugin_id, k),
  FOREIGN KEY(plugin_id) REFERENCES plugin(id)
);
