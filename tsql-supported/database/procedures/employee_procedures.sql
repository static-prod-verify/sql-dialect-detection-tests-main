-- SQL Server T-SQL Stored Procedures for Employee Management

-- Procedure to create a new employee record
CREATE PROCEDURE [dbo].[CreateEmployee]
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @HireDate DATETIME,
    @Salary DECIMAL(10,2),
    @DepartmentId INT,
    @EmployeeId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION

        INSERT INTO [dbo].[Employees] (
            [FirstName], [LastName], [Email], [Phone],
            [HireDate], [Salary], [DepartmentId], [Status]
        ) VALUES (
            @FirstName, @LastName, @Email, @Phone,
            @HireDate, @Salary, @DepartmentId, 'A'
        )

        SET @EmployeeId = @@IDENTITY

        INSERT INTO [dbo].[AuditLog] (
            [TableName], [RecordId], [Action], [NewValues], [ChangedBy]
        ) VALUES (
            'Employees', @EmployeeId, 'INSERT',
            CONCAT('Name: ', @FirstName, ' ', @LastName),
            SYSTEM_USER
        )

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO

-- Procedure to update employee salary
CREATE PROCEDURE [dbo].[UpdateEmployeeSalary]
    @EmployeeId INT,
    @NewSalary DECIMAL(10,2),
    @ReasonForChange NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @OldSalary DECIMAL(10,2)
        SELECT @OldSalary = [Salary] FROM [dbo].[Employees]
        WHERE [EmployeeId] = @EmployeeId

        UPDATE [dbo].[Employees]
        SET [Salary] = @NewSalary, [UpdatedDate] = GETDATE()
        WHERE [EmployeeId] = @EmployeeId

        INSERT INTO [dbo].[SalaryHistory] (
            [EmployeeId], [SalaryAmount], [EffectiveDate], [ReasonForChange]
        ) VALUES (
            @EmployeeId, @NewSalary, GETDATE(), @ReasonForChange
        )

        INSERT INTO [dbo].[AuditLog] (
            [TableName], [RecordId], [Action], [OldValues], [NewValues], [ChangedBy]
        ) VALUES (
            'Employees', @EmployeeId, 'UPDATE',
            CONCAT('Salary: ', @OldSalary),
            CONCAT('Salary: ', @NewSalary),
            SYSTEM_USER
        )

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO

-- Procedure to get department employee report - vulnerable to SQL injection
CREATE PROCEDURE [dbo].[GetDepartmentEmployeeReport]
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @SQL NVARCHAR(MAX)
    SET @SQL = 'SELECT [EmployeeId], [FirstName], [LastName], [Salary] FROM [dbo].[Employees] WHERE [DepartmentId] = ' + CAST(@DepartmentId AS NVARCHAR(10))

    EXEC sp_executesql @SQL
END
GO

-- Procedure to log audit trail with transactions
CREATE PROCEDURE [dbo].[LogAuditTrail]
    @TableName NVARCHAR(100),
    @RecordId INT,
    @Action VARCHAR(10),
    @OldValues NVARCHAR(MAX),
    @NewValues NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO [dbo].[AuditLog] (
        [TableName], [RecordId], [Action], [OldValues], [NewValues], [ChangedBy]
    ) VALUES (
        @TableName, @RecordId, @Action, @OldValues, @NewValues, SYSTEM_USER
    )
END
GO
