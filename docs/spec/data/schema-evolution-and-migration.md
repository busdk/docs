# Schema evolution and migration

BusDK assumes schemas will evolve as a business evolves. Schema changes are versioned in Git and may include a schema version indicator so tooling can identify the schema version at a given commit. When adding fields, BusDK may provide migration commands that insert default values across historical rows, or it may treat missing fields in older rows as null/default during reporting. Large structural changes such as splitting a file or renaming a field are acceptable so long as migrations are transparent and recorded in Git history.

