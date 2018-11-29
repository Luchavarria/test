------ TEORIA CREACION BD ------
/*
BD DEL SISTEMA
MASTER: TIENE INFORMACION DEL SERVIDOR
MSDB: ES USADA POR EL SERVIDOR PARA PROGRAMAR TAREAS Y ALERTAS
MODEL: SIRVE DE PLANTILLA
TEMPDB: TIENE OBJETOS TEMPORALES
RESOURCE: DB QUE CONTIENE OBJETOS DEL SISTEMA (SYS)
VISTAS DE CATALOGO: PEMITEN ACCEDER A LOS METADATOS DEL SERVIDOR

CREATE DATABASE NOMBRE
ON PRIMARY
(
NAME = NOMBRE_DATA,
FILENAME = 'C:\TEMP\NOMBRE_DATA.MDF',
SIZE = 10MB,
MAXSIZE = 50MB,
FILEGROWTH = 5MB)
LOG ON
(
NAME = NOMBRE_LOG,
FILENAME = 'C:\TEMP\NOMBRE_LOG.LDF',
SIZE = 50MB,
MAXSIZE = 25,
FILEGROWTH = 5MB
)

*/
---- FIN TEORIA CREACION BD ---

------ PARTICIONAMIENTO -------
/*
PARTICIONAMIENTO DE TABLAS SE RECOMIENTA PARA REDUCRI EL TIEMPO DE RESPUESTA Y CARGA DE DATOS DE UNA TABLA, OFRECE CONTROL, MEJROA EL RENDIMIENTO Y FACILITA LA GESTION

PARTICIONAMIENTO VERTICAL SE USA PARA FACILITAR LAS CONSULTAS

PARTICIONAMIENTO HORIZONTAL divide una tabla en múltiples tablas que contienen el mismo número de columnas, pero menos filas.

*/
------ PARTICIONAMIENTO -------

---------- INDICES ------------
/*

INDICE CLUSTERED Se ordenan físicamente en el disco dependiendo del criterio que se aplica ya sea de manera ascendente o descendente.

HEAP Los registros se ingresaran en el primer espacio disponible dentro de las páginas pertenecientes a la tabla.

INDICE NONCLUSTERED crean una estructura adicional y sobre dicha estructura creada se ordenan, Se crean para mejorar el rendimiento de las consultas utilizadas con frecuencia no cubiertas por el índice clustered

*/
---------- INDICES ------------

-- TEORIA FILEGROUPS Y PARTICIONAMIENTO --
/*
 .MDF:DATOS DE LAS TABLAS
 .NDF:ARCHIVO SECUNDARIOD DE DATOS DE LAS TABLAS
 .LDF:CONTIENE LAS CONSULTAS, TRANSACCIONES

-- CREACION DE PARTICION 
CREATE PARTITION FUNCTION Particion01 (int)
AS RANGE right
FOR VALUES (1,100,1000)

-- DEFINICION DE ESQUEMA 3 FILEGROUPS
CREATE PARTITION SCHEME Esquema01
AS PARTITION Particion01
TO ([PRIMARY], Fg01, Fg02, Fg03)

-- AL CREAR LA TABLE AGREGAR AL FINAL 'on Esquema01(IDTABLA)'
-- CONSULTAR ESTRUCTURA DE TABLA
DECLARE @TableName sysname = 'Countries';
SELECT OBJECT_NAME([object_id]) AS table_name, p.partition_number, fg.name, p.rows
FROM sys.partitions p INNER JOIN sys.allocation_units au ON au.container_id = p.hobt_id
INNER JOIN sys.filegroups fg ON fg.data_space_id = au.data_space_id
WHERE p.object_id = OBJECT_ID(@TableName)
-- CONOCER ESTADO DE BD
SP_HELPDB BDNAME
*/
---- FIN TEORIA FILEGROUPS -----

------ TEORIA DE INDICES -------
/*
INDICE CLUSTER: SE ORDENAN FISICAMENTE EN DISCO
HEAP: NUEVOS REGISTROS SE INSERTAR EN EL PRIMER ESPACIO DISPONIBLE
INDICE NON CLUSTER: NO PUEDEN ORDENARSE EN DISCO, CREAN UNA ESTRUCTURA LOGICA

USE DATABASENAME
CREATE NONCLUSTERED INDEX IX_Contact_Countryname_Formalname_Transact
ON Countries (FormalName ASC,CountryName ASC) INCLUDE (Region,Subregion)
WITH (FILLFACTOR = 80, ONLINE = ON)

<= 30% de fragmentación = Reorganizar
ALTER INDEX index_name ON table_name REORGANIZE
>= 30% de fragmentación = Volver a reconstruir
ALTER INDEX index_name ON table_name REBUILD
*/
---- FIN TEORIA DE INDICES -----

