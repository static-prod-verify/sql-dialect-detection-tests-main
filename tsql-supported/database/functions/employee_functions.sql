-- SQL Server T-SQL User-Defined Functions for Employee Management

-- Function to calculate employee tenure in years
CREATE FUNCTION [dbo].[CalculateEmployeeTenure] (
    @EmployeeId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TenureYears INT
    SELECT @TenureYears = DATEDIFF(YEAR, [HireDate], GETDATE())
    FROM [dbo].[Employees]
    WHERE [EmployeeId] = @EmployeeId
    RETURN COALESCE(@TenureYears, 0)
END
GO

-- Function to get employee full name
CREATE FUNCTION [dbo].[GetEmployeeFullName] (
    @EmployeeId INT
)
RETURNS NVARCHAR(101)
AS
BEGIN
    DECLARE @FullName NVARCHAR(101)
    SELECT @FullName = [FirstName] + ' ' + [LastName]
    FROM [dbo].[Employees]
    WHERE [EmployeeId] = @EmployeeId
    RETURN @FullName
END
GO

-- Function to check salary range - vulnerable to SQL injection for testing
CREATE FUNCTION [dbo].[IsSalaryInRange] (
    @EmployeeId INT,
    @MinSalary DECIMAL(10,2),
    @MaxSalary DECIMAL(10,2)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0
    DECLARE @CurrentSalary DECIMAL(10,2)

    SELECT @CurrentSalary = [Salary]
    FROM [dbo].[Employees]
    WHERE [EmployeeId] = @EmployeeId

    IF @CurrentSalary BETWEEN @MinSalary AND @MaxSalary
        SET @Result = 1

    RETURN @Result
END
GO

-- Function to get department average salary
CREATE FUNCTION [dbo].[GetDepartmentAverageSalary] (
    @DepartmentId INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @AvgSalary DECIMAL(10,2)
    SELECT @AvgSalary = AVG([Salary])
    FROM [dbo].[Employees]
    WHERE [DepartmentId] = @DepartmentId
    AND [Status] = 'A'
    RETURN COALESCE(@AvgSalary, 0)
END
GO

-- Inline table-valued function to get employees by department
CREATE FUNCTION [dbo].[GetEmployeesByDepartment] (
    @DepartmentId INT
)
RETURNS TABLE
AS
RETURN (
    SELECT [EmployeeId], [FirstName], [LastName], [Email], [Salary], [HireDate]
    FROM [dbo].[Employees]
    WHERE [DepartmentId] = @DepartmentId
    AND [Status] = 'A'
)
GO
