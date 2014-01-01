CREATE PROCEDURE [dbo].[GetDynamicData]
AS
	BEGIN
		DECLARE @conversation_handle UNIQUEIDENTIFIER;
		DECLARE @timestamp DATETIME;
		DECLARE @message NVARCHAR(MAX);
		DECLARE @response XML;

		IF OBJECT_ID('tempdb..#DynamicDataResult') IS NULL
			CREATE TABLE #DynamicDataResult (Result NVARCHAR(MAX));

		BEGIN DIALOG CONVERSATION @conversation_handle
		FROM SERVICE [DynamicDataResponseService]
		TO SERVICE 'DynamicDataRequestService'
		ON CONTRACT [DynamicDataContract]
		WITH ENCRYPTION = OFF ;

		SET @timestamp = GETUTCDATE();

		SET @message = '<requests><request><message><requestTime>'
						+CONVERT(VARCHAR(19), @timestamp, 127)
						+'</requestTime></message></request></requests>';

		--PRINT '@@TRANCOUNT Before SEND: ' + CAST(@@TRANCOUNT AS VARCHAR(10));

		SEND ON CONVERSATION @conversation_handle MESSAGE TYPE [DynamicDataRequestType] (@message);

		WAITFOR(RECEIVE TOP(1)
			@response = CAST(message_body AS XML)
		FROM
			[DynamicDataResponseQueue]
		WHERE
			conversation_handle = @conversation_handle
			), TIMEOUT 10000;
		IF(@@ROWCOUNT=0) 
		BEGIN
			END CONVERSATION @conversation_handle WITH CLEANUP;
			INSERT INTO #DynamicDataResult
				SELECT 'Timeout occured on waitig for handle ''' + CAST(@conversation_handle AS VARCHAR(40)) + '''' AS 'Result';
		END
		ELSE
		BEGIN
			INSERT INTO #DynamicDataResult
				SELECT CAST(@response AS NVARCHAR(MAX)) AS 'Result';
			END CONVERSATION @conversation_handle;		
		END
		SELECT * FROM #DynamicDataResult
	END
RETURN 0