---- TEORIA DE INTEGRIDAD ------
/*
CONSTRAINTS
DEFAULT: ESPECIFICA VALOR POR DEFECTO DE UNA COLUMNA
CHECK: VALIDA VALORES PERMITIDOS POR COLUMNA
FOREIGN KEY: VALORES QUE DEBEN EXISTIR
NULL: PERMITE VACIOS
PRIMARY KEY: INDICA ID
UNIQUE: NO PERMITE DUPLICACION DE CLAVE NO PRINCIPALES

create table PRESTAMO
(
codOper char(7) not null,
idMatBiblio varchar(20) not null,
idUsuario char(8) not null,
fechaP smalldatetime not null,
fechaD smalldatetime not null,
ndias int not null,
constraint PK_PRESTAMO_codOper PRIMARY KEY (codOper),
constraint FK_PRESTAMO_idMatBiblio FOREIGN KEY (idMatBiblio) REFERENCES MAT_BIBLIO(idMatBiblio),
constraint FK_PRESTAMO_idUsuario FOREIGN KEY (idUsuario) REFERENCES USUARIO(idUsuario)
)

-- ELEMINAR RELACION 
ALTER TABLE [HumanResources].[Employee] DROP CONSTRAINT [CK_Employee_Gender]
*/
--- FIN TEORIA DE INTEGRIDAD ---

---------- TEORIA XML ----------
/*
 COMANDO: for xml + :PARAMETRO:
 RAW: MUESTRA LA INFORMACION COMPLETA POR FILA
 AUTO: MUESTRA LA INFORMACION AGRUPADA POR ID
 EXPLICIT: PERMITE EDITAR COMO ES LA ESTRUCTURA [1 AS TAG, !1!,!Element]
 PATH: MANTIENE LA ESTRUCTURA DE LA TABLA SEPARANDO POR ATRIBUTO
*/
-- CREACION DE TABLA MEDIANTE XML
/*declare @doc int
declare @xmldoc nvarchar(1000)
set @xmldoc = 
N'<ROOT>
	<Cliente IDCliente="UPC" Nombre="NOMBREUPC">
		<Pedido IDPedido="10283" IDCliente="UPC" IDEmpleado="3"
		Fecha="2018-10-19T:00:00">
		<PedidoDetalle IDProducto="72" Cantidad="3"/>
		</Pedido>
	</Cliente>
</ROOT>'
-- crea xml
exec SP_XML_PREPAREDOCUMENT @doc output, @xmldoc
select * from openxml (@doc,'/ROOT/Cliente',1)
WITH (IDCliente varchar(10),
Nombre varchar(42))
exec SP_XML_REMOVEDOCUMENT @doc

 XQUERY ROUND,CONCAT,COUNT,MIN,MAX,AVG,SUM()

DECLARE @DATAXML AS XML;
SET @DATAXML = '<Cursos>
	<Curso id="5" >
		<Nombre>base de datos</Nombre>
	</Curso>
	<Curso id="10" >
		<Nombre>sql server</Nombre>
		<Codigo>82</Codigo>
	</Curso>
</Cursos>';
Select 
@DATAXML.query('*') as InfoCompleta,
@DATAXML.query('data(*)') as DataCompleta,
@DATAXML.query('data(Cursos/Curso[@id=10])') as DataElemento,
@DATAXML.query('data(Cursos/Curso/Codigo)') as DataElemento

 FUNCION FLWOR
DECLARE @DATAXML AS XML;
SET @DATAXML = '<Ventas>
	<Cliente id="5">
		<Pedido total="906.00" />
		<Pedido total="920.00" />
	</Cliente>
	<Cliente id="10">
		<Pedido total="722.00" />
	</Cliente>
</Ventas>';
SELECT @DATAXML.query('
for $i in //Cliente
return
<Pedidos>
	<NroPedidos>{count($i/Pedido)}</NroPedidos>
	<VentaPedidos>{sum($i/Pedido/@total)}</VentaPedidos>
</Pedidos>
');

 CREACION DE INDICES XML
 CREATE PRIMARY XML INDEX XMLPATH_JOBCANDIDATE_RESUME 
 ON HUMANRESOURCES.JOBCANDIDATE(Resume)
 CREATE XML INDEX XMLPATH_JOBCANDIDATE_RESUME2 ON HUMANRESOURCES.JOBCANDIDATE(Resume)
 USING XML INDEX XMLPATH_JOBCANDIDATE_RESUME FOR PATH;
 GO

 TABLA ASOCIADA A XML
CREATE TABLE HumanResources.EmployeeResume
(EmployeeID int,
Resume xml (EmployeeResumeSchemaCollection))

INSERT INTO HumanResources.EmployeeResume
VALUES
(1,
'<?xml version="1.0" ?>
<resume xmlns="http://schemas.adventure-works.com/EmployeeResume">
<name>Guy Gilbert</name>
<employmentHistory>
<employer endDate="2000-07-07">Northwind Traders</employer>
<employer>Adventure Works</employer>
</employmentHistory>
</resume>')
*/
---------- FIN TEORIA XML ----------

