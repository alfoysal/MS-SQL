
USE master
DROP DATABASE IF EXISTS Bus_Ticket_Reservation;
GO   
USE master;
create database Bus_Ticket_Reservation
go

ALTER DATABASE Bus_Ticket_Reservation
MODIFY FILE(NAME=N'Bus_Ticket_Reservation',SIZE=10MB,MAXSIZE=UNLIMITED,FILEGROWTH=5MB)
GO

ALTER DATABASE Bus_Ticket_Reservation
MODIFY FILE(NAME=N'Bus_Ticket_Reservation_Log',SIZE=9MB,MAXSIZE=100MB,FILEGROWTH=512KB)
GO

use Bus_Ticket_Reservation
GO

CREATE SCHEMA king
Go
use Bus_Ticket_Reservation
create Table king.EmpCategory
(
EmpCatID int   primary key IDENTITY(1,1), 
Category  varchar(15)  Not null UNIQUE ,
)
GO
use Bus_Ticket_Reservation
create Table king.Employee
(
	EmployeeID					 int			primary key IDENTITY(101,1),
	EmployeeName				 varchar(25)					 Not null,
	EmpCatID                     int            foreign Key references king.EmpCategory(EmpCatID),
	CellPhone					 nvarchar(18)					 Not null,
	Designation					 varchar(20)                         Not null,
)
go

use Bus_Ticket_Reservation
create Table king.BusRoute
(
	RouteID                  int               primary key       identity,
	FromLocation         varchar(11),
	ToDestination            varchar(11)
)
go

use Bus_Ticket_Reservation
create Table king.BusCategory
(
	BusCatID int primary key  Identity     ,
	BusCatName  nvarchar(11)        Not null UNIQUE,
)
GO
--DROP TABLE king.BusCategory
use Bus_Ticket_Reservation
create Table king.Bus
(
	BusID int primary key Identity(101,1) ,
	BusCatID int  foreign Key references king.BusCategory(BusCatID),
	BusNumber nvarchar(25) UNIQUE,
	NoOfSeats int,
	NoOfActiveSeat int ,
	TPrice Money ,
	IsActive bit DEFAULT 1,
	Remarks       varchar(11) ,
	CHECK(NoOfActiveSeat <= NoOfSeats)
)
GO

USE Bus_Ticket_Reservation;
IF OBJECT_ID('king.Schedule') IS NOT NULL
DROP TABLE king.Schedule;
use Bus_Ticket_Reservation
create Table king.Schedule
(
	ScheduleID int primary key IDENTITY(1,1),
	RouteID int FOREIGN KEY REFERENCES king.BusRoute(RouteID),
	BusID int FOREIGN KEY REFERENCES king.Bus(BusID),
	DepartureDate Date,
	DepartureTime time,
	NoOfAvailableSeat int,
	ApproxArrivalTime Time,
	
	Driver int FOREIGN KEY REFERENCES king.Employee(EmployeeID),
	Superviser int FOREIGN KEY REFERENCES king.Employee(EmployeeID),
	Helper int FOREIGN KEY REFERENCES king.Employee(EmployeeID),
	ScheduleCreatedBy int FOREIGN KEY REFERENCES king.Employee(EmployeeID),
)
go

use Bus_Ticket_Reservation
create Table king.TicketPurchase
(
	TicketPurchaseID int Primary key identity,
	BusID int FOREIGN KEY REFERENCES king.Bus(BusID),
	ScheduleID int FOREIGN KEY REFERENCES king.Schedule(ScheduleID),
	PassengerName nvarchar(25)  not null ,
	PassengerPhone nvarchar(18) not null ,
	Email				varchar(max)				Check(Email LIKE '%_@__%.__%' or Email LIKE 'None')		Default 'None',
	NID nvarchar(20)  null,
	JourneyDate Date,
	BookedSeatNo nvarchar(3),
	TotalSeat int,
	UnitFare money,
	Vat decimal,
	ISConfirm bit,
	AdvanceAmount money,
	DueAmount money
)
GO

