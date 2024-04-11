<h1>Data Wrangling, Analysis e AB Testing com SQL</h1>

<h2>Peer-graded Assignment: AB Testing</h2>


### 1. First, we start with a simple query of the final_assignments_qa table, to identify its columns and see which ones can be used for comparison:

```sql
SELECT * 
FROM dsv1069.final_assignments_qa;
```
Obtaining the following result:

![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/aca561a5-f9b0-44d4-b122-6e34a8175591)


Therefore, we can conclude that it is not, as the created_at data is necessary.

### 2. A query and table creation statement to make final_assignments_qa look like the final_assignments table:
   ```sql
    SELECT item_id,
     test_a      AS test_assignment, 
    'test_a'     AS test_number, 
    '2020-01-01' AS test_start_date
    FROM 
      dsv1069.final_assignments_qa;
   ```
  Obtaining the following result:

  ![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/54e5b658-2b5c-4857-a052-990f18c47318)


### 3. Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2 (You may include the day the test started):

```sql
SELECT
  test_assignment,
  COUNT(item_id) as items,
  SUM(order_binary_30d) AS ordered_items_30d
FROM
(
  SELECT 
   fa.test_assignment,
   fa.item_id, 
   MAX(CASE WHEN orders.created_at > fa.test_start_date THEN 1 ELSE 0 END)  AS order_binary_30d
  FROM 
    dsv1069.final_assignments fa
    
  LEFT OUTER JOIN
    dsv1069.orders
  ON 
    fa.item_id = orders.item_id 
  AND 
    orders.created_at >= fa.test_start_date
  AND 
    DATE_PART('day', orders.created_at - fa.test_start_date ) <= 30
  WHERE 
    fa.test_number= 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
) item_level
GROUP BY test_assignment;
```
 Obtaining the following result:
![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/abb9806b-a324-426b-a738-9d2c4001715c)


 ### 4. Use the final_assignments table to calculate the view binary, and average views for the 30 day window after the test assignment for item_test_2. (You may include the day the test started):
```sql
SELECT
test_assignment,
COUNT(item_id) AS items,
SUM(view_binary_30d) AS viewed_items,
CAST(100*SUM(view_binary_30d)/COUNT(item_id) AS FLOAT) AS viewed_percent,
SUM(views) AS views,
SUM(views)/COUNT(item_id) AS average_views_per_item
FROM 
(
 SELECT 
   fa.test_assignment,
   fa.item_id, 
   MAX(CASE WHEN views.event_time > fa.test_start_date THEN 1 ELSE 0 END)  AS view_binary_30d,
   COUNT(views.event_id) AS views
  FROM 
    dsv1069.final_assignments fa
    
  LEFT OUTER JOIN 
    (
    SELECT 
      event_time,
      event_id,
      CAST(parameter_value AS INT) AS item_id
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    AND 
      parameter_name = 'item_id'
    ) views
  ON 
    fa.item_id = views.item_id
  AND 
    views.event_time >= fa.test_start_date
  AND 
    DATE_PART('day', views.event_time - fa.test_start_date ) <= 30
  WHERE 
    fa.test_number= 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
) item_level
GROUP BY 
 test_assignment;
```
Obtaining the following result:

![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/26879016-3780-4dc2-992a-09b846835b54)


### 5. Use the [ABBA - AB Testings Statistics](https://thumbtack.github.io/abba/demo/abba.html) to compute the lifts in metrics and the p-values for the binary metrics (30 day order binary and 30 day view binary) using a interval 95% confidence. To do this, let's create the query to obtain the data:
```sql
SELECT
test_assignment,
COUNT(item_id) AS items,
SUM(view_binary_30d) AS viewed_items
FROM 
(
 SELECT 
   fa.test_assignment,
   fa.item_id, 
   MAX(CASE WHEN views.event_time > fa.test_start_date THEN 1 ELSE 0 END)  AS view_binary_30d
  FROM 
    dsv1069.final_assignments fa
    
  LEFT OUTER JOIN 
    (
    SELECT 
      event_time, 
      CAST(parameter_value AS INT) AS item_id
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    AND 
      parameter_name = 'item_id'
    ) views
  ON 
    fa.item_id = views.item_id
  AND 
    views.event_time >= fa.test_start_date
  AND 
    DATE_PART('day', views.event_time - fa.test_start_date ) <= 30
  WHERE 
    fa.test_number= 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
) item_level
GROUP BY 
 test_assignment;
```
Obtaining the following result:

![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/50366c1d-4ec9-480f-8d0d-e9040345286e)

### 6. Use Mode’s Report builder feature to write up the test. Your write-up should include a title, a graph for each of the two binary metrics you’ve calculated. The lift and p-value (from the AB test calculator) for each of the two metrics, and a complete sentence to interpret the significance of each of the results.

I didn't understand how to do it.


