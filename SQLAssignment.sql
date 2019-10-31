--1.0 Setting up Oracle Chinook
--In this section you will begin the process of working with the Oracle Chinook database
--Task – Open the Chinook_Oracle.sql file and execute the scripts within.
--2.0 SQL Queries
--In this section you will be performing various queries against the Oracle Chinook database.
--2.1 SELECT
--Task – Select all records from the Employee table.
SELECT * FROM employee;

--Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee
WHERE lastname = 'King';

--Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee
WHERE firstname = 'Andrew' AND REPORTSTO IS NULL;

--2.2 ORDER BY
--Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album
ORDER BY title desc;

--Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer
ORDER BY firstname;

--2.3 INSERT INTO
--Task – Insert two new records into Genre table
INSERT INTO genre(genreid, name)
    VALUES( 26, Jazz);
   
INSERT INTO genre(genreid, name)
    VALUES( 27, EDM);

--Task – Insert two new records into Employee table
INSERT INTO employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, 
    postalcode, phone, fax, email)
    VALUES( 9, -- Employee ID
            'Doe', 'John', -- Last & First name
            'IT Staff', 6, -- Job Position and Reportsto ID
            DATE('22-MAR-95', 'DD-MON-YY'), DATE('30-SEP-19', 'DD-MON-YY'), -- DOB and Hire Date
            '1234 Revature Road', 'Reston', 'VA', 'USA', '20170', -- Street, City, State, Country, Postal Code
            '+1 (555) 555-5555', '+1 (555)555-4444', 'john@chinookcorp.com'); -- phone, fax, email

INSERT INTO employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, 
    postalcode, phone, fax, email)
    VALUES( 9, -- Employee ID
            'Parker', 'Jurassica', -- Last & First name
            'IT Staff', 6, -- Job Position and Reportsto ID
            DATE('16-JAN-86', 'DD-MON-YY'), DATE('30-SEP-19', 'DD-MON-YY'), -- DOB and Hire Date
            '100 Tyranosaurus Road', 'Reston', 'VA', 'USA', '20170', -- Street, City, State, Country, Postal Code
            '+1 (555) 555-3333', '+1 (555)555-2222', 'jurassica@chinookcorp.com'); -- phone, fax, email

--Task – Insert two new records into Customer table

INSERT INTO customer(customerid, firstname, lastname, address, city, state, country, postalcode, phone, fax, email,
      supportreid)
    VALUES(60, 'Spy', 'Derman', '8 Legged Lane', 'New York', 'NY', 'USA', '11365', '+1 (347) 888-8888','+1 (347) 888-8889',
          'spyderman@yahoo.com', 4);

INSERT INTO customer(customerid, firstname, lastname, address, city, state, country, postalcode, phone, fax, email,
      supportreid)
    VALUES(61, 'Leeroy', 'Jenkins', '100 Whelps Circle', 'Southington', 'CT', 'USA', '06489', '+1 (860) 555-5555','+1 (860) 5555-5556',
          'leeroyjenkins@wow.com', 4);

--2.4 UPDATE
--Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer
SET firstname = 'Robert', lastname = 'Walter'
WHERE firstname = 'Aaron' AND lastname = 'Mitchell';
COMMIT;
--Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist
SET name = 'CCR'
WHERE name = 'Creedence Clearwater Revival';
COMMIT;
--2.5 LIKE
--Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice
WHERE billingaddress LIKE 'T%';

--2.6 BETWEEN
--Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice
WHERE total BETWEEN 15 AND 50;

--Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM EMPLOYEE
WHERE hiredate BETWEEN '01-JUN-03' AND '01-MAR-04';

--2.7 DELETE
--Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM invoiceline
WHERE invoiceid = (SELECT i.invoiceid FROM invoice WHERE customerid = 
    (SELECT c.customerid FROM customer WHERE lastname = 'Walter' AND firstname = 'Robert'));

DELETE FROM invoice i
WHERE customerid = (SELECT c.customerid FROM customer WHERE lastname = 'Walter' AND firstname = 'Robert');

DELETE FROM customer c
WHERE lastname = 'Walter' AND firstname = 'Robert';
COMMIT;
--
--3.0 SQL Functions
--In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
--3.1 System Defined Functions
--Task – Create a function that returns the current time.
SELECT SYSTIMESTAMP FROM dual;

--Task – create a function that returns the length of a mediatype from the mediatype table
SELECT vsize(mediatypeid) + vsize(name) FROM mediatype;

--3.2 System Defined Aggregate Functions
--Task – Create a function that returns the average total of all invoices
SELECT AVG(total) FROM invoice;

--Task – Create a function that returns the most expensive track
SELECT MAX(unitprice) FROM track;

--3.3 User Defined Scalar Functions
--Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION avg_price
RETURN NUMBER
IS
    average NUMBER(4,2);
BEGIN
    SELECT AVG(unitprice) INTO average FROM invoiceline;
    RETURN average;
END;
/

--Test Code for the function
SELECT avg_price FROM dual;

