# Postgres Message Store

A fully-featured event store and message store implemented entirely in PostgreSQL server functions and indexes supporting event sourcing and messaging applications and services.

## Features

- Event streams
- Pub/Sub
- Message storage
- JSON message data
- Metadata
- Stream categories
- Consumer groups
- Optimistic concurrency
- Administration tools
- Reports

## Installation

The Postgres Message Store can be installed either as a Ruby Gem, an NPM package or can simply be cloned from this repository.

### As a Ruby Gem

``` bash
gem install evt-message_store-postgres-database
```

### As an NPM Module

``` bash
npm install @eventide/postgres-message-store
```

### Git Clone

``` bash
git clone git@github.com:eventide-project/postgres-message-store.git
```

# Server Functions

The message store provides an interface of Postgres server functions that can be used with any programming language or through the `psql` command line tool.

There are working examples of uses of the server functions included with the source code:

Example: [https://github.com/eventide-project/postgres-message-store/blob/master/database](https://github.com/eventide-project/postgres-message-store/blob/master/database)

## Write a Message

Write a JSON-formatted message to a named stream, optionally specifying JSON-formatted metadata and an expected version number.

``` sql
write_message(
  id varchar,
  stream_name varchar,
  type varchar,
  data jsonb,
  metadata jsonb DEFAULT NULL,
  expected_version bigint DEFAULT NULL
)
```

### Arguments

| Name | Type | Description | Default | Example |
| --- | --- | --- | --- | --- |
| id | varchar | UUID of the message being written | | a5eb2a97-84d9-4ccf-8a56-7160338b11e2 |
| stream_name | varchar | Name of stream to which the message is written | | someStream-123 |
| type | varchar | The type of the message | | Withdrawn |
| data | jsonb | JSON representation of the message body | | {"someAttribute": "some value"} |
| metadata (optional) | jsonb | JSON representation of the message metadata | NULL | {"metadataAttribute": "some meta data value"} |
| expected_version (optional) | bigint | Version that the stream is expected to be when the message is written | NULL | 11 |

### Usage

``` sql
SELECT write_message('a11e9022-e741-4450-bf9c-c4cc5ddb6ea3', 'someStream-123', 'SomeMessageType', '{"someAttribute": "some value"}', '{"metadataAttribute": "some meta data value"}');
```

Example: [https://github.com/eventide-project/postgres-message-store/blob/master/database/write-test-message.sh](https://github.com/eventide-project/postgres-message-store/blob/master/database/write-test-message.sh)

### Specifying the Expected Version of the Stream

``` sql
SELECT write_message('a11e9022-e741-4450-bf9c-c4cc5ddb6ea3', 'someStream-123', 'SomeMessageType', '{"someAttribute": "some value"}', '{"metadataAttribute": "some meta data value"}', 11);
```

NOTE: If the expected version does not match the stream version at the time of the write, an error is raised of the form:

```
'Wrong expected version: {specified_stream_version} (Stream: {stream_name}, Stream Version: {current_stream_version})'
```

Example (_no expected version error_): [https://github.com/eventide-project/postgres-message-store/blob/master/test/write-message-expected-version.sh](https://github.com/eventide-project/postgres-message-store/blob/master/test/write-message-expected-version.sh)

Example (_with expected version error_): [https://github.com/eventide-project/postgres-message-store/blob/master/test/write-message-expected-version-error.sh](https://github.com/eventide-project/postgres-message-store/blob/master/test/write-message-expected-version-error.sh)

## Get Messages from a Stream

Retrieve messages from a single stream, optionally specifying the starting position, the number of messages to retrieve, and an additional condition that will be appended to the SQL command's WHERE clause.

``` sql
get_stream_messages(
  stream_name varchar,
  position bigint DEFAULT 0,
  batch_size bigint DEFAULT 1000,
  correlation varchar DEFAULT NULL,
  condition varchar DEFAULT NULL
)
```

### Arguments

| Name | Type | Description | Default | Example |
| --- | --- | --- | --- | --- |
| stream_name | varchar | Name of stream to retrieve messages from | (none) | someStream-123 |
| position (optional) | bigint | Starting position of the messages to retrieve | 0 | 11 |
| batch_size (optional) | bigint | Number of messages to retrieve | 1000 | 111 |
| correlation (optional) | varchar | Category or stream name recorded in message metadata's `correlationStreamName` attribute to filter the batch by | NULL | someCorrelationCategory |
| condition (optional) | varchar | SQL condition to filter the batch by | NULL | messages.time >= current_time |

### Usage

``` sql
SELECT * FROM get_stream_messages('someStream-123', 0, 1000, correlation => 'someCorrelationCateogry', condition => 'messages.time >= current_time');
```

Example: [https://github.com/eventide-project/postgres-message-store/blob/master/test/get-stream-messages.sh](https://github.com/eventide-project/postgres-message-store/blob/master/test/get-stream-messages.sh)

## Get Messages from a Category

Retrieve messages from a category of streams, optionally specifying the starting position, the number of messages to retrieve, the correlation category for Pub/Sub, consumer group parameters, and an additional condition that will be appended to the SQL command's WHERE clause.

``` sql
CREATE OR REPLACE FUNCTION get_category_messages(
  category_name varchar,
  position bigint DEFAULT 0,
  batch_size bigint DEFAULT 1000,
  correlation varchar DEFAULT NULL,
  consumer_group_member varchar DEFAULT NULL,
  consumer_group_size varchar DEFAULT NULL,
  condition varchar DEFAULT NULL
)
```

### Arguments

| Name | Type | Description | Default | Example |
| --- | --- | --- | --- | --- |
| category_name | varchar | Name of the category to retrieve messages from | (none) | someCategory |
| position (optional) | bigint | Global position to start retrieving messages from | 1 | 11 |
| batch_size (optional) | bigint | Number of messages to retrieve | 1000 | 111 |
| correlation (optional) | varchar | Category or stream name recorded in message metadata's `correlationStreamName` attribute to filter the batch by | NULL | someCorrelationCategory |
| consumer_group_member (optional) | bigint | The zero-based member number of an individual consumer that is participating in a consumer group | NULL | 1 |
| consumer_group_size (optional) | bigint | The size of a group of consumers that are cooperatively processing a single input stream | NULL | 2 |
| condition (optional) | varchar | SQL condition to filter the batch by | NULL | messages.time >= current_time |

### Usage

``` sql
SELECT * FROM get_category_messages('someCategory', 1, 1000, correlation => 'someCorrelationCateogry', consumer_group_member => 1, consumer_group_size => 2, condition => 'messages.time >= current_time');
```

::: tip
Where `someStream-123` is a _stream name_, `someStream` is a _category_. Reading the `someStream` category retrieves messages from all streams whose names start with `someStream-`.
:::

Example: [https://github.com/eventide-project/postgres-message-store/blob/master/test/get-category-messages.sh](https://github.com/eventide-project/postgres-message-store/blob/master/test/get-category-messages.sh)

### Pub/Sub and Retrieving Correlated Messages

The principle use of the `correlation` parameter is to implement Pub/Sub.

The `correlation` parameter filters the retrieved batch based on the content of message metadata's `correlationStreamName` attribute. The correlation stream name is like a _return address_. It's a way to give the message some information about the component where the message originated from. This information is carried from message to message in a workflow until it ultimately returns to the originating component.

The `correlationStreamName` attribute allows a component to tag an outbound message with its origin. And then later, the originating component can subscribe to other components' events that carry the origin metadata.

Before the source component sends the message to the receiving component, the source component assigns it's own stream name to the message metadata's `correlation_stream_name` attribute. That attribute is carried from message to message through messaging workflows.

``` sql
SELECT write_message('a11e9022-e741-4450-bf9c-c4cc5ddb6ea3', 'otherComponent-123', 'SomeMessageType', '{"someAttribute": "some value"}', '{"correlationStreamName": "thisComponent-789"}');

SELECT * FROM get_category_messages('otherComponent', correlation => 'thisComponent');
```

For more details on pub/sub using the correlation stream, see the [pub/sub topic in the consumers user guide](../consumers.html#correlation-and-pub-sub).

## Consumer Groups

Consumers processing a single input stream can be operated in parallel in a _consumer group_. Consumer groups provide a means of scaling horizontally to distribute the processing load of a single stream amongst a number of consumers.

Consumers operating in consumer groups process a single input stream, with each consumer in the group processing messages that are not processed by any other consumer in the group.

Specify both the `consumer_group_member` argument and the `consumer_group_size` argument to enlist a consumer in a consumer group. The `consumer_group_size` argument specifies the total number of consumers participating in the group. The `consumer_group_member` argument specifies the unique ordinal ID of a consumer. A consumer group with three members will have a `group_size` of 3, and will have members with `group_member` numbers `0`, `1`, and `2`.

``` sql
SELECT * FROM get_category_messages('otherComponent', consumer_group_member => 0, consumer_group_size => 3);
```

Consumer groups ensure that any given stream is processed by a single consumer. The consumer that processes a stream is always the same consumer. This is achieved by the _consistent hashing_ of a message's stream name.

A stream name is hashed to a 64-bit integer, and the modulo of that number by the consumer group size yields a consumer group member number that will consistently process that stream name.

Specifying values for the `consumer_group_size` and `consumer_group_member` consumer causes the query for messages to include a condition that is based on the hash of the stream name, the modulo of the group size, and the consumer member number.

``` sql
WHERE @hash_64(stream_name) % {group_size} = {group_member}
```

## Filtering Messages with a SQL Condition

The `condition` parameter receives an arbitrary SQL condition which further filters the messages retrieved.

``` sql
SELECT * FROM get_stream_messages('someStream-123', condition => 'extract(month from messages.time) = extract(month from now())');

SELECT * FROM get_stream_messages('someStream', condition => 'extract(month from messages.time) = extract(month from now())');
```

<div class="note custom-block">
  <p>
    Note: The SQL condition feature is deactivated by default. The feature is activated using the <code>message_store.sql_condition</code> Postgres configuration option: <code>message_store.sql_condition=on</code>. Using the feature without activating the configuration option will result in an error.
  </p>
</div>

::: danger
Activating the SQL condition feature may expose the message store to unforeseen security risks. Before activating this condition, be certain that access to the message store is appropriately protected.
:::

## Get Last Message from a Stream

Retrieve the last message in a stream.

``` sql
get_last_message(
  stream_name varchar
)
```

### Arguments

| Name | Type | Description | Default | Example |
| --- | --- | --- | --- | --- |
| stream_name | varchar | Name of the stream to retrieve messages from | (none) |  someStream-123 |

### Usage

``` sql
SELECT * FROM get_last_message('someStream');
```

Note: This is only for entity streams, and does not work for categories.

Example: [https://github.com/eventide-project/postgres-message-store/blob/master/test/get-last-message.sh](https://github.com/eventide-project/postgres-message-store/blob/master/test/get-last-message.sh)

## Get Message Store Database Schema Version

Retrieve the four octet version number of the message store database.

``` sql
message_store_version()
```

### Usage

``` sql
SELECT message_store_version();
```

The version number will change when the database schema changes. A database schema change could be a change to the `messages` table structure, changes to Postgres server functions, types, indexes, users, or permissions. The version number follows the [SemVer](https://semver.org/) scheme for the last three numbers in the version (the first number is the product generation, and implies a major version change).

## Debugging Output

The message store's server functions will print parameter values, and any generated SQL code, to the standard I/O of the client process.

Debugging output can be enabled for all server functions, or for the get functions and the write function separately

### `message_store.debug_get`

The `debug_get` setting controls debug output for the retrieval functions, including `get_stream_messages`, `get_category_messages`, and `get_last_message`.

Assign the value `on` to the setting to enable debug output.

`message_store.debug_get=on`

### `message_store.debug_write`

The `debug_write` setting controls debug output for the write function, `write_message`.

Assign the value `on` to the setting to enable debug output.

`message_store.debug_write=on`

### `message_store.debug`

The `debug` setting controls debug output for the get functions and the write function.

Assign the value `on` to the setting to enable debug output.

`message_store.debug=on`

### Enabling Debug Output Using a Postgres Environment Variable

The debugging output configuration settings can be enabled in a terminal session using the `PGOPTIONS` environment variable.

``` bash
PGOPTIONS="-c message_store.debug=on"
```

### Enabling Debug Output Using the Postgres Configuration File

The debugging output configuration settings can be set using PostgresSQL's configuration file.

The file system location of the configuration file can be displayed at the command line using the `psql` tool.

``` bash
psql -c 'show config_file'
```

### More on Postgres Configuration

See the PostgreSQL documentation for more configuration options:<br />
[https://www.postgresql.org/docs/current/config-setting.html](https://www.postgresql.org/docs/current/config-setting.html)

## Documentation

See the message store documentation on the Eventide docs site:

[http://docs.eventide-project.org/user-guide/message-store/](http://docs.eventide-project.org/user-guide/message-store/)

## Database Definition Script Files

The database is defined by raw SQL scripts. You can examine them, or execute them directly with the `psql` command line tool.

[https://github.com/eventide-project/postgres-message-store/tree/master/database/](https://github.com/eventide-project/postgres-message-store/tree/master/database/)

## License

The Postgres Message Store is released under the [MIT License](https://github.com/eventide-project/postgres-message-store/blob/master/MIT-License.txt).
