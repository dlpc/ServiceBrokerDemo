CREATE SERVICE [DynamicDataResponseService]
	ON QUEUE [dbo].[DynamicDataResponseQueue]
	(
		[DynamicDataContract]
	)
