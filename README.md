# Kafka Dashboards [![Deps Status](https://beta.hexfaktor.org/badge/all/github/tulinmola/kafka-dashboards.svg)](https://beta.hexfaktor.org/github/tulinmola/kafka-dashboards)

Configurable Kafka web dashboards... well... at this point of the development
not too much configuration is possible... and there are no dashboards yet! But
in a near future that's the idea. Stay in touch!

## Development

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Testing

A working Kafka instance needs to be running for testing. You can run a
dockerized Kafka instance with `scripts/start_kafka.sh`.

Then just start tests as usual with `mix test`.

Some notes here:

  * The provided script uses docker-machine. Adapt it to your needs and don't
forget updating `config/test.exs` to connect to your docker host IP.
  * The tests create a lot of topics with testing data. Please, don't use your
production Kafka for testing if you don't want to generate trash into it.

## Running into a docker container

To run Kafka Dashboards application into a container you just need:

  * Build image with `docker build --tag=kafka-dashboards .`
  * Run with `docker run -p 4000:4000 -e "HOST=192.168.99.100" kafka-dashboards`
using your docker host IP
