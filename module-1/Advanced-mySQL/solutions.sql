#Advance per title (1 line per title)

CREATE TEMPORARY TABLE Table_Advance_Per_Title
SELECT
    titleauthor.au_id AS author_id,
    titleauthor.title_id AS title_id,
    titles.advance * titleauthor.royaltyper / 100 AS advance_per_title
FROM titleauthor
INNER JOIN titles ON titleauthor.title_id = titles.title_id
ORDER BY author_id;

#Royalty per title (several lines per title)
    
CREATE TEMPORARY TABLE Table_Royalty_Per_Title
SELECT
    titleauthor.au_id AS author_id,
    titleauthor.title_id AS title_id,
    titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100 AS royalty_per_title
FROM titleauthor
INNER JOIN titles ON titleauthor.title_id = titles.title_id
INNER JOIN sales ON titles.title_id = sales.title_id
ORDER BY author_id;

#Royalty per title - Aggregated (1 line per title)
    
CREATE TEMPORARY TABLE Table_Royalty_Per_Title_Aggregated
SELECT
    author_id,
    title_id,
    SUM(royalty_per_title) AS agregated_royalty_per_title
FROM Table_Royalty_Per_Title
GROUP BY author_id, title_id;

#Profit per author

SELECT
    t1.author_id,
    ROUND(SUM(t1.advance_per_title) + SUM(t2.agregated_royalty_per_title),2) AS author_profit
FROM Table_Advance_Per_Title AS t1
INNER JOIN Table_Royalty_Per_Title_Aggregated AS t2 ON t1.author_id = t2.author_id
GROUP BY t1.author_id
ORDER BY author_profit DESC
LIMIT 3;
