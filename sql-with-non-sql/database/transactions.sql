-- T-SQL mixed with other source code
USE [TransactionDB]
GO

CREATE TABLE [dbo].[Transactions] (
    [TransactionId] INT PRIMARY KEY IDENTITY(1,1),
    [Amount] DECIMAL(10,2),
    [TransactionDate] DATETIME DEFAULT GETDATE()
)
GO

CREATE FUNCTION [dbo].[GetTransactionTotal]()
RETURNS DECIMAL(15,2)
AS
BEGIN
    RETURN (SELECT SUM([Amount]) FROM [dbo].[Transactions])
END
GO
