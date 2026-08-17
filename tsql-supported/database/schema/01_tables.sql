-- SQL Server T-SQL Employee Management Schema
-- Demonstrates T-SQL-specific features

USE [EmployeeDB]
GO

-- Set T-SQL options (T-SQL-specific)
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Employees table
CREATE TABLE [dbo].[Employees] (
    [EmployeeId] INT PRIMARY KEY IDENTITY(1000, 1),
    [FirstName] NVARCHAR(50) NOT NULL,
    [LastName] NVARCHAR(50) NOT NULL,
    [Email] NVARCHAR(100) UNIQUE,
    [Phone] NVARCHAR(20),
    [HireDate] DATETIME NOT NULL,
    [Salary] DECIMAL(10,2),
    [DepartmentId] INT,
    [Status] CHAR(1) NOT NULL DEFAULT 'A',
    [CreatedDate] DATETIME DEFAULT GETDATE(),
    [UpdatedDate] DATETIME DEFAULT GETDATE()
)
GO

-- Departments table
CREATE TABLE [dbo].[Departments] (
    [DepartmentId] INT PRIMARY KEY IDENTITY(100, 1),
    [DepartmentName] NVARCHAR(100) NOT NULL,
    [ManagerId] INT,
    [Budget] DECIMAL(15,2),
    [CreatedDate] DATETIME DEFAULT GETDATE()
)
GO

-- Performance Reviews table
CREATE TABLE [dbo].[PerformanceReviews] (
    [ReviewId] INT PRIMARY KEY IDENTITY(10000, 1),
    [EmployeeId] INT NOT NULL,
    [ReviewDate] DATETIME DEFAULT GETDATE(),
    [Rating] INT CHECK (Rating BETWEEN 1 AND 5),
    [Comments] NVARCHAR(MAX),
    [ReviewerId] INT,
    CONSTRAINT [FK_Reviews_Employee] FOREIGN KEY ([EmployeeId])
        REFERENCES [dbo].[Employees]([EmployeeId]) ON DELETE CASCADE
)
GO

-- Audit Log table
CREATE TABLE [dbo].[AuditLog] (
    [LogId] BIGINT PRIMARY KEY IDENTITY(1, 1),
    [TableName] NVARCHAR(100),
    [RecordId] INT,
    [Action] VARCHAR(10),
    [OldValues] NVARCHAR(MAX),
    [NewValues] NVARCHAR(MAX),
    [ChangedBy] NVARCHAR(100),
    [ChangedDate] DATETIME DEFAULT GETDATE()
)
GO

-- Salary History table
CREATE TABLE [dbo].[SalaryHistory] (
    [SalaryHistoryId] BIGINT PRIMARY KEY IDENTITY(1, 1),
    [EmployeeId] INT NOT NULL,
    [SalaryAmount] DECIMAL(10,2),
    [EffectiveDate] DATETIME,
    [EndDate] DATETIME,
    [ReasonForChange] NVARCHAR(255),
    CONSTRAINT [FK_SalaryHistory_Employee] FOREIGN KEY ([EmployeeId])
        REFERENCES [dbo].[Employees]([EmployeeId])
)
GO

-- Add foreign key for department
ALTER TABLE [dbo].[Employees]
ADD CONSTRAINT [FK_Employees_Department]
FOREIGN KEY ([DepartmentId]) REFERENCES [dbo].[Departments]([DepartmentId])
GO

-- Add foreign key for manager
ALTER TABLE [dbo].[Departments]
ADD CONSTRAINT [FK_Departments_Manager]
FOREIGN KEY ([ManagerId]) REFERENCES [dbo].[Employees]([EmployeeId])
GO

-- Create indexes
CREATE INDEX [IX_Employees_Email] ON [dbo].[Employees]([Email])
GO
CREATE INDEX [IX_Employees_Department] ON [dbo].[Employees]([DepartmentId])
GO
CREATE INDEX [IX_SalaryHistory_Employee] ON [dbo].[SalaryHistory]([EmployeeId])
GO
