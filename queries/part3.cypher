// Query 1: Thrillers with avg rating > 4.0
MATCH (g:Genre {name: 'Thriller'})<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-()
WITH m, avg(r.rating) AS avgRating, count(r) AS ratingCount
WHERE avgRating > 4.0 AND ratingCount > 20
RETURN m.title, round(avgRating*100)/100 AS avgRating, ratingCount
ORDER BY avgRating DESC;

// Query 2: Users who gave 5 stars to more than 50 movies
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE r.rating = 5
WITH u, count(m) AS fiveStarCount
WHERE fiveStarCount > 50
RETURN u.userId, fiveStarCount
ORDER BY fiveStarCount DESC;

// Query 3: Movies both user 1 and user 2 rated highly (>=4)
MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User {userId: 2})
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.title, r1.rating AS user1Rating, r2.rating AS user2Rating;

// Query 4: Genres with consistently high ratings
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-()
WITH g.name AS genre, avg(r.rating) AS avgRating, count(r) AS totalRatings
WHERE totalRatings > 1000
RETURN genre, round(avgRating*100)/100 AS avgRating, totalRatings
ORDER BY avgRating DESC;

// Query 5: Collaborative filtering recommendation for user 1
MATCH (target:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(similar:User)
WHERE r1.rating >= 4 AND r2.rating >= 4 AND similar <> target
WITH target, similar, count(m) AS commonMovies
ORDER BY commonMovies DESC LIMIT 20
MATCH (similar)-[r3:RATED]->(rec:Movie)
WHERE r3.rating >= 4
  AND NOT (target)-[:RATED]->(rec)
RETURN rec.title, count(similar) AS recommendedBy, avg(r3.rating) AS avgScore
ORDER BY recommendedBy DESC LIMIT 10;

// Query 6: Shortest path between user 1 and user 500 via shared movies
MATCH path = shortestPath(
  (u1:User {userId: 1})-[:RATED*..10]-(u2:User {userId: 500})
)
RETURN path, length(path) AS pathLength;