CREATE FUNCTION king.fn_CellNoFormat 
(
	@cellNo varchar(18)
)
RETURNS varchar(17)
AS
BEGIN
	IF LEN(@cellNo) = 11 
		BEGIN
			DECLARE @phoneNo varchar(17)
			SET @phoneNo = '(+88)'+ SUBSTRING(@cellNo, 1,5) + '-' + SUBSTRING(@cellNo, 6,6)
		END
	ELSE 
	BEGIN 
		SET @phoneNo = 'Invalid Number' 
	END
	RETURN @phoneNo
END
GO

--==========Insert Value===============
INSERT INTO king.EmpCategory VALUES ('Manager'),('CounterManager'),('Superviser'),('Driver'),('Helper')

GO
INSERT INTO king.Employee VALUES ('Rhamat Ali',2,king.fn_CellNoFormat('01885103968'),'CounterManager'),
                                 ('Eyakub Ali',2,king.fn_CellNoFormat('01788203968'),'CounterManager'),
								 ('Eyasin Ali',3,king.fn_CellNoFormat('01798203968'),'Superviser'),
								 ('Arshad Ali',4,king.fn_CellNoFormat('01748203968'),'Driver'),
								 ('Asgar Ali',5,king.fn_CellNoFormat('01728203968'),'Helper'),
                                 ('Amzad Ali',1,king.fn_CellNoFormat('01955203768'),'Manager'),
                                 ('Hasmat Ali',2,king.fn_CellNoFormat('01688203868'),'CounterManager'),
								 ('Babor Ali',3,king.fn_CellNoFormat('01588203988'),'Superviser'),
								 ('Azmol Ali',4,king.fn_CellNoFormat('01908204968'),'Driver'),
								 ('Nesar Ali',2,king.fn_CellNoFormat('01788203968'),'Helper')
GO

INSERT INTO king.BusRoute VALUES 
                                ('Chattogram','Dhaka'),
								('Dhaka','Chattogram')
GO

INSERT INTO king.BusCategory VALUES ('AC'),
                                    ('NON-AC')
GO

INSERT INTO king.Bus(BusCatID,BusNumber,NoOfSeats,NoOfActiveSeat,TPrice,IsActive,Remarks) 
VALUES (1,'ChattaMetro-KA-23105',52,50,400,1,'ok'),
       (2,'ChattaMetro-KHA-23106',52,50,400,1,'ok'),
	   (2,'ChattaMetro-GA-23107',52,52,400,1,'ok')
GO

INSERT INTO king.Schedule VALUES(1,101,'12/06/2018','5:20',104,'1:20',104,103,105,101),
								(1,102,'12/06/2018','6:20',50,'2:20',104,108,110,101)
GO
INSERT INTO king.TicketPurchase (BusID,ScheduleID,PassengerName,PassengerPhone,Email,NID,JourneyDate,BookedSeatNo,TotalSeat,UnitFare,Vat,ISConfirm,DueAmount)
VALUES(101,1,'Abdullah Al Foysal',king.fn_CellNoFormat('01885103968'),'foysal_nstu@yahoo.com','19923567289138267','12/06/2018','A1',1,400.00,0.10,1,0.00),
      (101,1,'Abdullah Al Noman',king.fn_CellNoFormat('01675103968'),'noman_cu@hotmail.com','19933567289136867','12/06/2018','A2',1,400.00,0.10,1,0.00),
	  (101,1,'Belal Uddin',king.fn_CellNoFormat('01685103968'),'noman_cu@hotmail.com','','12/06/2018','B1',1,400.00,0.10,1,0.00)


