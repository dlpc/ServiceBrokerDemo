# Demo of _**Service Broker**_ synchronous scenario

This solution demonstrate usage of **Service Broker** to implement sync requests from SQL Server to other data sources.

## Structure

- [**Database project**][1]. Demo database structure required to set up Service Broker.
- [**Console project**][2]. Demo windows service to process Service Broker requests.


## Build

1. Build & Deploy [Database][1] project using `F5`.
2. Build [Worker][2] project.

[1]: ./Database
[2]: ./Worker 

## Execute

### Running scenario:

1. Start [Worker][2] project using `CTRL-F5`
1. Execute [SP][3]:

```sql
USE [Database]
GO

DECLARE    @return_value Int

EXEC	@return_value = [dbo].[GetDynamicData]

SELECT	@return_value as 'Return Value'

GO
```
    
**_Note:_**  SP finished execution ater ~1 second. You received XML with following template:
```xml
    <results>
        <result>
            <message>
                <requestedAt>2013-11-10T08:24:01</requestedAt>
                <processedAt>2013-11-10T08:24:10</processedAt>
            </message>
        </result>
    </results>
```
### Exceptional flow - service not running

1. Stop worker process `CTRL-C` if it's running
1. Execute SP _(same as previous)_

**_Note:_** SP finished execution ater ~10 second. You receive following response:

`"Timeout occured on waitig for handle '09D74FA4-F049-E311-A53A-C9D92FED11A4'"`

[3]: ./Database/GetDynamicData.sql

## Deploy

[Worker][2] console can be easely installed as a service:
1. Compile [Worker][2] project (Release configuration?)
1. Open output folder in **cmd** as administrator
1. Execute `> Worker.exe install` to install as Windows Service
1. Execute `> Worker.exe start` to start service.

For more command line options refere to [Topshelf][topshelf] documentation
[topshelf]: http://topshelf-project.com/documentation/