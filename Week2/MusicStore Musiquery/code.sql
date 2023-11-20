
-- Section1

WITH Customer_Artist AS (
    SELECT DISTINCT i.CustomerId, a.ArtistId
    FROM Invoice i
    join InvoiceLine il on i.InvoiceId = il.InvoiceId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Album a ON t.AlbumId = a.AlbumId
    JOIN Artist ar ON a.ArtistId = ar.ArtistId
    GROUP BY i.CustomerId, a.ArtistId
)
, Artist_Combinations AS (
    SELECT DISTINCT ar1.Name as artist_A, ar2.Name as artist_B, c1.CustomerId
    FROM Customer_Artist c1
    JOIN Customer_Artist c2 ON c1.CustomerId = c2.CustomerId
    JOIN Artist ar1 ON c1.ArtistId = ar1.ArtistId
    JOIN Artist ar2 ON c2.ArtistId = ar2.ArtistId
    WHERE ar1.Name < ar2.Name
)
SELECT artist_A, artist_B, COUNT(*) AS num_occurrences
FROM Artist_Combinations
GROUP BY artist_A, artist_B
ORDER BY num_occurrences DESC, artist_A, artist_B
LIMIT 200;

-- Section2

WITH customer_spend AS (
  SELECT
    c.FirstName,
    c.LastName,
    SUM(il.UnitPrice * il.Quantity) AS total_spent,
    RANK() OVER (ORDER BY SUM(il.UnitPrice * il.Quantity) DESC) as spend_rank,
    COUNT(*) OVER () AS total_customers
  FROM
    Customer c
  JOIN
    Invoice i ON c.CustomerId = i.CustomerId
  JOIN
    InvoiceLine il ON i.InvoiceId = il.InvoiceId
  WHERE
    i.InvoiceDate >= '2010-01-01'
  GROUP BY
    c.CustomerId, c.FirstName, c.LastName
)
SELECT
  FirstName,
  LastName,
  total_spent,
  CASE
    WHEN spend_rank <= total_customers * 0.3 THEN 'top'
    WHEN spend_rank > total_customers * 0.7 THEN 'low'
    ELSE 'middle'
  END AS customer_level
FROM
  customer_spend
ORDER BY
  total_spent DESC,
  LastName ASC;