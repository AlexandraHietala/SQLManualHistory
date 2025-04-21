
-----------------------------------------------------------

USE [AuditTest]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER FUNCTION [dbo].[fnGetCustomerHistory]
(
   @customer_id int
)
RETURNS TABLE
AS

   RETURN 
   (
			WITH changesDraft1 AS (
					SELECT 
						[EFFECTIVE_DATE],
						[INEFFECTIVE_DATE],
						[CUSTOMER_ID],
						[FIRST_NAME],
						[MIDDLE_NAME],
						[LAST_NAME],
						[ADDRESS_1],
						[ADDRESS_2],
						[ADDRESS_3],
						[CITY],
						[STATE],
						[ZIP],
						[VIP],
						[ADDED],
						[DELETED],
						[MODIFIED_BY],
						nextCUSTOMER_ID = LEAD([CUSTOMER_ID]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),	
						nextFIRST_NAME = LEAD([FIRST_NAME]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),	
						nextMIDDLE_NAME = LEAD([MIDDLE_NAME]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),	
						nextLAST_NAME = LEAD([LAST_NAME]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),	
						nextADDRESS_1 = LEAD([ADDRESS_1]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),	
						nextADDRESS_2 = LEAD([ADDRESS_2]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),
						nextADDRESS_3 = LEAD([ADDRESS_3]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),
						nextCITY = LEAD([CITY]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),
						nextSTATE = LEAD([STATE]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),
						nextZIP = LEAD([ZIP]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),
						nextVIP = LEAD([VIP]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),
						nextADDED = LEAD([ADDED]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),
						nextDELETED = LEAD([DELETED]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]),
						nextMODIFIED_BY = LEAD([MODIFIED_BY]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [EFFECTIVE_DATE]
					)
				FROM dbo.Audit_Customers
				WHERE 
					[CUSTOMER_ID] = @customer_id
			), 
			changesDraft2 AS (
				SELECT 
					[CUSTOMER_ID],
					COLNAME AS [COLUMN],
					VALUE,
					NEXTVALUE,
					NULL as SNAPSHOT,
					[EFFECTIVE_DATE],
					[INEFFECTIVE_DATE],
					nextMODIFIED_BY as [MODIFIED_BY]
				FROM changesDraft1
					CROSS APPLY (VALUES																					
						('CUSTOMER ID', COALESCE(CAST([CUSTOMER_ID] AS VARCHAR(100)),''),COALESCE(CAST(nextCUSTOMER_ID AS VARCHAR(100)),'')),
						('FIRST NAME', COALESCE(CAST([FIRST_NAME] AS VARCHAR(100)),''),COALESCE(CAST(nextFIRST_NAME AS VARCHAR(100)),'')),
						('MIDDLE NAME', COALESCE(CAST([MIDDLE_NAME] AS VARCHAR(100)),''),COALESCE(CAST(nextMIDDLE_NAME AS VARCHAR(100)),'')),
						('LAST NAME', COALESCE(CAST([LAST_NAME] AS VARCHAR(100)),''),COALESCE(CAST(nextLAST_NAME AS VARCHAR(100)),'')),
						('ADDRESS 1', COALESCE(CAST([ADDRESS_1] AS VARCHAR(100)),''),COALESCE(CAST(nextADDRESS_1 AS VARCHAR(100)),'')),
						('ADDRESS 2', COALESCE(CAST([ADDRESS_2] AS VARCHAR(100)),''),COALESCE(CAST(nextADDRESS_2 AS VARCHAR(100)),'')),
						('ADDRESS 3', COALESCE(CAST([ADDRESS_3] AS VARCHAR(100)),''),COALESCE(CAST(nextADDRESS_3 AS VARCHAR(100)),'')),
						('CITY', COALESCE(CAST([CITY] AS VARCHAR(100)),''),COALESCE(CAST(nextCITY AS VARCHAR(100)),'')),
						('STATE', COALESCE(CAST([STATE] AS VARCHAR(2)),''),COALESCE(CAST(nextSTATE AS VARCHAR(2)),'')),
						('ZIP', COALESCE(CAST([ZIP] AS VARCHAR(15)),''),COALESCE(CAST(nextZIP AS VARCHAR(15)),'')),
						('VIP', COALESCE(CAST([VIP] AS VARCHAR(10)),''),COALESCE(CAST(nextVIP AS VARCHAR(10)),''))
					) CA(COLNAME, VALUE, NEXTVALUE)
				WHERE 
					EXISTS(SELECT VALUE EXCEPT SELECT NEXTVALUE)
					AND [CUSTOMER_ID] = @customer_id
					AND [nextCUSTOMER_ID] IS NOT NULL
			), 
			changes AS (
			  SELECT 
				   INEFFECTIVE_DATE as DATEOFCHANGE, 
				   MODIFIED_BY as CHANGEDBY, 
				   'Changed record value ' + [COLUMN] + ' from ' + CASE WHEN [VALUE] IS NULL THEN '[]' ELSE '[' + [VALUE] + ']' END + ' to ' + CASE WHEN [NEXTVALUE] IS NULL THEN '[]' ELSE '[' + [NEXTVALUE] + ']' END AS CHANGE 
			  FROM changesDraft2
			),
			addsDraft AS (
					SELECT 
						[CUSTOMER_ID],
						NULL as [COLUMN],
						NULL as VALUE,
						NULL as NEXTVALUE,
						(SELECT 
							'CUSTOMER ID: [' + COALESCE(CAST([CUSTOMER_ID] AS VARCHAR(100)), '') + '],' + 
							' FIRST NAME: [' + COALESCE(CAST([FIRST_NAME] AS VARCHAR(100)), '') + '],' + 
							' MIDDLE NAME: [' + COALESCE(CAST([MIDDLE_NAME] AS VARCHAR(100)), '') + '],' + 
							' LAST NAME: [' + COALESCE(CAST([LAST_NAME] AS VARCHAR(100)), '') + '],' + 
							' ADDRESS 1: [' + COALESCE(CAST([ADDRESS_1] AS VARCHAR(100)), '') + '],' + 
							' ADDRESS 2: [' + COALESCE(CAST([ADDRESS_2] AS VARCHAR(100)), '') + '],' + 
							' ADDRESS 3: [' + COALESCE(CAST([ADDRESS_3] AS VARCHAR(100)), '') + '],' + 
							' CITY: [' + COALESCE(CAST([CITY] AS VARCHAR(100)), '') + '],' + 
							' STATE: [' + COALESCE(CAST([STATE] AS VARCHAR(2)), '') + '],' + 
							' ZIP: [' + COALESCE(CAST([ZIP] AS VARCHAR(15)), '') + '],' + 
							' VIP: [' + COALESCE(CAST([VIP] AS VARCHAR(10)), '') + ']'
						) as [SNAPSHOT],
						EFFECTIVE_DATE,
						INEFFECTIVE_DATE,
						MODIFIED_BY 
					FROM dbo.Audit_Customers
					WHERE
						[CUSTOMER_ID] = @customer_id
						AND [ADDED] = 1
			),
			adds AS (
					SELECT 
						EFFECTIVE_DATE as DATEOFCHANGE, 
						MODIFIED_BY as CHANGEDBY, 
						'Added record with values [' + [SNAPSHOT] + ']' AS CHANGE
					FROM addsDraft
			),
			deletesDraft AS (
					SELECT 
						[CUSTOMER_ID],
						NULL as [COLUMN],
						NULL as VALUE,
						NULL as NEXTVALUE,
						(SELECT 
							'CUSTOMER ID: [' + COALESCE(CAST([CUSTOMER_ID] AS VARCHAR(100)), '') + '],' + 
							' FIRST NAME: [' + COALESCE(CAST([FIRST_NAME] AS VARCHAR(100)), '') + '],' + 
							' MIDDLE NAME: [' + COALESCE(CAST([MIDDLE_NAME] AS VARCHAR(100)), '') + '],' + 
							' LAST NAME: [' + COALESCE(CAST([LAST_NAME] AS VARCHAR(100)), '') + '],' + 
							' ADDRESS 1: [' + COALESCE(CAST([ADDRESS_1] AS VARCHAR(100)), '') + '],' + 
							' ADDRESS 2: [' + COALESCE(CAST([ADDRESS_2] AS VARCHAR(100)), '') + '],' + 
							' ADDRESS 3: [' + COALESCE(CAST([ADDRESS_3] AS VARCHAR(100)), '') + '],' + 
							' CITY: [' + COALESCE(CAST([CITY] AS VARCHAR(100)), '') + '],' + 
							' STATE: [' + COALESCE(CAST([STATE] AS VARCHAR(2)), '') + '],' + 
							' ZIP: [' + COALESCE(CAST([ZIP] AS VARCHAR(15)), '') + '],' + 
							' VIP: [' + COALESCE(CAST([VIP] AS VARCHAR(10)), '') + ']'
						) as [SNAPSHOT],
						EFFECTIVE_DATE,
						INEFFECTIVE_DATE,
						MODIFIED_BY 
					FROM dbo.Audit_Customers
					WHERE
						[CUSTOMER_ID] = @customer_id
						AND [DELETED] = 1
			),
			deletes AS (
				SELECT 
					EFFECTIVE_DATE as DATEOFCHANGE, 
					MODIFIED_BY as CHANGEDBY, 
					'Deleted record with values [' + [SNAPSHOT] + ']' AS CHANGE
				FROM deletesDraft
			)
			
			SELECT * FROM changes
			UNION ALL 
			SELECT * FROM adds
			UNION ALL 
			SELECT * FROM deletes
		
   );

   GO

-----------------------------------------------------------

USE [AuditTest]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[spGetCustomerHistory]
	 @customer_id int
AS

BEGIN TRY

	SELECT DATEOFCHANGE, CHANGEDBY, CHANGE 
	FROM dbo.fnGetCustomerHistory (@customer_id)
	ORDER BY DATEOFCHANGE DESC;

END TRY

BEGIN CATCH

	DECLARE @ErrorMessage nvarchar(500);
	DECLARE @ErrorSeverity int;
	DECLARE @ErrorState int;

	SELECT @ErrorMessage  = ERROR_MESSAGE(),
		   @ErrorSeverity  = ERROR_SEVERITY(),
		   @ErrorState  = ERROR_STATE();

	SELECT @ErrorMessage, @ErrorSeverity, @ErrorState;

	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

END CATCH


GO

-----------------------------------------------------------