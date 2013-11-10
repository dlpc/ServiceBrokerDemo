using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Xml.Linq;
using Broker;
using Broker.Entities;
using Topshelf;

namespace Worker
{
    class Program
    {
        private const string ServiceName = "BrokerMessageHandlerDemo";

        static void Main(string[] args)
        {
            HostFactory.Run(x =>
            {
                x.SetServiceName(ServiceName);
                x.SetDescription("This service processes messages from queue provided by connection string. Each message received from queue sent using Messaging dll.");
                x.SetDisplayName("Spiral Message Queue Service");
                x.Service<QueueProcessor>(sc =>
                {
                    sc.ConstructUsing(() =>
                    {
                        var pConfig = new ProcessorConfiguration(1,
                            "DynamicDataResponseType",
                            "DynamicDataRequestType",
                            MessageProcessorDelegate, 
                            1000,
                            "DynamicDataRequestQueue",
                            ConfigurationManager.ConnectionStrings["Connection"]);

                        return new QueueProcessor(pConfig);
                    });
                    sc.WhenStarted(s => s.Start());
                    sc.WhenStopped(s => s.Stop());
                    sc.BeforeStartingService(h => Trace.Listeners.Add(new ConsoleTraceListener()));
                });
                x.StartAutomatically();
                x.RunAsNetworkService();

            });
        }

        private static string MessageProcessorDelegate(string message)
        {
            var xdoc = XDocument.Parse(message);
            Thread.Sleep(1000);
            return new XElement("results", from req in xdoc.Descendants("request")
                select new XElement("result",
                    new XElement("message",
                        new XElement("requestedAt", req.Element("message").Element("requestTime").Value),
                        new XElement("processedAt", DateTime.UtcNow.ToString("s"))))).ToString(SaveOptions.DisableFormatting);

        }
    }
}
