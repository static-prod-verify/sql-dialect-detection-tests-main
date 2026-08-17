-- SQL Server T-SQL HR Stored Procedures

-- Procedure to generate salary review report
CREATE PROCEDURE [dbo].[GenerateSalaryReviewReport]
    @DepartmentId INT = NULL,
    @MinSalary DECIMAL(10,2) = 0,
    @MaxSalary DECIMAL(10,2) = 999999
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        e.[EmployeeId],
        e.[FirstName],
        e.[LastName],
        e.[Salary],
        d.[DepartmentName],
        [dbo].[CalculateEmployeeTenure](e.[EmployeeId]) AS [TenureYears],
        e.[HireDate],
        CASE
            WHEN e.[Salary] < 50000 THEN 'Below Market'
            WHEN e.[Salary] BETWEEN 50000 AND 100000 THEN 'Market Rate'
            ELSE 'Above Market'
        END AS [SalaryLevel]
    FROM [dbo].[Employees] e
    INNER JOIN [dbo].[Departments] d ON e.[DepartmentId] = d.[DepartmentId]
    WHERE e.[Status] = 'A'
        AND e.[Salary] BETWEEN @MinSalary AND @MaxSalary
        AND (@DepartmentId IS NULL OR e.[DepartmentId] = @DepartmentId)
    ORDER BY e.[Salary] DESC
END
GO

-- Procedure to promote employee
CREATE PROCEDURE [dbo].[PromoteEmployee]
    @EmployeeId INT,
    @NewDepartmentId INT,
    @SalaryIncrease DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @CurrentSalary DECIMAL(10,2)
        SELECT @CurrentSalary = [Salary] FROM [dbo].[Employees]
        WHERE [EmployeeId] = @EmployeeId

        UPDATE [dbo].[Employees]
        SET [DepartmentId] = @NewDepartmentId,
            [Salary] = [Salary] + @SalaryIncrease,
            [UpdatedDate] = GETDATE()
        WHERE [EmployeeId] = @EmployeeId

        INSERT INTO [dbo].[SalaryHistory] (
            [EmployeeId],
            [SalaryAmount],
            [EffectiveDate],
            [ReasonForChange]
        ) VALUES (
            @EmployeeId,
            @CurrentSalary + @SalaryIncrease,
            GETDATE(),
            'Promotion'
        )

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO

-- Procedure to terminate employee
CREATE PROCEDURE [dbo].[TerminateEmployee]
    @EmployeeId INT,
    @TerminationDate DATETIME,
    @ReasonForTermination NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION

        UPDATE [dbo].[Employees]
        SET [Status] = 'I',
            [UpdatedDate] = GETDATE()
        WHERE [EmployeeId] = @EmployeeId

        INSERT INTO [dbo].[AuditLog] (
            [TableName],
            [RecordId],
            [Action],
            [OldValues],
            [NewValues],
            [ChangedBy]
        ) VALUES (
            'Employees',
            @EmployeeId,
            'TERMINATE',
            'Status: A',
            CONCAT('Status: I, Reason: ', @ReasonForTermination),
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

-- Procedure to archive audit logs older than specified days
CREATE PROCEDURE [dbo].[ArchiveOldAuditLogs]
    @DaysToKeep INT = 365
AS
BEGIN
    SET NOCOUNT ON

    DELETE FROM [dbo].[AuditLog]
    WHERE [ChangedDate] < DATEADD(DAY, -@DaysToKeep, GETDATE())
END
GO
