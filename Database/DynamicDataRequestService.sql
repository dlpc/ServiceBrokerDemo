CREATE SERVICE [DynamicDataRequestService]
	ON QUEUE [dbo].[DynamicDataRequestQueue]
	(
		[DynamicDataContract]
	)
