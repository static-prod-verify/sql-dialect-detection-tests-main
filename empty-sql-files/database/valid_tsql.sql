-- Valid T-SQL file mixed with empty files
USE [TestDB]
GO

CREATE TABLE [dbo].[TestTable] (
    [Id] INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(100)
)
GO

CREATE FUNCTION [dbo].[GetCount]()
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM [dbo].[TestTable])
END
GO
