<h1>Data Wrangling, Analysis e AB Testing com SQL</h1>

<h2>Peer-graded Assignment: AB Testing</h2>


### 1. First, we start with a simple query of the final_assignments_qa table, to identify its columns and see which ones can be used for comparison:

```sql
SELECT * 
FROM dsv1069.final_assignments_qa;
```
Obtaining the following result:
![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/d6511d5a-48e9-4d25-be46-7d5daf20bc33)
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
  ![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/e4a21188-392d-416e-9f90-bf04927bf1e9)

### 3. Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2 (You may include the day the test started):

```sql
SELECT test_assignment,
       COUNT(DISTINCT item_id) AS number_of_items,
       SUM(order_binary) AS items_ordered_30d
FROM
  (SELECT item_test_2.item_id,
          item_test_2.test_assignment,
          item_test_2.test_number,
          item_test_2.test_start_date,
          item_test_2.created_at,
          MAX(CASE
                  WHEN (created_at > test_start_date
                        AND DATE_PART('day', created_at - test_start_date) <= 30) THEN 1
                  ELSE 0
              END) AS order_binary
   FROM
     (SELECT final_assignments.*,
             DATE(orders.created_at) AS created_at
      FROM dsv1069.final_assignments AS final_assignments
      LEFT JOIN dsv1069.orders AS orders
        ON final_assignments.item_id = orders.item_id
        WHERE test_number = 'item_test_2') AS item_test_2
   GROUP BY item_test_2.item_id,
            item_test_2.test_assignment,
            item_test_2.test_number,
            item_test_2.test_start_date,
            item_test_2.created_at) AS order_binary
GROUP BY test_assignment;
```
 Obtaining the following result:
 ![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/9df6e977-87c5-41de-b271-b89285a9c35e)

 ### 4. Use the final_assignments table to calculate the view binary, and average views for the 30 day window after the test assignment for item_test_2. (You may include the day the test started):
```sql
SELECT item_test_2.item_id,
       item_test_2.test_assignment,
       item_test_2.test_number,
       MAX(CASE
               WHEN (view_date > test_start_date
                     AND DATE_PART('day', view_date - test_start_date) <= 30) THEN 1
               ELSE 0
           END) AS view_binary
FROM
  (SELECT final_assignments.*,
          DATE(events.event_time) AS view_date
   FROM dsv1069.final_assignments AS final_assignments
   LEFT JOIN
       (SELECT event_time,
               CASE
                   WHEN parameter_name = 'item_id' THEN CAST(parameter_value AS NUMERIC)
                   ELSE NULL
               END AS item_id
      FROM dsv1069.events
      WHERE event_name = 'view_item') AS events
     ON final_assignments.item_id = events.item_id
   WHERE test_number = 'item_test_2') AS item_test_2
GROUP BY item_test_2.item_id,
         item_test_2.test_assignment,
         item_test_2.test_number
LIMIT 100;
```
Obtaining the following result:
![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/24a1d7e8-c497-4a6f-9efd-2941f47681d5)

### 5. Use the [ABBA - AB Testings Statistics](https://thumbtack.github.io/abba/demo/abba.html) to compute the lifts in metrics and the p-values for the binary metrics (30 day order binary and 30 day view binary) using a interval 95% confidence. To do this, let's create the query to obtain the data:
```sql
SELECT test_assignment,
       test_number,
       COUNT(DISTINCT item) AS number_of_items,
       SUM(view_binary_30d) AS view_binary_30d
FROM
  (SELECT final_assignments.item_id AS item,
          test_assignment,
          test_number,
          test_start_date,
          MAX((CASE
                   WHEN date(event_time) - date(test_start_date) BETWEEN 0 AND 30 THEN 1
                   ELSE 0
               END)) AS view_binary_30d
   FROM dsv1069.final_assignments
   LEFT JOIN dsv1069.view_item_events
     ON final_assignments.item_id = view_item_events.item_id
   WHERE test_number = 'item_test_2'
   GROUP BY final_assignments.item_id,
            test_assignment,
            test_number,
            test_start_date) AS view_binary
GROUP BY test_assignment,
         test_number,
         test_start_date;
```
Obtaining the following result:
![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/3df9ab5a-834c-42ee-a04e-0f2bc64cc012)
![image](https://github.com/jubssoares/ab-testing-coursera/assets/104150753/312d8d1b-cd32-441b-8359-d4d981ce54d2)

**View Binary:** We can say with 95% confidence that the lift value is 2% and the p_value is 0.2. There is not a significant difference in the number of views within 30days of the assigned treatment date between the two treatments.

**Order binary:** There is no detectable change in this metric. The p-value is 0.86 meaning that there is a no significant difference in the number of orders within 30days of the assigned treatment date between the two treatments.

### 6. Use Mode’s Report builder feature to write up the test. Your write-up should include a title, a graph for each of the two binary metrics you’ve calculated. The lift and p-value (from the AB test calculator) for each of the two metrics, and a complete sentence to interpret the significance of each of the results.

I didn't understand how to do it.


