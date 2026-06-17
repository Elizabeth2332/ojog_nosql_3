// --- Query 1: Find top 20 nodes by degree (all relationship types) ---
MATCH (n)
WITH n, COUNT {(n)--()} AS degree
ORDER BY degree DESC
LIMIT 20
RETURN labels(n)[0]                                    AS nodeType,
       coalesce(n.name, n.title, toString(n.userId))   AS name,
       degree;

// --- Query 2: Degree distribution: how many nodes have degree > 500? ---
MATCH (n)
WITH n, COUNT {(n)--()} AS degree
WHERE degree > 500
RETURN degree, count(*) AS nodeCount
ORDER BY degree DESC;

// --- Query 3: Which Genre nodes are supernodes? ---
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)
WITH g.name AS genre, count(m) AS movieCount
ORDER BY movieCount DESC
RETURN genre, movieCount;

// --- Query 4: Which movies have the most ratings? ---
MATCH (m:Movie)<-[r:RATED]-()
WITH m.title AS movie, count(r) AS ratingCount
ORDER BY ratingCount DESC
LIMIT 10
RETURN movie, ratingCount;

// --- Query 5: Which users rated the most movies? ---
MATCH (u:User)-[r:RATED]->()
WITH u.userId AS userId, count(r) AS ratingCount
ORDER BY ratingCount DESC
LIMIT 10
RETURN userId, ratingCount;