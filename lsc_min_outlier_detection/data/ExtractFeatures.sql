/****** Object:  Stored Procedure dbo.ExtractFeatures    Script Date: 5/1/2006 3:14:09 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtractFeatures]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtractFeatures]
GO

/****** Object:  Table [dbo].[FeatureTable]    Script Date: 5/1/2006 3:14:09 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FeatureTable]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[FeatureTable]
GO

/****** Object:  Table [dbo].[FeatureTable]    Script Date: 5/1/2006 3:14:10 PM ******/
CREATE TABLE [dbo].[FeatureTable] (
	[SeqNum] [numeric](18, 0) NULL ,
	[datetimestarted] [datetime] NULL ,
	[count_src] [numeric](18, 0) NULL ,
	[count_src_ip] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[count_dest] [numeric](18, 0) NULL ,
	[count_dest_ip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[count_serv_src] [numeric](18, 0) NULL ,
	[count_serv_src_ip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[count_serv_dest] [numeric](18, 0) NULL ,
	[count_serv_dest_ip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[count_src_dest] [numeric](18, 0) NULL ,
	[count_src_dest_ip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO


SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

/****** Object:  Stored Procedure dbo.ExtractFeatures    Script Date: 5/1/2006 3:14:10 PM ******/
CREATE PROCEDURE [dbo].[ExtractFeatures] AS
declare @cmd varchar(1000), @ip varchar(1000), @conn int, @pcount_src int, @psource_ip varchar(100)
declare @vseqnum int, @vprotocol varchar(100), @vsourceip varchar(100), @vdestip varchar(100), @vsourceport varchar(100), 
	@vdestport varchar(100), @vdatetimestarted datetime, @rdatetime datetime
DECLARE tcp_Cursor CURSOR FOR
SELECT distinct /*seqnum, protocol, sourceip, destip, sourceport, destport,*/ datetimestarted
FROM [dbo].[tcpdata]

BEGIN

create table #temptable (sourceip varchar(100), destip varchar(100), sourceport varchar(100), destport varchar(100), NumConnections int)

OPEN tcp_Cursor

FETCH NEXT FROM tcp_Cursor into /*@vseqnum, @vprotocol, @vsourceip, @vdestip, @vsourceport, @vdestport,*/ @vdatetimestarted
WHILE @@FETCH_STATUS = 0 
BEGIN
	insert into FeatureTable(datetimestarted)
	values(@vdatetimestarted)

	insert into #temptable
	select sourceip,  destip,  sourceport , destport, count(seqnum) NumConnections
	from [dbo].[tcpdata]
	where datetimestarted > dateadd(minute,-1,@vdatetimestarted) and datetimestarted<=  @vdatetimestarted
	group by sourceip, sourceport, destip,  destport
	with cube
	
	select @conn=tempb.maxconn, @ip=sourceip
	from  #temptable, (select  max(NumConnections) maxconn from #temptable
				where sourceip is not null
				and destip is null
				and destport is null
				and sourceport is not null) as tempb
	where sourceip is not null
	and destip is null
	and destport is null
	and sourceport is not null
	and NumConnections=tempb.maxconn

	update FeatureTable
	set count_src=@conn, count_src_ip =@ip
	where datetimestarted=@vdatetimestarted

	select @conn=tempb.maxconn, @ip=destip
	from  #temptable, (select  max(NumConnections) maxconn from #temptable
				where sourceip is null
				and destip is not null
				and destport is not null
				and sourceport is null) as tempb
	where sourceip is null
	and destip is not null
	and destport is not null
	and sourceport is null
	and NumConnections=tempb.maxconn

	update FeatureTable 
	set count_dest=@conn, count_dest_ip = @ip
	where datetimestarted=@vdatetimestarted


	select distinct @conn=tempb.maxconn, @ip= sourceip
	from  #temptable, (select  max(NumConnections) maxconn from #temptable
				where sourceip is not null
				and destip is null
				and destport is null
				and sourceport is null) as tempb
	where sourceip is not null
	and destip is null
	and destport is null
	and sourceport is null
	and NumConnections=tempb.maxconn

	update FeatureTable 
	set count_serv_src = @conn, count_serv_src_ip=@ip
	where datetimestarted=@vdatetimestarted

	select distinct @conn=tempb.maxconn, @ip=destip
	from  #temptable, (select  max(NumConnections) maxconn from #temptable
				where sourceip is null
				and destip is not null
				and destport is null
				and sourceport is null) as tempb
	where sourceip is null
	and destip is not null
	and destport is null
	and sourceport is null
	and NumConnections=tempb.maxconn
	
	update FeatureTable 
	set count_serv_dest = @conn, count_serv_dest_ip=@ip
	where datetimestarted=@vdatetimestarted

	select distinct @conn=tempb.maxconn, @ip=destip
	from  #temptable, (select  max(NumConnections) maxconn from #temptable
				where sourceip is not null
				and destip is not null
				and destport is null
				and sourceport is null) as tempb
	where sourceip is not null
	and destip is not null
	and destport is null
	and sourceport is null
	and NumConnections=tempb.maxconn
	
	update FeatureTable 
	set count_src_dest = @conn, count_src_dest_ip=@ip
	where datetimestarted=@vdatetimestarted

	delete from #temptable

    FETCH NEXT FROM tcp_Cursor into /*@vseqnum, @vprotocol, @vsourceip, @vdestip, @vsourceport, @vdestport,*/ @vdatetimestarted
END

CLOSE tcp_Cursor
DEALLOCATE tcp_Cursor

drop table #temptable

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

Execute ExtractFeatures
Go