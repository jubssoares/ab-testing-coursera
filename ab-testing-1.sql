-- Compare the final_assignments_qa table to the assignment events we captured for user_level_testing. Write an answer to the following question: Does this table have everything you need to compute metrics like 30-day view-binary?

-- First, we start with a simple query of the final_assignments_qa table, to identify its columns and see which ones can be used for comparison:

SELECT * 
FROM dsv1069.final_assignments_qa;

-- Therefore, we can conclude that it is not, as the created_at data is necessary.