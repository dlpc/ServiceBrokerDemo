CREATE PROCEDURE [dbo].[GetDynamicData]
AS
	BEGIN
		DECLARE @conversation_handle UNIQUEIDENTIFIER;
		DECLARE @timestamp DATETIME;
		DECLARE @message NVARCHAR(MAX);
		DECLARE @response XML;
		BEGIN DIALOG CONVERSATION @conversation_handle
		FROM SERVICE [DynamicDataResponseService]
		TO SERVICE 'DynamicDataRequestService'
		ON CONTRACT [DynamicDataContract]
		WITH ENCRYPTION = OFF ;

		SET @timestamp = GETUTCDATE();

		SET @message = '<requests><request><message><requestTime>'
						+CONVERT(VARCHAR(19), @timestamp, 127)
						+'</requestTime></message></request></requests>';
		SEND ON CONVERSATION @conversation_handle MESSAGE TYPE [DynamicDataRequestType] (@message);

		BEGIN TRANSACTION ;
		WAITFOR(RECEIVE TOP(1)
			@response = CAST(message_body AS XML)
		FROM
			[DynamicDataResponseQueue]
		WHERE
			conversation_handle = @conversation_handle
			), TIMEOUT 10000;
		IF(@@ROWCOUNT=0) 
		BEGIN
			ROLLBACK TRANSACTION;
			END CONVERSATION @conversation_handle WITH CLEANUP;
			SELECT 'Timeout occured on waitig for handle ''' + CAST(@conversation_handle AS VARCHAR(40)) + '''' AS 'Result';
		END
		ELSE
		BEGIN
			SELECT CAST(@response AS NVARCHAR(MAX)) AS 'Result';
			END CONVERSATION @conversation_handle;		
			COMMIT TRANSACTION;
		END
	END
RETURN 0