----DB creada desde interfaz grafica----
use EjemploTrigger
go
CREATE TABLE Employee_Test
(
Emp_ID INT Identity,
Emp_name Varchar(100),
Emp_Sal Decimal (10,2)
)

INSERT INTO Employee_Test VALUES ('Anees',1000);
INSERT INTO Employee_Test VALUES ('Rick',1200);
INSERT INTO Employee_Test VALUES ('John',1100);
INSERT INTO Employee_Test VALUES ('Stephen',1300);
INSERT INTO Employee_Test VALUES ('Maria',1400);

select * from Employee_Test

CREATE TABLE Employee_Test_Audit
(
Emp_ID int,
Emp_name varchar(100),
Emp_Sal decimal (10,2),
Audit_Action varchar(100),
Audit_Timestamp datetime
)
go
------------------------------------------

------After Triggers------
-----After Insert Trigger-----
CREATE TRIGGER trgAfterInsert ON [dbo].[Employee_Test] 
FOR INSERT
AS
	declare @empid int;
	declare @empname varchar(100);
	declare @empsal decimal(10,2);
	declare @audit_action varchar(100);

	select @empid=i.Emp_ID from inserted i;	
	select @empname=i.Emp_Name from inserted i;	
	select @empsal=i.Emp_Sal from inserted i;	
	set @audit_action='Inserted Record -- After Insert Trigger.';

	insert into Employee_Test_Audit
           (Emp_ID,Emp_Name,Emp_Sal,Audit_Action,Audit_Timestamp) 
	values(@empid,@empname,@empsal,@audit_action,getdate());

	PRINT 'AFTER INSERT trigger fired.'
GO

insert into Employee_Test values('Chris',1500);
select * from Employee_Test_Audit
go
----- AFTER UPDATE Trigger-------
CREATE TRIGGER trgAfterUpdate ON [dbo].[Employee_Test] 
FOR UPDATE
AS
	declare @empid int;
	declare @empname varchar(100);
	declare @empsal decimal(10,2);
	declare @audit_action varchar(100);

	select @empid=i.Emp_ID from inserted i;	
	select @empname=i.Emp_Name from inserted i;	
	select @empsal=i.Emp_Sal from inserted i;	
	
	if update(Emp_Name)
		set @audit_action='Updated Record -- After Update Trigger.';
	if update(Emp_Sal)
		set @audit_action='Updated Record -- After Update Trigger.';

	insert into Employee_Test_Audit(Emp_ID,Emp_Name,Emp_Sal,Audit_Action,Audit_Timestamp) 
	values(@empid,@empname,@empsal,@audit_action,getdate());

	PRINT 'AFTER UPDATE Trigger fired.'
GO

update Employee_Test set Emp_Sal=1550 where Emp_ID=6
select * from Employee_Test_Audit
go
------AFTER DELETE Trigger----
CREATE TRIGGER trgAfterDelete ON [dbo].[Employee_Test] 
AFTER DELETE
AS
	declare @empid int;
	declare @empname varchar(100);
	declare @empsal decimal(10,2);
	declare @audit_action varchar(100);

	select @empid=d.Emp_ID from deleted d;	
	select @empname=d.Emp_Name from deleted d;	
	select @empsal=d.Emp_Sal from deleted d;	
	set @audit_action='Deleted -- After Delete Trigger.';

	insert into Employee_Test_Audit
