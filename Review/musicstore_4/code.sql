
-- Section1

WITH ClassicalPlaylistSales AS (
  SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS customer_name,
    COUNT(distinct t.TrackId) AS num_purchases,
    CONCAT('@', SUBSTRING_INDEX(c.Email, '@', 1)) AS account
  FROM
    Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
    JOIN track t ON il.TrackId = t.TrackId
    JOIN PlaylistTrack pt ON il.TrackId = pt.TrackId
    JOIN Playlist p ON pt.PlaylistId = p.PlaylistId
  WHERE
    p.Name LIKE '%Classical%'
  GROUP BY
    c.CustomerId
),
RankedClassicalPlaylistSales AS (
  SELECT
    customer_name,
    DENSE_RANK() OVER (ORDER BY num_purchases DESC) AS ranks,
    account
  FROM
    ClassicalPlaylistSales
  WHERE
    num_purchases >= 2
)
SELECT
  customer_name,
  ranks as `Rank`,
  account
FROM
  RankedClassicalPlaylistSales
ORDER BY
  customer_name;

-- Section2

WITH Sales AS (
  SELECT
    CASE
      WHEN g.Name IN ('Easy Listening', 'Science Fiction', 'TV Shows', 'Sci Fi & Fantasy', 'Drama', 'Comedy') THEN 'Podcast'
      ELSE g.Name
    END AS genre,
    SUM(il.Quantity) AS total_sales,
    SUM(t.Milliseconds ) AS total_minutes
  FROM
    Invoice i
  JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
  JOIN Track t ON il.TrackId = t.TrackId
  JOIN Genre g ON t.GenreId = g.GenreId
  WHERE
    i.InvoiceDate BETWEEN '2010-01-01' AND '2012-12-31'
    AND i.BillingCountry NOT IN ('USA', 'Canada')
  GROUP BY
    CASE
      WHEN g.Name IN ('Easy Listening', 'Science Fiction', 'TV Shows', 'Sci Fi & Fantasy', 'Drama', 'Comedy') THEN 'Podcast'
      ELSE g.Name
    END
),
SalesWithListeningMultiplier AS (
  SELECT
    genre,
    total_sales,
    CASE
      WHEN genre = 'Podcast' THEN total_minutes * 1.5
      WHEN genre IN ('Opera', 'Classical') THEN total_minutes * 22
      ELSE total_minutes * 55
    END AS total_listening_minutes
  FROM
    Sales
)
SELECT
  genre,
  ROUND(total_listening_minutes/60000, 2) AS `total (min)`,
  total_sales
FROM SalesWithListeningMultiplier
ORDER BY total_listening_minutes DESC;