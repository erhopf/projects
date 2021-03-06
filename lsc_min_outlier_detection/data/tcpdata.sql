if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tcpdata]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tcpdata]
GO

CREATE TABLE [dbo].[tcpdata] (
	[seqnum] [numeric](18, 0) NULL ,
	[Col002] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[datestarted] [datetime] NULL ,
	[timestarted] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[duration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[protocol] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[sourceport] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[destport] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[sourceip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[destip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[flag] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[attacktype] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[datetimestarted] [datetime] NULL 
) ON [PRIMARY]
GO

