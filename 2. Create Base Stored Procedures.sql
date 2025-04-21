-----------------------------------------------------------

USE [AuditTest]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[spAddCustomerEntry]
	@first_name varchar(100),
	@middle_name varchar(100),
	@last_name varchar(100),
	@address_1 varchar(100),
	@address_2 varchar(100),
	@address_3 varchar(100),
	@city varchar(100),
	@state char(2),
	@zip varchar(15),
	@vip bit,
	@modifiedby varchar(100)
AS

BEGIN TRY
	
	SET NOCOUNT ON;

	DECLARE @customer_id int

	-- Insert the new main table record
	INSERT INTO [dbo].[Customers] ([FIRST_NAME], [MIDDLE_NAME], [LAST_NAME], [ADDRESS_1], [ADDRESS_2], [ADDRESS_3], [CITY], [STATE], [ZIP], [VIP])
	VALUES (@first_name, @middle_name, @last_name, @address_1, @address_2, @address_3, @city, @state, @zip, @vip);
	
	SELECT @customer_id = SCOPE_IDENTITY()

	-- Insert the new open audit record
	INSERT INTO [dbo].[Audit_Customers] ([EFFECTIVE_DATE], [INEFFECTIVE_DATE], [CUSTOMER_ID], [FIRST_NAME], [MIDDLE_NAME], [LAST_NAME], [ADDRESS_1], [ADDRESS_2], [ADDRESS_3], [CITY], [STATE], [ZIP], [VIP], [ADDED], [DELETED], [MODIFIED_BY])
	VALUES (GETDATE(), '9999-12-31', @customer_id, @first_name, @middle_name, @last_name, @address_1, @address_2, @address_3, @city, @state, @zip, @vip, 1, 0, @modifiedby)


END TRY

BEGIN CATCH

	DECLARE @ErrorMessage nvarchar(4000);
	DECLARE @ErrorSeverity int;
	DECLARE @ErrorState int;

	SELECT @ErrorMessage = ERROR_MESSAGE(),
		   @ErrorSeverity = ERROR_SEVERITY(),
		   @ErrorState = ERROR_STATE();

	SELECT @ErrorMessage, @ErrorSeverity, @ErrorState;

	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

END CATCH

GO

-----------------------------------------------------------


USE [AuditTest]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[spUpdateCustomerEntry]
	@customer_id int,
	@first_name varchar(100),
	@middle_name varchar(100),
	@last_name varchar(100),
	@address_1 varchar(100),
	@address_2 varchar(100),
	@address_3 varchar(100),
	@city varchar(100),
	@state char(2),
	@zip varchar(15),
	@vip bit,
	@modifiedby varchar(100)
AS

BEGIN TRY

	SET NOCOUNT ON;

	-- Only update the customer's record if it exists
	IF EXISTS (SELECT TOP 1 [CUSTOMER_ID] FROM [dbo].[Customers] WHERE [CUSTOMER_ID] = @customer_id)

		BEGIN

			-- Update the existing record in the main table
			UPDATE [dbo].[Customers] 
			SET [FIRST_NAME] = @first_name, [MIDDLE_NAME] = @middle_name, [LAST_NAME] = @last_name, [ADDRESS_1] = @address_1, [ADDRESS_2] = @address_2, [ADDRESS_3] = @address_3, [CITY] = @city, [STATE] = @state, [ZIP] = @zip, [VIP] = @vip
			WHERE [CUSTOMER_ID] = @customer_id

			-- Close the existing audit record
			UPDATE [dbo].[Audit_Customers]
			SET [INEFFECTIVE_DATE] = GETDATE() 
			WHERE [CUSTOMER_ID] = @customer_id AND [INEFFECTIVE_DATE] > GETDATE()
			
			-- Create a new audit record
			INSERT INTO [dbo].[Audit_Customers] ([EFFECTIVE_DATE], [INEFFECTIVE_DATE], [CUSTOMER_ID], [FIRST_NAME], [MIDDLE_NAME], [LAST_NAME], [ADDRESS_1], [ADDRESS_2], [ADDRESS_3], [CITY], [STATE], [ZIP], [VIP], [ADDED], [DELETED], [MODIFIED_BY])
			VALUES (GETDATE(), '9999-12-31', @customer_id, @first_name, @middle_name, @last_name, @address_1, @address_2, @address_3, @city, @state, @zip, @vip, 0, 0, @modifiedby)

		END

	-- If the record doesn't already exist, throw an error
	ELSE
		
		RAISERROR('Customer ID being updated does not exist.',1,1);  

END TRY

BEGIN CATCH

	DECLARE @ErrorMessage nvarchar(4000);
	DECLARE @ErrorSeverity int;
	DECLARE @ErrorState int;

	SELECT @ErrorMessage = ERROR_MESSAGE(),
		   @ErrorSeverity = ERROR_SEVERITY(),
		   @ErrorState = ERROR_STATE();

	SELECT @ErrorMessage, @ErrorSeverity, @ErrorState;

	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

END CATCH

GO

-----------------------------------------------------------


USE [AuditTest]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[spDeleteCustomerEntry]
	@customer_id int,
	@modifiedby varchar(100)
AS

BEGIN TRY

	SET NOCOUNT ON;

	-- Only delete the customer's record if it exists
	IF EXISTS (SELECT TOP 1 [CUSTOMER_ID] FROM [dbo].[Customers] WHERE [CUSTOMER_ID] = @customer_id)

		BEGIN

			-- Close the existing audit record
			UPDATE [dbo].[Audit_Customers]
			SET [INEFFECTIVE_DATE] = GETDATE() 
			WHERE [CUSTOMER_ID] = @customer_id AND [INEFFECTIVE_DATE] > GETDATE()
			
			-- Create a new audit record for the deletion
			INSERT INTO [dbo].[Audit_Customers] ([EFFECTIVE_DATE], [INEFFECTIVE_DATE], [CUSTOMER_ID], [FIRST_NAME], [MIDDLE_NAME], [LAST_NAME], [ADDRESS_1], [ADDRESS_2], [ADDRESS_3], [CITY], [STATE], [ZIP], [VIP], [ADDED], [DELETED], [MODIFIED_BY])
			SELECT GETDATE(), '9999-12-31', @customer_id, c.[FIRST_NAME], c.[MIDDLE_NAME], c.[LAST_NAME], c.[ADDRESS_1], c.[ADDRESS_2], c.[ADDRESS_3], c.[CITY], c.[STATE], c.[ZIP], c.[VIP], 0, 1, @modifiedby
			FROM [dbo].[Customers] c
			WHERE [CUSTOMER_ID] = @customer_id
		
			-- Delete the existing record in the main table
			DELETE FROM [dbo].[Customers] 
			WHERE [CUSTOMER_ID] = @customer_id

		END

	-- If the record being deleted doesn't already exist, throw an error
	ELSE
		
		RAISERROR('Customer ID being deleted does not exist.', 1, 1);  

END TRY

BEGIN CATCH

	DECLARE @ErrorMessage nvarchar(4000);
	DECLARE @ErrorSeverity int;
	DECLARE @ErrorState int;

	SELECT @ErrorMessage = ERROR_MESSAGE(),
		   @ErrorSeverity = ERROR_SEVERITY(),
		   @ErrorState = ERROR_STATE();


	SELECT @ErrorMessage, @ErrorSeverity, @ErrorState;

	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

END CATCH

GO

-----------------------------------------------------------
