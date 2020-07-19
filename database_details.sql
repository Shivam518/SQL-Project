--select * from ##tbl_Database_info
-- exec USP_Database_Detail 'shivam'

Alter Proc USP_Database_Detail
	(
		@Database varchar(50)
	)
as
begin
	
	SET NOCOUNT ON
	--Conditon to Check database exist or not 
	if exists(select * from sys.databases where name=@Database)
		begin
			---Checking if table already exist in temp db
			IF OBJECT_ID('tempdb..##tbl_Database_info') IS NOT NULL
				DROP TABLE ##tbl_Database_info

			--Creating temp table to store table , columumn and count null and not null
			create table ##tbl_Database_info(
												table_name varchar(50),
												column_name varchar(50),
												DataType varchar(30),
												not_null int,
												null1 int
											)
			declare 
				@table_query			nvarchar(200),
				@Table_Name 			varchar(50),
				@Column_Qerry			nvarchar(200),
				@col_name				varchar(50),
				@Query_For_Not_Null		nvarchar(100),
				@Querry_For_Num__Null	nvarchar(100), 
				@not_null				int,
				@null					int,
				@Data_Type_Query		nvarchar(500),
				@datatype				varchar(20),
				@File_name				Varchar(100),
				@Path					Varchar(300),
				@File_Create_query		Nvarchar(max),
				@Creation_query			nvarchar(300);
			

			--Seting file Name
			set @File_name		=@Database+'_Database_Information.csv'
			set @Path			='F:\Sql_Project\'

			---Declaring table variable to store table name 
			declare @tbl table(tbl_nm varchar(50))

			---Query to select all table name from Database
			set @table_query ='select table_name from '+@database+'.information_schema.Tables'
 
			---Inserting records in table variable 
			insert into @tbl
			exec sp_executesql @table_query

			--Creating Cursor for Fetch each table 
			declare Table_Cursor cursor for 
			select tbl_nm from @tbl 

			--Opening Cursor For table 
			open Table_Cursor 

			--Fetch table name from Table_Cursor
			Fetch next from Table_Cursor into @Table_Name

			--Conditon for Until its True
			while (@@FETCH_STATUS<>-1)
				begin 

					--Decalre table to store column name in one table
					declare @column_Table  table(col varchar(50))

					set @Column_Qerry ='select column_name from '+@database+'.information_schema.columns where table_name = '+ '''' + @Table_Name + ''''

					--Inserting value in Column table
					insert into @column_Table
					exec sp_executesql @Column_Qerry

				    --Creating Cursor to get column 
				   declare Column_Cursor cursor for select col from @column_Table

				   --opening Cursor for Column 
					open Column_Cursor 

					fetch next from Column_Cursor into @col_name

					while @@FETCH_STATUS<>-1
						begin

							--Query To get count of record where record are not null
							set @Query_For_Not_Null='select @nn=count('+@col_name+') from '+@Database+'.dbo.'+@Table_Name  +' where '+@col_name+' is not null'
									
							exec sp_executesql @Query_For_Not_Null,N'@nn Int Output',@nn=@not_null output

							
							--To Find out data type of Column 
							set @Data_Type_Query='SELECT @dd=DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='+''''+ @Table_Name+''''+' AND COLUMN_NAME ='+
							''''+@col_name+''''

							exec sp_executesql @Data_Type_Query,N'@dd varchar(20) Output',@dd=@datatype output
							
							
							---If Datatype is date of column
							if @datatype='date'
								begin
									set @Querry_For_Num__Null='select @n=count(isnull('+@col_name+',''1990-01-01'')) from '+@Database+'.dbo.'+@Table_Name +' where '+@col_name+' is null'
										
									exec sp_executesql @Querry_For_Num__Null,N'@n Int Output',@n=@null output
								end	
							
							---If Datatype of Column is Integer
							else if  @datatype='int'
								begin
									set @Querry_For_Num__Null='select @n=count(isnull('+@col_name+',0)) from '+@Database+'.dbo.'+@Table_Name +' where '+@col_name+' is null'
										
									exec sp_executesql @Querry_For_Num__Null,N'@n Int Output',@n=@null output
								end	
							
							--If DataType of Column is varchar
							else if @datatype='varchar'
								begin
									set @Querry_For_Num__Null='select @n=count(isnull('+@col_name+',''abc'')) from '+@Database+'.dbo.'+@Table_Name +' where '+@col_name+' is null'
										
									exec sp_executesql @Querry_For_Num__Null,N'@n Int Output',@n=@null output
								end		

							--Inserting table name , Column Name , count of null and count of not 
							insert into ##tbl_Database_info values
							(@Table_Name,@col_name,@datatype,@not_null,@null)

					
							fetch next from Column_Cursor into @col_name

						end

				---Closing Column Cursor
				close Column_Cursor

				--Deallocating Column Cursor
				deallocate Column_Cursor

				--Deleting Records from column table so that next time for second table new column list will insert
				delete from  @column_Table

				Fetch next from Table_Cursor into @Table_Name

			end
		
			---Closing Table_Cursor Cursor
			close Table_Cursor

			---Closing Table_Cursor Cursor
			deallocate Table_Cursor
			
			---Storing Database information in File 
			set @File_Create_query=' sqlcmd  -E -d tempdb  -S "DESKTOP-D2M81Q0" -s, -Q "select * from ##tbl_Database_info "'

			--Command to Create File with data
			set @Creation_query=@File_Create_query+ ' >'+@Path+@File_name 
			
			exec master.dbo.xp_Cmdshell @Creation_query
		end

	else

		Begin 
				raiserror('Database does not exist',8,16)
		End
end

 

