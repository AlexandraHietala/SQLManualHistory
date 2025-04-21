-----------------------------------------------------------
/*
CREATE DATABASE [AuditTest]

GO
*/

-----------------------------------------------------------

USE [AuditTest]

GO

-----------------------------------------------------------

CREATE TABLE [dbo].[Audit_Customers] (
	[EFFECTIVE_DATE] [datetime] NOT NULL DEFAULT GetDate(),
	[INEFFECTIVE_DATE] [datetime] NULL DEFAULT '9999-12-31',
	[CUSTOMER_ID] [int] NOT NULL,
	[FIRST_NAME] [varchar](100) NOT NULL,
	[MIDDLE_NAME] [varchar](100) NULL,
	[LAST_NAME] [varchar](100) NOT NULL,
	[ADDRESS_1] [varchar](100) NOT NULL,
	[ADDRESS_2] [varchar](100) NULL,
	[ADDRESS_3] [varchar](100) NULL,
	[CITY] [varchar](100) NOT NULL,
	[STATE] [char](2) NOT NULL,
	[ZIP] [varchar](15) NOT NULL,
	[VIP] [bit] NOT NULL,
	[ADDED] [bit] NOT NULL DEFAULT 0,
	[DELETED] [bit] NOT NULL DEFAULT 0,
	[MODIFIED_BY] [varchar](100) NULL
 CONSTRAINT [PK_Audit_Customers] PRIMARY KEY CLUSTERED 
(
	[EFFECTIVE_DATE] ASC,
	[CUSTOMER_ID] ASC
))

GO

-----------------------------------------------------------

CREATE TABLE [dbo].[Customers](
	[CUSTOMER_ID] [int] IDENTITY(1,1) NOT NULL,
	[FIRST_NAME] [varchar](100) NOT NULL,
	[MIDDLE_NAME] [varchar](100) NULL,
	[LAST_NAME] [varchar](100) NOT NULL,
	[ADDRESS_1] [varchar](100) NOT NULL,
	[ADDRESS_2] [varchar](100) NULL,
	[ADDRESS_3] [varchar](100) NULL,
	[CITY] [varchar](100) NOT NULL,
	[STATE] [char](2) NOT NULL,
	[ZIP] [varchar](15) NOT NULL,
	[VIP] [bit] NOT NULL DEFAULT 0,
CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CUSTOMER_ID] ASC
))


GO

-----------------------------------------------------------