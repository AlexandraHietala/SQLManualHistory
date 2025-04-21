
-----------------------------------------------------------

USE [AuditTest]
GO

DECLARE @first_name varchar(100)
DECLARE @middle_name varchar(100)
DECLARE @last_name varchar(100)
DECLARE @address_1 varchar(100)
DECLARE @address_2 varchar(100)
DECLARE @address_3 varchar(100)
DECLARE @city varchar(100)
DECLARE @state char(2)
DECLARE @zip varchar(15)
DECLARE @vip bit
DECLARE @modifiedby varchar(100)

SET @first_name = 'John'
SET @last_name = 'Doe'
SET @address_1 = '123 Fake St.'
SET @city = 'Davenport'
SET @state = 'FL'
SET @zip = '33897'
SET @vip = 1
SET @modifiedby = 'Alex'

EXECUTE [dbo].[spAddCustomerEntry]
   @first_name
  ,@middle_name
  ,@last_name
  ,@address_1
  ,@address_2
  ,@address_3
  ,@city
  ,@state
  ,@zip
  ,@vip
  ,@modifiedby

GO

-----------------------------------------------------------

USE [AuditTest]
GO

DECLARE @customer_id int
DECLARE @first_name varchar(100)
DECLARE @middle_name varchar(100)
DECLARE @last_name varchar(100)
DECLARE @address_1 varchar(100)
DECLARE @address_2 varchar(100)
DECLARE @address_3 varchar(100)
DECLARE @city varchar(100)
DECLARE @state char(2)
DECLARE @zip varchar(15)
DECLARE @vip bit
DECLARE @modifiedby varchar(100)

SET @customer_id = 1
SET @first_name = 'John'
SET @middle_name = 'T'
SET @last_name = 'Doe'
SET @address_1 = '123 Ocean Ave'
SET @city = 'Davenport'
SET @state = 'FL'
SET @zip = '11111'
SET @vip = 0
SET @modifiedby = 'Alex'

EXECUTE [dbo].[spUpdateCustomerEntry]
   @customer_id
  ,@first_name
  ,@middle_name
  ,@last_name
  ,@address_1
  ,@address_2
  ,@address_3
  ,@city
  ,@state
  ,@zip
  ,@vip
  ,@modifiedby

GO

-----------------------------------------------------------

USE [AuditTest]
GO

DECLARE @customer_id int
DECLARE @modifiedby varchar(100)

SET @customer_id = 1
SET @modifiedby = 'Jim'

EXECUTE [dbo].[spDeleteCustomerEntry]
   @customer_id
  ,@modifiedby

GO

-----------------------------------------------------------

USE [AuditTest]
GO

DECLARE @customer_id int

SET @customer_id = 1

SELECT * FROM dbo.fnGetCustomerHistory (@customer_id) 
ORDER BY DATEOFCHANGE DESC

-----------------------------------------------------------

USE [AuditTest]
GO

DECLARE @customer_id int

SET @customer_id = 1

EXECUTE [dbo].[spGetCustomerHistory]
   @customer_id

GO

-----------------------------------------------------------
  
  SELECT *
  FROM [AuditTest].[dbo].[Audit_Customers]
  WHERE CUSTOMER_ID = 1
  ORDER BY EFFECTIVE_DATE ASC