GO
----STORE PROCEDURE-----
CREATE PROC sp_Employee
( 
	@employeeid					 int ,
	@employeename				 varchar(25),
	@empcatid                     int ,
	@cellphone					 nvarchar(18),
	@designation					 varchar(20),
	@operation                      varchar (20)
)
AS
SET NOCOUNT ON
BEGIN
		BEGIN TRY
			BEGIN TRAN

				if(@operation = 'Insert')
					BEGIN
						INSERT INTO king.Employee (EmployeeName,EmpCatID ,CellPhone,Designation)
						VALUES (@employeename, @empcatid,king.fn_CellNoFormat(@cellphone) ,@designation )

					END

					ELSE IF(@operation = 'Update')
					BEGIN
						Update king.Employee set  EmployeeName=@employeename ,  EmpCatID=@empcatid ,CellPhone=king.fn_CellNoFormat(@cellphone) ,Designation =@designation  Where  EmployeeID=@employeeid
					END
				if(@operation = 'Delete')
					BEGIN
						DELETE FROM king.Employee WHERE  EmployeeID=@employeeid
					END

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			ROLLBACK TRAN
		END CATCH
	END
go
EXEC sp_Employee 101,'Iman Ali',2,'01782345784','Counter Manager','Insert'
SELECT * FROM king.Employee
--EXEC sp_Employee 112,'Iman Ali',2,'01782345784','Counter Manager','Delete'
--SELECT * FROM king.Employee
GO
Create Trigger tr_EmployeeTrigger ON king.Employee
For Insert, Update, Delete
As
Begin
	if(@@ROWCOUNT) < 2
	Begin
		Print 'Successfully Inserted !!!'
	End
	Else
	Begin
		Rollback Tran
		Print 'There is no permission. !!!'
	End
End
Go
--DROP VIEW king.vw_PassengerReport
CREATE VIEW king.vw_PassengerReport

AS
SELECT t.PassengerName,t.PassengerPhone,t.Email,t.NID,t.JourneyDate,s.DepartureTime,t.TotalSeat,s.ApproxArrivalTime
FROM king.Schedule s
JOIN king.TicketPurchase t
on s.ScheduleID=t.ScheduleID
GO

Alter VIEW king.vw_PassengerReport
with Schemabinding
AS
SELECT t.PassengerName,t.PassengerPhone,t.Email,t.NID,t.JourneyDate,s.DepartureTime,t.TotalSeat,s.ApproxArrivalTime
FROM king.Schedule s
JOIN king.TicketPurchase t
on s.ScheduleID=t.ScheduleID
go
select * from king.vw_PassengerReport


select * from king.TicketPurchase
select * from king.Schedule

--,(UnitFare*CAST(TotalSeat AS money)+(UnitFare*CAST(TotalSeat AS money)*CAST(Vat AS money))) as [Total Fare]
-----Not----
Select * From king.Employee
Where NOT CellPhone Like('_____018%')
Go
---------Over @COUNT AND COUNT ALL-----
Select BusID,PassengerName,COUNT(TotalSeat)AS 'Selected TotalSeat'
,COUNT (*) OVER () AS 'Count All'
FROM king.TicketPurchase WHERE TicketPurchaseID in (1,2)
Group by BusID,PassengerName
Go
-----------------
------Is Null----
Select PassengerName,PassengerPhone
From king.TicketPurchase Where NID IS  NULL
Go
----IS not NULL----
Select PassengerName,PassengerPhone
From king.TicketPurchase Where NID IS NOT  NULL
Go
----EXCEPT-----
Select ScheduleID
From king.TicketPurchase
EXCEPT
Select ScheduleID
From king.Schedule
Go

---------Union all 
SELECT BusID
FROM king.Bus
UNION ALL
SELECT BusID
FROM king.TicketPurchase
Go

--------Intersect
Select ScheduleID
From king.TicketPurchase
INTERSECT
Select ScheduleID
From king.Schedule
Go
---
----DISTINCT----
Select DISTINCT EmployeeName
From king.Employee
GO
SELECT * FROM king.EmpCategory
SELECT * FROM king.Employee
SELECT * FROM king.BusRoute
SELECT * FROM king.BusCategory
SELECT * FROM king.Bus
SELECT * FROM king.Schedule
SELECT * FROM king.TicketPurchase
SELECT * FROM king.vw_PassengerReport
GO