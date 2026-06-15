// Indexes first — ALWAYS before loading edges
CREATE INDEX user_id IF NOT EXISTS FOR (u:User) ON (u.userId);
CREATE INDEX movie_id IF NOT EXISTS FOR (m:Movie) ON (m.movieId);
CREATE INDEX genre_name IF NOT EXISTS FOR (g:Genre) ON (g.name);

// Load Users
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {userId: toInteger(row.userId)})
SET u.gender = row.gender,
    u.age = toInteger(row.age),
    u.occupation = toInteger(row.occupation);

// Load Movies + Genre nodes
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET m.title = row.title,
    m.year = toInteger(substring(row.title, size(row.title)-5, 4))
WITH m, row
UNWIND split(row.genres, '|') AS genreName
MERGE (g:Genre {name: genreName})
MERGE (m)-[:HAS_GENRE]->(g);

// Load Ratings in batches (1M rows — must use apoc)
CALL apoc.periodic.iterate(
  'LOAD CSV WITH HEADERS FROM "file:///ratings.csv" AS row RETURN row',
  'MATCH (u:User {userId: toInteger(row.userId)})
   MATCH (m:Movie {movieId: toInteger(row.movieId)})
   MERGE (u)-[r:RATED]->(m)
   SET r.rating = toInteger(row.rating),
       r.timestamp = toInteger(row.timestamp)',
  {batchSize: 10000, parallel: false}
);