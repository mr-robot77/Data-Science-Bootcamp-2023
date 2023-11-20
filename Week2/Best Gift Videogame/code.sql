
-- Section1

SELECT platform_name, AVG(num_sales) AS Average
FROM region_sales rs
JOIN game_platform gp ON rs.game_platform_id = gp.id
JOIN platform p ON gp.platform_id = p.id
GROUP BY platform_name
ORDER BY Average DESC;

-- Section2

SELECT g.game_name, p.platform_name, gplat.release_year, pub.publisher_name, SUM(rs.num_sales) as global_sales
FROM game g
JOIN game_publisher gp ON g.id = gp.game_id
JOIN publisher pub ON gp.publisher_id = pub.id
JOIN game_platform gplat ON gp.id = gplat.game_publisher_id
JOIN platform p ON gplat.platform_id = p.id
JOIN region_sales rs ON gplat.id = rs.game_platform_id
GROUP BY g.game_name, p.platform_name, gplat.release_year, pub.publisher_name
ORDER BY global_sales DESC
LIMIT 20;

-- Section3

SELECT g.game_name, COUNT(DISTINCT gplat.platform_id) AS platform_count
FROM game g
JOIN game_publisher gp ON g.id = gp.game_id
JOIN game_platform gplat ON gp.id = gplat.game_publisher_id
JOIN platform p ON gplat.platform_id = p.id
GROUP BY g.game_name
HAVING platform_count > 5
ORDER BY platform_count DESC, g.game_name ASC;

-- Section4

SELECT p.platform_name AS platform, g.genre_name AS genre,
DENSE_RANK() OVER(PARTITION BY p.platform_name ORDER BY SUM(rs.num_sales) DESC) as genre_in_platform_rank,
SUM(rs.num_sales) as genre_sale,
DENSE_RANK() OVER(ORDER BY SUM(rs.num_sales) DESC, p.platform_name ASC, g.genre_name ASC) as total_rank
FROM genre g
JOIN game ga ON g.id = ga.genre_id
JOIN game_platform gp ON ga.id = gp.id
JOIN platform p ON gp.platform_id = p.id
JOIN region_sales rs ON gp.id = rs.game_platform_id
GROUP BY g.genre_name, p.platform_name
ORDER BY genre_sale DESC, platform, genre;

-- Section5

SELECT g.game_name as game_name, r.region_name as region_name, SUM(rs.num_sales) as total_sales,
DENSE_RANK() OVER (PARTITION BY r.region_name ORDER BY SUM(rs.num_sales) DESC, g.game_name ASC ) as rank_in_region
FROM game g
JOIN game_platform gp ON g.id = gp.id
JOIN platform p ON p.id = gp.platform_id
JOIN region_sales rs ON gp.id = rs.game_platform_id
JOIN region r ON rs.region_id = r.id
GROUP BY g.game_name, r.region_name
ORDER BY region_name ASC , total_sales DESC, rank_in_region ASC ;

-- Section6

SELECT g.game_name, GROUP_CONCAT(p.publisher_name ORDER BY p.publisher_name ASC SEPARATOR ',') AS publishers
FROM game_publisher gp
JOIN publisher p ON gp.publisher_id = p.id
JOIN game g ON gp.game_id = g.id
GROUP BY g.id HAVING COUNT(DISTINCT p.publisher_name) > 1
ORDER BY g.game_name ASC;