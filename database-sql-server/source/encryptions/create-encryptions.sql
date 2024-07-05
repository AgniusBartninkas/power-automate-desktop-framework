-- setup encryption for the database
USE [PowerAutomate]
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '{password}';
Go

CREATE CERTIFICATE CredentialProtectorCertificate
   WITH SUBJECT = 'CredentialProtector';
GO

CREATE SYMMETRIC KEY CredentialProtector
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CredentialProtectorCertificate;
GO

-- setup encryption for the database
USE [PowerAutomate_DEV]
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '{password}';
Go

CREATE CERTIFICATE CredentialProtectorCertificate
   WITH SUBJECT = 'CredentialProtector';
GO

CREATE SYMMETRIC KEY CredentialProtector
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CredentialProtectorCertificate;
GO