CREATE TABLE marketing_data (
    customer_id INTEGER PRIMARY KEY,
    birth_year INTEGER,
    age INTEGER,
    education VARCHAR(50),
    marital_status VARCHAR(20),
    income NUMERIC(10, 2),
    kid_home SMALLINT,
    teen_home SMALLINT,
    dt_customer DATE,
    recency INTEGER,
    liquor_spent NUMERIC(10, 2),
    veg_spent NUMERIC(10, 2),
    meat_spent NUMERIC(10, 2),
    fish_spent NUMERIC(10, 2),
    choc_spent NUMERIC(10, 2),
    commodt_spent NUMERIC(10, 2),
    total_spent NUMERIC(10, 2),
    num_deals SMALLINT,
    num_web_buy SMALLINT,
    num_shop_buy SMALLINT,
    num_web_visit SMALLINT,
    camp_offer INTEGER,
    complain INTEGER,
    country VARCHAR(30)
);

CREATE TABLE ad_data (
    customer_id INTEGER PRIMARY KEY,
    bulkmail_ad INTEGER,
    twitter_ad INTEGER,
    instagram_ad INTEGER,
    facebook_ad INTEGER,
    brochure_ad INTEGER
);




-------Part 1 -----

---the total spend per country?

SELECT country, SUM(total_spent) AS total_spending
FROM marketing_data
GROUP BY country
ORDER BY total_spending DESC;

---the total spend per product per country

SELECT country, 
       SUM(liquor_spent) AS total_liquor,
       SUM (veg_spent) AS total_vegetable,
       SUM (meat_spent) AS total_meat,
       SUM (fish_spent) AS total_fish,
       SUM (choc_spent) AS total_chocolate,
       SUM (commodt_spent) AS total_commodities,
	   SUM (total_spent) AS total_spending
FROM marketing_data
GROUP BY country
ORDER BY total_spending DESC;


---which products are the most popular in each country ___

/*outcome is the same?*/


WITH product_spend AS (
    SELECT country,
           'liquor' AS product, SUM(liquor_spent) AS total_spent
    FROM marketing_data
    GROUP BY country
    UNION ALL
    SELECT country,
           'vegetable' AS product, SUM(veg_spent) AS total_spent
    FROM marketing_data
    GROUP BY country
    UNION ALL
    SELECT country,
           'meat' AS product, SUM(meat_spent) AS total_spent
    FROM marketing_data
    GROUP BY country
    UNION ALL
    SELECT country,
           'fish' AS product, SUM(fish_spent) AS total_spent
    FROM marketing_data
    GROUP BY country
    UNION ALL
    SELECT country,
           'chocolate' AS product, SUM(choc_spent) AS total_spent
    FROM marketing_data
    GROUP BY country
    UNION ALL
    SELECT country,
           'commodities' AS product, SUM(commodt_spent) AS total_spent
    FROM marketing_data
    GROUP BY country
)
SELECT country, product, total_spent
FROM (
    SELECT country, product, total_spent,
           ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_spent DESC) AS rank
    FROM product_spend
) ranked_products
ORDER BY product;


---which products are the most popular based on marital status

SELECT marital_status, 
       SUM(liquor_spent) AS total_liquor,
       SUM (veg_spent) AS total_vegetable,
       SUM (meat_spent) AS total_meat,
       SUM (fish_spent) AS total_fish,
       SUM (choc_spent) AS total_chocolate,
       SUM (commodt_spent) AS total_commodities,
	   SUM (total_spent) AS total_spending
FROM marketing_data
GROUP BY marital_status
ORDER BY total_spending DESC;



---which products are the most popular based on whether or not there are children or teens in the home.

SELECT 
    CASE 
        WHEN kid_home > 0 OR teen_home > 0 THEN 'With Children/Teens'
        ELSE 'Without Children/Teens'
    END AS home_status,
    SUM(liquor_spent) AS total_liquor,
    SUM(veg_spent) AS total_vegetable,
    SUM(meat_spent) AS total_meat,
    SUM(fish_spent) AS total_fish,
    SUM(choc_spent) AS total_chocolate,
    SUM(commodt_spent) AS total_commodities,
    SUM(total_spent) AS total_spending
FROM marketing_data
GROUP BY home_status
ORDER BY total_spending DESC;


---Part 2 ---


---Which social media platform (Twitter, Instagram, or Facebook) is the most effective method of advertising in each country? 
--**--(In this case, consider the total number of lead conversions as a measure of effectiveness).


