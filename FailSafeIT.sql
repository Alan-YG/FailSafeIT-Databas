
-- FailSafe IT - Databashantering SQL
-- Inlämningsuppgift 

-- Skapa databasen
CREATE DATABASE FailSafeIT;
GO
USE FailSafeIT;
GO


-- DDL: Skapa tabeller


CREATE TABLE Kund (
    KundID INT IDENTITY(1,1) PRIMARY KEY,
    OrgNr NVARCHAR(11) NOT NULL UNIQUE,
    Foretagsnamn NVARCHAR(100) NOT NULL,
    Epost NVARCHAR(100) NOT NULL,
    Telefon NVARCHAR(20) NOT NULL
);

CREATE TABLE Konsult (
    KonsultID INT IDENTITY(1,1) PRIMARY KEY,
    PersonNr NVARCHAR(13) NOT NULL UNIQUE,
    Namn NVARCHAR(100) NOT NULL,
    Timpris DECIMAL(10,2) NOT NULL,
    Specialitet NVARCHAR(50) NOT NULL
);

-- Uppdrag är kopplingstabellen som löser upp M:N mellan Kund och Konsult
CREATE TABLE Uppdrag (
    UppdragID INT IDENTITY(1,1) PRIMARY KEY,
    StartDatum DATE NOT NULL,
    SlutDatum DATE NOT NULL,
    Rollbeskrivning NVARCHAR(200) NOT NULL,
    KundID INT NOT NULL,
    KonsultID INT NOT NULL,
    CONSTRAINT FK_Uppdrag_Kund FOREIGN KEY (KundID) REFERENCES Kund(KundID),
    CONSTRAINT FK_Uppdrag_Konsult FOREIGN KEY (KonsultID) REFERENCES Konsult(KonsultID)
);
GO

-- Index på främmande nycklar (snabbare JOIN och FK-kontroller)
CREATE NONCLUSTERED INDEX IX_Uppdrag_KundID ON Uppdrag(KundID);
CREATE NONCLUSTERED INDEX IX_Uppdrag_KonsultID ON Uppdrag(KonsultID);
GO

-- ==========================================
-- DML: Fyll på med testdata
-- ==========================================

INSERT INTO Kund (OrgNr, Foretagsnamn, Epost, Telefon) VALUES
(N'556123-4567', N'TechSolutions AB', N'info@techsolutions.se', N'08-1234567'),
(N'556987-6543', N'SecureBank AB', N'kontakt@securebank.se', N'031-987654'),
(N'556456-7890', N'GreenEnergy AB', N'hej@greenenergy.se', N'040-112233'),
(N'556111-2222', N'Nordic Retail AB', N'info@nordicretail.se', N'019-445566');

INSERT INTO Konsult (PersonNr, Namn, Timpris, Specialitet) VALUES
(N'19900101-1234', N'Alan Dev', 1350.00, N'DevSecOps'),
(N'19850505-5678', N'Saga Säker', 1500.00, N'Cybersecurity'),
(N'19921212-9012', N'Erik Kod', 1100.00, N'C# Developer');

INSERT INTO Uppdrag (StartDatum, SlutDatum, Rollbeskrivning, KundID, KonsultID) VALUES
('2026-01-10', '2026-03-15', N'Säkerhetsgranskning av API-miljö', 1, 2),
('2026-02-01', '2026-06-30', N'Utveckling av kundportal', 1, 3),
('2026-03-01', '2026-04-01', N'Penetrationstestning av databas', 2, 2),
('2026-04-15', '2026-08-15', N'Implementering av CI/CD pipeline', 2, 1),
('2026-05-01', '2026-05-20', N'Konsultation kring molnmigrering', 3, 1);
GO

-- ==========================================
-- Frågor (Queries)
-- ==========================================

-- Fråga A: Konsulter med timpris högre än 1200 kr, högst pris först
SELECT Namn, Timpris
FROM Konsult
WHERE Timpris > 1200
ORDER BY Timpris DESC;

-- Fråga B: Sammanställning över alla uppdrag (INNER JOIN)
SELECT
    k.Foretagsnamn,
    kons.Namn AS KonsultNamn,
    u.StartDatum,
    u.SlutDatum
FROM Uppdrag u
INNER JOIN Kund k ON u.KundID = k.KundID
INNER JOIN Konsult kons ON u.KonsultID = kons.KonsultID
ORDER BY k.Foretagsnamn, u.StartDatum;

-- Fråga C: Alla kunder och antal uppdrag i systemet
-- (alla registrerade uppdrag räknas som aktiva; LEFT JOIN gör att
--  kunder utan uppdrag också visas, med antal 0)
SELECT
    k.Foretagsnamn,
    COUNT(u.UppdragID) AS AntalUppdrag
FROM Kund k
LEFT JOIN Uppdrag u ON k.KundID = u.KundID
GROUP BY k.KundID, k.Foretagsnamn
ORDER BY AntalUppdrag DESC;

-- Fråga D: Uppdatera timpris för en specifik konsult (identifieras via primärnyckel)
UPDATE Konsult
SET Timpris = 1400.00
WHERE KonsultID = 1;

-- Verifiera uppdateringen
SELECT KonsultID, Namn, Timpris FROM Konsult WHERE KonsultID = 1;

-- Fråga E: Ta bort en kund som inte har några uppdrag (KundID 4 har inga uppdrag)
-- Om kunden hade haft uppdrag hade främmande nyckeln blockerat raderingen.
-- Test (ger felmeddelande, kör bara för att visa skyddet):
-- DELETE FROM Kund WHERE KundID = 1;
DELETE FROM Kund WHERE KundID = 4;

-- Verifiera raderingen
SELECT KundID, Foretagsnamn FROM Kund;
GO