-- SQL Server T-SQL Orders Schema (Supported)
USE [OrderDB]
GO

CREATE TABLE [dbo].[Orders] (
    [OrderId] INT PRIMARY KEY IDENTITY(1, 1),
    [OrderNumber] NVARCHAR(50) NOT NULL,
    [OrderDate] DATETIME DEFAULT GETDATE(),
    [Total] DECIMAL(10,2),
    [Status] CHAR(1) DEFAULT 'P'
)
GO

CREATE FUNCTION [dbo].[GetOrderCount]()
RETURNS INT
AS
BEGIN
    DECLARE @Count INT
    SELECT @Count = COUNT(*) FROM [dbo].[Orders]
    RETURN @Count
END
GO