SELECT 
    SUM(bulkmail_ad) AS total_bulkmail_conversions,
    SUM(twitter_ad) AS total_twitter_conversions,
    SUM(instagram_ad) AS total_instagram_conversions,
    SUM(facebook_ad) AS total_facebook_conversions,
    SUM(brochure_ad) AS total_brochure_conversions,
    SUM(bulkmail_ad + twitter_ad + instagram_ad + facebook_ad + brochure_ad) AS total_conversions,
    COUNT(DISTINCT customer_id) AS total_unique_customers
FROM ad_data;
----
SELECT 
    md.country,
    CASE 
        WHEN GREATEST(SUM(ad.twitter_ad), SUM(ad.instagram_ad), SUM(ad.facebook_ad)) = SUM(ad.twitter_ad) THEN 'Twitter'
        WHEN GREATEST(SUM(ad.twitter_ad), SUM(ad.instagram_ad), SUM(ad.facebook_ad)) = SUM(ad.instagram_ad) THEN 'Instagram'
        WHEN GREATEST(SUM(ad.twitter_ad), SUM(ad.instagram_ad), SUM(ad.facebook_ad)) = SUM(ad.facebook_ad) THEN 'Facebook'
    END AS most_effective_platform,
    GREATEST(SUM(ad.twitter_ad), SUM(ad.instagram_ad), SUM(ad.facebook_ad)) AS max_conversions
FROM marketing_data md
JOIN ad_data ad ON md.customer_id = ad.customer_id
GROUP BY md.country 
ORDER BY max_conversions DESC ;



----Which social media platform is the most effective method of advertising based on marital status? 
--**--(In this case, consider the total number of lead conversions as a measure of effectiveness)
--

SELECT 
    md.marital_status,
    CASE 
        WHEN GREATEST(SUM(ad.twitter_ad), SUM(ad.instagram_ad), SUM(ad.facebook_ad)) = SUM(ad.twitter_ad) THEN 'Twitter'
        WHEN GREATEST(SUM(ad.twitter_ad), SUM(ad.instagram_ad), SUM(ad.facebook_ad)) = SUM(ad.instagram_ad) THEN 'Instagram'
        WHEN GREATEST(SUM(ad.twitter_ad), SUM(ad.instagram_ad), SUM(ad.facebook_ad)) = SUM(ad.facebook_ad) THEN 'Facebook'
    END AS most_effective_platform,
    GREATEST(SUM(ad.twitter_ad), SUM(ad.instagram_ad), SUM(ad.facebook_ad)) AS max_conversions
FROM marketing_data md
JOIN ad_data ad
USING (customer_id)
GROUP BY md.marital_status
ORDER BY max_conversions DESC;


-----Which social media platform(s) seem(s) to be the most effective per country? 
--***(In this case, assume that purchases were in some way influenced by lead conversions from a campaign). 
--**--Hint: You’ll want to generate the amount spent per product type per country and include a total of the ads for each of the social media platforms. 
--**--Then, review the output to determine whether there is anything interesting related to the amount spent per product in each country and which social media platforms were used for advertising.


WITH product_spending AS (
    SELECT 
        md.country,
        SUM(md.liquor_spent) AS total_liquor_spent,
        SUM(md.veg_spent) AS total_veg_spent,
        SUM(md.meat_spent) AS total_meat_spent,
        SUM(md.fish_spent) AS total_fish_spent,
        SUM(md.choc_spent) AS total_choc_spent,
        SUM(md.commodt_spent) AS total_commodt_spent,
        SUM(md.total_spent) AS total_spent
    FROM marketing_data md
    GROUP BY md.country
),
social_media_conversions AS (
    SELECT 
        md.country,
        SUM(ad.twitter_ad) AS total_twitter_conversions,
        SUM(ad.instagram_ad) AS total_instagram_conversions,
        SUM(ad.facebook_ad) AS total_facebook_conversions
    FROM marketing_data md
    JOIN ad_data ad ON md.customer_id = ad.customer_id
    GROUP BY md.country
)
SELECT 
    ps.country,
    ps.total_liquor_spent,
    ps.total_veg_spent,
    ps.total_meat_spent,
    ps.total_fish_spent,
    ps.total_choc_spent,
    ps.total_commodt_spent,
    ps.total_spent,
    smc.total_twitter_conversions,
    smc.total_instagram_conversions,
    smc.total_facebook_conversions,
    CASE 
        WHEN GREATEST(smc.total_twitter_conversions, smc.total_instagram_conversions, smc.total_facebook_conversions) = smc.total_twitter_conversions THEN 'Twitter'
        WHEN GREATEST(smc.total_twitter_conversions, smc.total_instagram_conversions, smc.total_facebook_conversions) = smc.total_instagram_conversions THEN 'Instagram'
        WHEN GREATEST(smc.total_twitter_conversions, smc.total_instagram_conversions, smc.total_facebook_conversions) = smc.total_facebook_conversions THEN 'Facebook'
    END AS most_effective_platform
