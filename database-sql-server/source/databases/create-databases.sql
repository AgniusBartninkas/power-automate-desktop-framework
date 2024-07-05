USE [master];
-- Create production database
CREATE DATABASE [PowerAutomate]
GO

USE [PowerAutomate];
ALTER AUTHORIZATION ON DATABASE::[PowerAutomate] TO [sa]
ALTER DATABASE [PowerAutomate]
SET ANSI_NULLS ON
GO
ALTER DATABASE [PowerAutomate]
SET RECOVERY FULL
GO


USE [master];
--Create dev/test database
CREATE DATABASE [PowerAutomate_DEV]
GO

USE [PowerAutomate_DEV];
ALTER AUTHORIZATION ON DATABASE::[PowerAutomate_DEV] TO [sa]
ALTER DATABASE [PowerAutomate_DEV]
SET ANSI_NULLS ON
GO
ALTER DATABASE [PowerAutomate_DEV]
SET RECOVERY FULL
GO
