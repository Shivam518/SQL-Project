USE [shivam]
GO
/****** Object:  StoredProcedure [dbo].[Creation_of_file]    Script Date: 19-07-2020 11:31:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[Creation_of_file]
as
begin

	set nocount on 

	declare 
			@sql1				nvarchar(200),
			@File_Path			nvarchar(200),
			@File_Name			nvarchar(30),
			@max_counter		int ,
			@counter			int,
			@Country_Name		nvarchar(100);

	--max number of countery available in customer table
	set @max_counter =(Select Max(count_id) from Customer)

	--starting counter value 1 
	set @counter=1

	---loop for creationg file as per number of country available
		while @counter<=@max_counter
			begin
				---Using sqlcmd to store data available in one country 
				set @sql1=' sqlcmd  -E -d shivam  -S "DESKTOP-D2M81Q0" -s, -Q "select * from dbo.Customer where Count_id ='+ cast(@counter as varchar(30))+'"'

				
				--To get name of Country 
				set @Country_Name=(select Country_name from country where Count_id=@counter)

				--file path 
				set @File_Path ='F:\'

				--File Name 
				set @File_Name ='File_'+@Country_Name+'.csv'

				--command to create file
				set @sql1=@sql1+ ' >'+@File_Path+@File_Name 
				
				exec master.dbo.xp_Cmdshell @sql1

				set @counter=@counter+1
		end
end