(Emp_ID,Emp_Name,Emp_Sal,Audit_Action,Audit_Timestamp) 
	values(@empid,@empname,@empsal,@audit_action,getdate());

	PRINT 'AFTER DELETE TRIGGER fired.'
GO

delete from Employee_Test where Emp_ID = 7 /*poner ultimo ID añadido*/
select * from Employee_Test_Audit

use NORTHWND
go
------- 
CREATE VIEW [Brazil Customers] AS
SELECT CompanyName, ContactName
FROM Customers
WHERE Country = 'Brazil';
GO

SELECT * FROM [Brazil Customers]
go
-------
CREATE VIEW [Products Above Average Price] AS
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products)
go

SELECT * FROM [Products Above Average Price]
go
-----
create view [Less than ten units] as
select ProductName, UnitsInStock
from Products
where UnitsInStock < 10
go

select * from [Less than ten units] 

--------------Stored Procedures-------------
use NORTHWND
go
select /*CustomerID, CompanyName, ContactName, Address, City, PostalCode, Country*/ * from Customers
--------Un Parametro---------
use NORTHWND
go
create procedure SelectAllCustomers @City nvarchar(30)
as
select * from Customers where City = @City
go

exec SelectAllCustomers @City = 'London';
-----------------Un Parametro(2)-----------------------------
use NORTHWND
go
create procedure SelectWithLetter @Letter nvarchar(1)
as
select CompanyName from Customers where SUBSTRING(CompanyName,1,1) = @Letter
go

exec SelectWithLetter @Letter = 'A'
-------Multiples Parametros-------
use NORTHWND
go
CREATE PROCEDURE SelectAllCustomersPstal @City nvarchar(30) , @PostalCode nvarchar(10)
AS
SELECT * FROM Customers WHERE City = @City AND PostalCode = @PostalCode
GO

exec SelectAllCustomersPstal @City = 'London' , @PostalCode = 'WA1 1DP'