FROM product_spending ps
JOIN social_media_conversions smc ON ps.country = smc.country
ORDER BY ps.total_spent DESC;


---RFM ANALYSIS 


--RECENCY ---

SELECT customer_id, recency
FROM marketing_data;

--FREQUENCY--

SELECT customer_id, 
       (num_deals + num_web_buy + num_shop_buy) AS frequency
FROM marketing_data;


--Monetary--


SELECT customer_id, total_spent AS monetary
FROM marketing_data;


-- RFM SCORE

CREATE TABLE rfm_scores AS
SELECT m.customer_id, 
       m.recency, 
       (m.num_deals + m.num_web_buy + m.num_shop_buy) AS frequency,
       m.total_spent AS monetary
FROM marketing_data m;


--RFM


1)--ranked data table --


CREATE TABLE ranked_data (
    customer_id INT,
    recency INT,
    frequency INT,
    monetary INT,
    recency_score INT,
    frequency_score INT,
    monetary_score INT
);

2)--data insert into ranked data (like excel)


INSERT INTO ranked_data (customer_id ,recency, frequency, monetary, recency_score, frequency_score, monetary_score)
SELECT customer_id ,recency, frequency, monetary,
    NTILE(5) OVER (ORDER BY recency ASC) AS recency_score,
    NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
    NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score
FROM rfm_scores;



3)--segmented table (1 to 5?)--

CREATE TABLE segmented_data (
    customer_id INT,
    recency INT,
    frequency INT,
    monetary INT,
    recency_score INT,
    frequency_score INT,
    monetary_score INT,
    rfm_score INT,
    segment VARCHAR(50)
);

-----old code----segmenting (1 to 5?)--

INSERT INTO segmented_data (customer_id, recency, frequency, monetary, recency_score, frequency_score, monetary_score, rfm_score, segment)
SELECT 
    customer_id, 
	recency, 
	frequency, 
	monetary, 
	recency_score, 
	frequency_score, 
	monetary_score,
    (recency_score * 100) + (frequency_score * 10) + monetary_score AS rfm_score,
    CASE
        WHEN recency_score = 5 AND frequency_score = 5 AND monetary_score = 5 THEN 'Champions'
        WHEN frequency_score >= 4 THEN 'Loyal Customers'
        WHEN monetary_score >= 4 THEN 'Big Spenders'
        WHEN recency_score >= 4 THEN 'Almost Lost'
        WHEN recency_score = 1 THEN 'Lost Customers'
        ELSE 'Other'
    END AS segment
FROM ranked_data;


-- latest_



INSERT INTO segmented_data (customer_id, recency, frequency, monetary, recency_score, frequency_score, monetary_score, rfm_score, segment)
SELECT 
    customer_id, 
    recency, 
    frequency, 
    monetary, 
    recency_score, 
    frequency_score, 
    monetary_score,
    (recency_score * 100) + (frequency_score * 10) + monetary_score AS rfm_score,
    CASE
        WHEN recency_score = 5 AND frequency_score = 5 AND monetary_score = 5 THEN 'Champions'
        WHEN recency_score = 5 AND frequency_score >= 3 THEN 'New Customers'
        WHEN frequency_score >= 4 AND monetary_score >= 4 THEN 'Loyal Customers'
        WHEN monetary_score >= 4 THEN 'Big Spenders'
        WHEN recency_score >= 4 AND frequency_score >= 3 THEN 'Potential Loyalists'
        WHEN recency_score >= 4 THEN 'Almost Lost'
        WHEN recency_score = 1 THEN 'Lost Customers'
        WHEN recency_score >= 2 AND recency_score <= 3 AND frequency_score <= 3 AND monetary_score <= 3 THEN 'Need Attention'
        WHEN recency_score >= 2 AND recency_score <= 3 AND frequency_score = 1 AND monetary_score <= 2 THEN 'About to Sleep'
        WHEN recency_score = 1 AND frequency_score = 1 AND monetary_score <= 2 THEN 'Hibernating'
        WHEN recency_score <= 2 AND frequency_score >= 2 AND monetary_score >= 2 THEN 'At Risk'
        ELSE 'Other'
    END AS segment
FROM ranked_data;


