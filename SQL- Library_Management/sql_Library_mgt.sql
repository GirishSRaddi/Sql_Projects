CREATE DATABASE library_db;
USE library_db;

CREATE TABLE IF NOT EXISTS branch 
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);

CREATE TABLE IF NOT EXISTS members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

CREATE TABLE IF NOT EXISTS books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);

CREATE TABLE IF NOT EXISTS return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

INSERT INTO branch(branch_id, manager_id, branch_address, contact_no) 
VALUES
('B001', 'E109', '123 Main St', '+919099988676'),
('B002', 'E109', '456 Elm St', '+919099988677'),
('B003', 'E109', '789 Oak St', '+919099988678'),
('B004', 'E110', '567 Pine St', '+919099988679'),
('B005', 'E110', '890 Maple St', '+919099988680');

SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM members;
SELECT * FROM books;
SELECT * FROM issued_status;
SELECT * FROM return_status;

INSERT INTO issued_status
(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 24 DAY, '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 13 DAY, '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL 7 DAY,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL 32 DAY, '978-0-375-50167-0', 'E101');



-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"--

INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '129 Cherry St'
WHERE member_id ='C119';


-- Task 3: Delete a Record from the Issued Status Table 

SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.--

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
    e.emp_id AS issued_emp_id,
    e.emp_name
FROM employees e
WHERE e.emp_id IN (
    SELECT issued_emp_id
    FROM issued_status
    GROUP BY issued_emp_id
    HAVING COUNT(*) > 1
);


-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt >=2 **

CREATE TABLE book_counts
AS    
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM
book_counts
where no_issued>=2;

-- or we can use below query for same task
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS no_issued
FROM books b
JOIN issued_status ist
    ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title
HAVING COUNT(ist.issued_id) >= 2;


-- Task 7. Retrieve All Books in a Specific Category:
select category, book_title as Title 
from books
WHERE category ='fiction';

/*
-- Retrieve a book from each category
SELECT category, MIN(book_title) AS Title
FROM books
GROUP BY category;


-- count no of books in category
SELECT category, COUNT(category) as Total_Books
FROM books
GROUP BY category
ORDER BY 2 DESC;
*/

-- Task 8: Find Total Rental Income by Category:

SELECT b.category,SUM(b.rental_price),COUNT(*)
FROM books as b
JOIN issued_status as ist 
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9: List Members Who Registered in the Last 180 Days:

SELECT * 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 day;   

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C123', 'Lucas', '120 Main St', '2026-01-01'),
('C124', 'Dustin', '114 Bell St', '2026-01-01'),
('C125', 'Nancy', '112 Crc St', '2026-01-03');

-- task 10 List Employees with Their Branch Manager's Name and their branch details:

SELECT e1.*,b.manager_id,e2.emp_name as manager
FROM employees as e1
JOIN branch as b
ON b.branch_id = e1.branch_id
JOIN employees as e2
ON b.manager_id = e2.emp_id;

-- Task 11. Create a CTE of Books with Rental Price Above a Certain Threshold 7USD:

WITH books_price_greater_than_seven AS (
    SELECT *
    FROM books
    WHERE rental_price > 7
)
SELECT *
FROM books_price_greater_than_seven;


-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

SELECT current_date();

SELECT ist.issued_member_id, m.member_name,bk.book_title,ist.issued_date,
CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN members as m  ON m.member_id = ist.issued_member_id
JOIN books as bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;


-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

select *
from return_status
where issued_id IN ('IS112', 'IS117', 'IS118');

SET SQL_SAFE_UPDATES = 0;

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id IN ('IS112', 'IS117', 'IS118');

DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END$$

DELIMITER ;

CALL add_return_records('RS138', 'IS135', 'Good');


-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.


CREATE TABLE branch_reports AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
JOIN books AS bk
    ON ist.issued_book_isbn = bk.isbn
GROUP BY 
    b.branch_id,
    b.manager_id;

SELECT * FROM branch_reports;



-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.

CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL 2 MONTH
);

SELECT * FROM active_members;


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT
    e.emp_name,
    b.*,
    t.no_book_issued
FROM employees e
JOIN branch b
    ON e.branch_id = b.branch_id
JOIN (
    SELECT
        issued_emp_id,
        COUNT(issued_id) AS no_book_issued
    FROM issued_status
    GROUP BY issued_emp_id
) t
    ON e.emp_id = t.issued_emp_id;



-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

SELECT 
    m.member_name,
    b.book_title,
    COUNT(*) AS damaged_issue_count
FROM issued_status i
JOIN members m
    ON i.issued_member_id = m.member_id
JOIN books b
    ON i.issued_book_isbn = b.isbn
WHERE b.status = 'damaged'
GROUP BY 
    m.member_name,
    b.book_title
HAVING COUNT(*) > 2;



/*
Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.
*/


DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    -- variable declaration
    DECLARE v_status VARCHAR(10);

    -- check book availability
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status (
            issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            CURDATE(),
            p_issued_book_isbn,
            p_issued_emp_id
        );

        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT(
            'Book records added successfully for book isbn : ',
            p_issued_book_isbn
        ) AS message;

    ELSE
        SELECT CONCAT(
            'Sorry to inform you the book you have requested is unavailable book_isbn: ',
            p_issued_book_isbn
        ) AS message;
    END IF;

END$$

DELIMITER ;


SELECT * FROM books;
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * 
FROM books
WHERE isbn = '978-0-375-41398-8';



-- Task 20: Create Table As Select (CTAS)
-- Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.


CREATE TABLE overdue_books_fines AS
SELECT
    i.issued_id,
    m.member_id,
    m.member_name,
    b.isbn,
    b.book_title,
    i.issued_date,
    r.return_date,
    DATEDIFF(
        COALESCE(r.return_date, CURDATE()),
        i.issued_date
    ) - 14 AS overdue_days,
    GREATEST(
        (DATEDIFF(
            COALESCE(r.return_date, CURDATE()),
            i.issued_date
        ) - 14) * 5,
        0
    ) AS fine_amount
FROM issued_status i
LEFT JOIN return_status r
    ON i.issued_id = r.issued_id
JOIN members m
    ON i.issued_member_id = m.member_id
JOIN books b
    ON i.issued_book_isbn = b.isbn
WHERE
    DATEDIFF(
        COALESCE(r.return_date, CURDATE()),
        i.issued_date
    ) > 14;
    
SELECT * FROM overdue_books_fines;