-- FULL BACKUP IMPLICITAMENTE
BACKUP DATABASE [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksFULL.bak'
WITH NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - Full database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10

-- TRANSACTIONAL BACKUP 
BACKUP LOG [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksT3.trn'
WITH NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - transactional database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
-- ** STATS 10 -> CADA 10% ESCRIBE EL PROGRESO DEL BACKUP

-- DIFERENCIAL BACKUP 
BACKUP DATABASE [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksDIFF2.trn'
WITH DIFFERENTIAL,NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - transactional database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
-- ** STATS 10 -> CADA 10% ESCRIBE EL PROGRESO DEL BACKUP

-- CAMBIAR EL TIPO DE RECUPERACION DE LA BD
use master
go
ALTER DATABASE AdventureWorks2014 set recovery simple 
go

DECLARE @BD VARCHAR(250)
SELECT @BD = 'E:Backups\AdventureWorks2014X' +
CONVERT(VARCHAR(20),GETDATE(),112) +
LEFT(REPLACE(CONVERT(VARCHAR(10), GETDATE(),114),
':',''),4) + '.bak'
BACKUP DATABASE AdventureWorks2014
TO DISK = @BD WITH INIT;


-- WITH RECOVERY: SOLO LEVANTA FULL, NO DIFERENCIAL NI TRANSACCIONAL
-- WITH NO RECOVERY: SE LEVANTA LA BD PERO QUEDA A LA ESPERA DE MAS BACKUPS

------------------------ E J E R C I C I O S ------------------------------

BACKUP DATABASE [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksFULL.bak'
WITH NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - Full database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO

create table pais
(
idpais int,
nombre varchar(20)
)
GO
-- TRANSACCIONAL
BACKUP LOG [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksT1.trn'
WITH NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - transactional database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO
create table ciudades
(
idciudad int,
nombre varchar(20)
)
GO
-- DIFERENCIAL
BACKUP DATABASE [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksDIFF1.trn'
WITH DIFFERENTIAL,NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - transactional database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO
create table departamentos
(
iddepa int,
nombre varchar(20)
)
GO
--TRANSACCIONAL 2
BACKUP LOG [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksT2.trn'
WITH NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - transactional database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO
insert into pais values (1,'pais1')
insert into pais values (2,'pais2')
GO
-- DIFERENCIAL 2
BACKUP DATABASE [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksDIFF2.trn'
WITH DIFFERENTIAL,NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - transactional database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO
insert into departamentos values (1,'depa1')
insert into departamentos values (2,'depa2')
GO
--TRANSACCIONAL 3
BACKUP LOG [AdventureWorks2014]
TO DISK = 'E:\Backups\AdventureWorksT3.trn'
WITH NOFORMAT, NOINIT, NAME = 'AdventureWorks2014 - transactional database backup :D',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO

-- SELECT * FROM departamentos


use AdventureWorks2014
go
--------Funcion Escalar------
IF OBJECT_ID (N'dbo.ufnGetInventoryStock', N'FN') IS NOT NULL  
    DROP FUNCTION ufnGetInventoryStock;  
GO 
CREATE FUNCTION dbo.ufnGetInventoryStock(@ProductID int)  
RETURNS int   
AS 
BEGIN  
    DECLARE @ret int;  
    SELECT @ret = SUM(p.Quantity)   
    FROM Production.ProductInventory p   
    WHERE p.ProductID = @ProductID   
        AND p.LocationID = '6';  
     IF (@ret IS NULL)   
        SET @ret = 0;  
    RETURN @ret;  
END
go 

SELECT ProductModelID, Name, dbo.ufnGetInventoryStock(ProductID)AS CurrentSupply  
FROM Production.Product  
WHERE ProductModelID BETWEEN 75 and 80;
----------Funciones de tablas---------
IF OBJECT_ID (N'Sales.ufn_SalesByStore', N'IF') IS NOT NULL  
    DROP FUNCTION Sales.ufn_SalesByStore;  
GO 

CREATE FUNCTION Sales.ufn_SalesByStore (@storeid int)  
RETURNS TABLE  
AS  
RETURN   
(  
    SELECT P.ProductID, P.Name, SUM(SD.LineTotal) AS 'Total'  
    FROM Production.Product AS P   
    JOIN Sales.SalesOrderDetail AS SD ON SD.ProductID = P.ProductID  
    JOIN Sales.SalesOrderHeader AS SH ON SH.SalesOrderID = SD.SalesOrderID  
    JOIN Sales.Customer AS C ON SH.CustomerID = C.CustomerID  
    WHERE C.StoreID = @storeid  
    GROUP BY P.ProductID, P.Name  
)
go

SELECT * FROM Sales.ufn_SalesByStore (602)

-------------
IF OBJECT_ID (N'dbo.ufn_FindReports', N'TF') IS NOT NULL  
    DROP FUNCTION dbo.ufn_FindReports;  
GO  

CREATE FUNCTION dbo.ufn_FindReports (@InEmpID INTEGER)  
RETURNS @retFindReports TABLE   
(  
    EmployeeID int primary key NOT NULL,  
    FirstName nvarchar(255) NOT NULL,  
    LastName nvarchar(255) NOT NULL,  
    JobTitle nvarchar(50) NOT NULL,  
    RecursionLevel int NOT NULL  
)   
AS  
BEGIN  
WITH EMP_cte(EmployeeID, OrganizationNode, FirstName, LastName, JobTitle, RecursionLevel)   
    AS (  
        SELECT e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, 0   
        FROM HumanResources.Employee e   
INNER JOIN Person.Person p   
ON p.BusinessEntityID = e.BusinessEntityID  
        WHERE e.BusinessEntityID = @InEmpID  
        UNION ALL  
        SELECT e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, RecursionLevel + 1   
        FROM HumanResources.Employee e   
            INNER JOIN EMP_cte  
            ON e.OrganizationNode.GetAncestor(1) = EMP_cte.OrganizationNode  
INNER JOIN Person.Person p   
ON p.BusinessEntityID = e.BusinessEntityID  
        )    
   INSERT @retFindReports  
   SELECT EmployeeID, FirstName, LastName, JobTitle, RecursionLevel  
   FROM EMP_cte   
   RETURN  
END 
GO

SELECT EmployeeID, FirstName, LastName, JobTitle, RecursionLevel  
FROM dbo.ufn_FindReports(1)

-------------------FUNCIONES DE SISTEMA----------
----SQL Server String Functions------
use NORTHWND
go
SELECT ASCII(ContactName) AS NumCodeOfFirstChar
FROM Customers;
----SQL Server Math/Numeric Functions----
SELECT COUNT(ProductID) AS NumberOfProducts FROM Products;
----SQL Server Date Functions-----
SELECT CURRENT_TIMESTAMP;
----SQL Server Advanced Functions---
SELECT SESSION_USER;


