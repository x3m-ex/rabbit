# X3m.Rabbit

Wrapper around RabbitMQ. Rest of the documentation is TBD.

##  Configuration examples


    [
      {:publisher, MyApp.Rabbit.ExchangePublisher, [
         {:exchange, %{
                        name:    "exchange_name",
                        type:    :topic,
                        options: [durable: true]
                      }}
      ]},
      {:publisher, MyApp.Rabbit.QueuePublisher, [
         {:queue,    %{
                        name:    "queue_name_to_publish",
                        options: [
                                   durable:   true,
                                   arguments: [{"x-dead-letter-exchange",    :longstr, "dead"}, 
                                               {"x-dead-letter-routing-key", :longstr, "dead.my_app.queue_name_to_publish"}]
                                 ]
                      }}
      ]},
      {:listener, MyApp.Rabbit.SomeQueueListener, %{
         event_processor: MyApp.SomeQueueProcessor,
         exchange: %{
           name:    "exchange_name",
           type:    :topic,
           options: [durable: true]
         },
         queue: %{
           name:         "some_queue_listener",
           qos_opts:     [prefetch_count: 100],
           declare_opts: [
             exclusive: false, 
             durable: true, 
             arguments: [
               {"x-dead-letter-exchange", :longstr, "dead"}, 
               {"x-dead-letter-routing-key", :longstr, "dead.my_app.some_queue_listener"}
             ]
           ],
           bind_opts: [routing_key: "#"],
         }
      }}
    ]

Minimal required configuration (when exchanges and queues are declared somewhere else) is:

    [
      {:publisher, MyApp.RabbitPublisher, [
         {:exchange, %{ name: "exchange_name" }},
         {:queue,    %{ name: "queue_name_to_publish" }}
      ]},
      {:listener,  MyApp.Rabbit.SomeQueueListener, %{
         event_processor: MyApp.SomeQueueProcessor,
         exchange:        %{ name: "exchange_name" },
         queue:           %{ name: "some_queue_listener" }
      }}
    ]

When listener receives message it calls `event_processor.process(route, payload, [redelivered?: redelivered?]=options)`
function. If it returns `:ok`, messages is acked. On `{:error, :discard_message}` message is nacked. On anything else
message is returned for redelivery.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `x3m_rabbit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:x3m_rabbit, "~> 0.1.0"}
  ]
end
```