--3.4 User Defined Table Valued Functions
--Task – Create a function that returns all employees who are born after 1968.
CREATE TYPE e_results 
IS OBJECT
    (employeeid NUMBER, lastname VARCHAR2(20), firstname VARCHAR2(20), title VARCHAR2(30), reportsto number, birthdate DATE,
    hiredate DATE, address VARCHAR2(70), city VARCHAR2(40), state VARCHAR2(40), country VARCHAR2(40), postalcode VARCHAR2(10),
    phone VARCHAR2(24), fax VARCHAR2(24), email VARCHAR2(60));
/

CREATE TYPE e_results_coll IS TABLE OF e_results;
/

CREATE OR REPLACE FUNCTION find_employees
RETURN e_results_coll PIPELINED
IS
BEGIN
    FOR i IN (SELECT * FROM employee
        WHERE birthdate > '31-DEC-68') LOOP
        PIPE ROW(e_results(i.employeeid, i.lastname, i.firstname, i.title, i.reportsto, i.birthdate, i.hiredate, i.address,
            i.city, i.state, i.country, i.postalcode, i.phone, i.fax, i.email));
    END LOOP;
    RETURN;
END;
/

SELECT * FROM TABLE(find_employees);

--4.0 Stored Procedures
-- In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
--4.1 Basic Stored Procedure
--Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE PROCEDURE get_employee_names(
e_cursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN e_cursor FOR
    SELECT lastname, firstname FROM employee;
    
END;    
/

--Test code for 4.1
VARIABLE emp_cursor refcursor;
EXEC get_employee_names(:emp_cursor);
print emp_cursor;    

--4.2 Stored Procedure Input Parameters
--Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE PROCEDURE update_employee
(e_lastname IN varchar2,
e_firstname IN varchar2,
e_address IN varchar2,
e_city IN varchar2,
e_state IN varchar2,
e_country IN varchar2,
e_postalcode IN varchar2,
e_phone IN varchar2,
e_fax IN varchar2,
e_email IN varchar2)
IS
BEGIN
    UPDATE employee
    SET lastname = e_lastname, firstname = e_firstname, address = e_address, city = e_city, state = e_state,
        country = e_country, postalcode = e_postalcode, phone = e_phone, fax = e_fax, email = e_email;
    COMMIT;    
END;
/
--Task – Create a stored procedure that returns the managers of an employee.
--4.3 Stored Procedure Output Parameters
--Task – Create a stored procedure that returns the name and company of a customer.
--6.0 Triggers
--In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
--6.1 AFTER/FOR
--Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE OR REPLACE TRIGGER after_insert_trigger
AFTER INSERT ON employee
FOR EACH ROW
DECLARE
    employees_added NUMBER;
BEGIN
    employees_added := 0;
    IF INSERTING THEN
        SELECT :new.employeeid INTO employees_added FROM dual;
    END IF;
END;
/

--Task – Create an after update trigger on the album table that fires after a row is inserted in the table
    -- Note: Assuming there is a typo and that this is asking for the trigger to occur after a row is updated.
CREATE OR REPLACE TRIGGER after_update_trigger
AFTER UPDATE ON album
FOR EACH ROW
DECLARE
    album_updated NUMBER;
BEGIN
    album_updated := 0;
    IF UPDATING THEN
        SELECT :new.albumid INTO album_updated FROM dual;
    END IF;
END;
/
--Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE OR REPLACE TRIGGER after_delete_trigger
AFTER DELETE ON customer
FOR EACH ROW
DECLARE
    row_deleted NUMBER;
BEGIN
    row_deleted := 0;
    IF DELETING THEN
        SELECT :old.customerid INTO row_deleted FROM dual;
    END IF;
END;
/

--Task – Create a trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE OR REPLACE TRIGGER delete_restriction_trigger
BEFORE DELETE ON invoice
FOR EACH ROW
DECLARE
    total_cost NUMBER;
BEGIN
    total_cost := 0;
    IF DELETING THEN
        SELECT :old.total INTO total_cost FROM invoice WHERE invoiceid = :old.invoiceid;
        IF(total_cost > 50) THEN
           RAISE_APPLICATION_ERROR(-20000, 'Delete not permitted for invoices over 50 dollars');
        END IF;
    END IF;
END;
/

--7.0 JOINS
--In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
--7.1 INNER
--Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT c.firstname, c.lastname, i.invoiceid FROM customer c
INNER JOIN invoice i ON (c.customerid = i.customerid);
--7.2 OUTER
--Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT c.customerid, c.firstname, c.lastname, i.invoiceid, i.total FROM customer c
FULL OUTER JOIN invoice i ON (c.customerid = i.customerid);
--7.3 RIGHT
--Task – Create a right join that joins album and artist specifying artist name and title.
SELECT art.name, a.title FROM album a
RIGHT JOIN artist art ON (a.artistid = art.artistid);
--7.4 CROSS
--Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT * FROM album CROSS JOIN artist
ORDER BY artist.name;
--7.5 SELF
--Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT * FROM employee e
LEFT JOIN employee manager ON (e.reportsto = manager.employeeid);
--
--14
--
--
