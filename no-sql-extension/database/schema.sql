-- Valid T-SQL file with .sql extension
USE [TestDB]
GO

CREATE TABLE [dbo].[Products] (
    [ProductId] INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(100),
    [Price] DECIMAL(10,2)
)
GO
