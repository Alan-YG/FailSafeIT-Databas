# FailSafeIT-Databas
# FailSafe IT – Inlämningsuppgift 1 (Databashantering SQL)

Detta repository innehåller min lösning för databasen till konsultbolaget FailSafe IT. Databasen håller reda på kunder, konsulter och deras uppdrag, och är byggd i Microsoft SQL Server (LocalDB).

## Filstruktur
- `README.md` – Den här filen (förklaringar och svar).
- `FailSafeIT.sql` – Hela SQL-skriptet (skapar tabeller, lägger in data och kör frågorna).
- `ER_Diagram.png` – Bild på mitt ER-diagram.

---

## ER-Diagram

**Interaktiv länk till Lucidchart:**  
[Öppna diagrammet i Lucidchart](https://lucid.app/lucidchart/c7bbbf7e-12ea-4d25-ba02-97682aedf48e/edit?invitationId=inv_42e18a9c-a301-47f5-9597-5912823e73b2)

**Databasen består av 3 tabeller:**
1. **Kund** (PK: `KundID`) – Sparar företagsinformation.
2. **Konsult** (PK: `KonsultID`) – Sparar konsultens personuppgifter och timpris.
3. **Uppdrag** (PK: `UppdragID`, FK: `KundID`, `KonsultID`) – Kopplingstabell som binder ihop en kund med en konsult för ett specifikt uppdrag.

**Relationer:** 
- En **Kund** kan ha många **Uppdrag** (1:M).
- En **Konsult** kan ha många **Uppdrag** (1:M).

---

## Normaliseringsmotivering (3NF)

Min databas är designad för att uppfylla tredje normalformen (3NF):

- **1NF (Första normalformen):** Alla kolumner innehåller bara ett enda (atomärt) värde per rad. Det finns inga upprepande grupper, och varje tabell har en unik primärnyckel (`KundID`, `KonsultID`, `UppdragID`).
- **2NF (Andra normalformen):** Eftersom vi har 1NF och alla primärnycklar består av en enda kolumn (ett `IDENTITY`-fält), finns det inga partiella beroenden. All data i en rad beror på hela primärnyckeln.
- **3NF (Tredje normalformen):** Det finns inga transitiva beroenden. Till exempel beror `Företagsnamn` i tabellen `Kund` enbart på `KundID`, och inte på någon annan kolumn. Samma sak gäller för `Konsult`. All information ligger på rätt ställe och hämtas sedan via `JOIN` vid behov.

---

## DevSecOps-reflektion

**Sec (Skydd mot SQL Injection):**  
För att skydda databasen använder jag **parametriserade frågor** (t.ex. `SqlParameter` i C#). Då behandlas användarens inmatning alltid som ren data och aldrig som körbar SQL-kod. Ett extra skydd är att använda **Stored Procedures** och tillämpa *Principle of Least Privilege* (minsta möjliga behörighet), så att applikationen inte har direkt åtkomst att radera tabeller.

**Ops (Prestanda och optimering):**  
För att sökningar ska gå snabbt även om databasen växer till miljontals rader, har jag skapat **Non-Clustered Index** på kolumner som söks ofta. I mitt skript har jag lagt index på `OrgNr` i `Kund`-tabellen, samt på de främmande nycklarna (`KundID` och `KonsultID`) i `Uppdrag`-tabellen för snabbare `JOIN`-operationer.
