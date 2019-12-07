# Message DB

**Microservice Native Message and Event Store for Postgres**

A fully-featured event store and message store implemented entirely in PostgreSQL. Pub/Sub, Event Sourcing, Evented Microservices.

## Features

- Pub/Sub
- JSON message data
- Event streams
- Metadata
- Message storage
- Consumer groups
- Service host
- Administration tools
- Reports

## Rationale

An event sourcing and Pub/Sub message store built on Postgres for simple cloud or local hosting. An implementation of the essential features of tools like [Event Store](https://eventstore.org), with built-in support for messaging patterns like Pub/Sub, and consumer patterns like consumer groups.

Message DB was extracted from the [Eventide Project](http://docs.eventide-project.org) to make it easier for users to write clients in the language of their choosing.

## Installation

The Postgres Message Store can be installed either as a Ruby Gem, an NPM package, or can simply be cloned from this repository.

### As a Ruby Gem

``` bash
gem install message-db
```

### As an NPM Module

``` bash
npm install @eventide/message-db
```

### Git Clone

``` bash
git clone git@github.com:message-db/message-db.git
```

## User Guide

A complete user guide is available on the Eventide Project docs site:

[http://docs.eventide-project.org/user-guide/message-db/](http://docs.eventide-project.org/user-guide/message-db/)

## Interface

The message store provides an interface of Postgres server functions that can be used with any programming language or through the `psql` command line tool.

Interaction with the underlying store through the Postgres server functions ensures correct writing and reading messages, streams, and categories.

### Write a Message

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

#### Returns

Position of the message written.

#### Arguments

| Name | Description | Type | Default | Example |
| --- | --- | --- | --- | --- |
| id | UUID of the message being written | varchar | | a5eb2a97-84d9-4ccf-8a56-7160338b11e2 |
| stream_name | Name of stream to which the message is written | varchar | | someStream-123 |
| type | The type of the message | varchar | | Withdrawn |
| data | JSON representation of the message body | jsonb | | {"someAttribute": "some value"} |
| metadata (optional) | JSON representation of the message metadata | jsonb | NULL | {"metadataAttribute": "some meta data value"} |
| expected_version (optional) | Version that the stream is expected to be when the message is written | bigint | NULL | 11 |

#### Usage

``` sql
SELECT write_message('a11e9022-e741-4450-bf9c-c4cc5ddb6ea3', 'someStream-123', 'SomeMessageType', '{"someAttribute": "some value"}', '{"metadataAttribute": "some meta data value"}');
```

```
-[ RECORD 1 ]-+--
write_message | 0
```

Example: [https://github.com/message-db/message-db/blob/master/database/write-test-message.sh](https://github.com/message-db/message-db/blob/master/database/write-test-message.sh)

### Get Messages from a Stream

Retrieve messages from a single stream, optionally specifying the starting position, the number of messages to retrieve, and an additional condition that will be appended to the SQL command's WHERE clause.

``` sql
get_stream_messages(
  stream_name varchar,
  position bigint DEFAULT 0,
  batch_size bigint DEFAULT 1000,
  condition varchar DEFAULT NULL
)
```

#### Arguments

| Name | Description | Type | Default | Example |
| --- | --- | --- | --- | --- |
| stream_name | Name of stream to retrieve messages from | varchar | | someStream-123 |
| position (optional) | Starting position of the messages to retrieve | bigint | 0 | 11 |
| batch_size (optional) | Number of messages to retrieve | bigint | 1000 | 111 |
| condition (optional) | SQL condition to filter the batch by | varchar | NULL | messages.time >= current_time |

#### Usage

``` sql
SELECT * FROM get_stream_messages('someStream-123', 0, 1000, condition => 'messages.time >= current_time');
```

```
-[ RECORD 1 ]---+---------------------------------------------------------
id              | 4b96f09e-104a-4b1f-b198-5b3b46cf1d06
stream_name     | someStream-123
type            | SomeType
position        | 0
global_position | 1
data            | {"attribute": "some value"}
metadata        | {"metaAttribute": "some meta value"}
time            | 2019-11-24 17:56:09.71594
-[ RECORD 2 ]---+---------------------------------------------------------
id              | d94e79e3-cdda-49a3-9aad-ce5d70a5edd7
stream_name     | someStream-123
type            | SomeType
position        | 1
global_position | 2
data            | {"attribute": "some value"}
metadata        | {"metaAttribute": "some meta value"}
time            | 2019-11-24 17:56:09.75969
```

Example: [https://github.com/message-db/message-db/blob/master/test/get-stream-messages/get-stream-messages.sh](https://github.com/message-db/message-db/blob/master/test/get-stream-messages/get-stream-messages.sh)

### Get Messages from a Category

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

#### Arguments

| Name | Description | Type | Default | Example |
| --- | --- | --- | --- | --- |
| category_name | Name of the category to retrieve messages from | varchar | | someCategory |
| position (optional) | Global position to start retrieving messages from | bigint | 1 | 11 |
| batch_size (optional) | Number of messages to retrieve | bigint | 1000 | 111 |
| correlation (optional) | Category or stream name recorded in message metadata's `correlationStreamName` attribute to filter the batch by | varchar | NULL | someCorrelationCategory |
| consumer_group_member (optional) | The zero-based member number of an individual consumer that is participating in a consumer group | bigint | NULL | 1 |
| consumer_group_size (optional) | The size of a group of consumers that are cooperatively processing a single category | bigint | NULL | 2 |
| condition (optional) | SQL condition to filter the batch by | varchar | NULL | messages.time >= current_time |

#### Usage

``` sql
SELECT * FROM get_category_messages('someCategory', 1, 1000, correlation => 'someCorrelationCateogry', consumer_group_member => 1, consumer_group_size => 2, condition => 'messages.time >= current_time');
```

```
-[ RECORD 1 ]---+---------------------------------------------------------
id              | 28d8347f-677e-4738-b6b9-954f1b15463b
stream_name     | someCategory-123
type            | SomeType
position        | 0
global_position | 111
data            | {"attribute": "some value"}
metadata        | {"correlationStreamName": "someCorrelationCateogry-123"}
time            | 2019-11-24 17:51:49.836341
-[ RECORD 2 ]---+---------------------------------------------------------
id              | 57894da7-680b-4483-825c-732dcf873e93
stream_name     | someCategory-456
type            | SomeType
position        | 1
global_position | 1111
data            | {"attribute": "some value"}
metadata        | {"correlationStreamName": "someCorrelationCateogry-123"}
time            | 2019-11-24 17:51:49.879011
```

Note: Where `someStream-123` is a _stream name_, `someStream` is a _category_. Reading the `someStream` category retrieves messages from all streams whose names start with `someStream` and are followed by an ID, or where `someStream` is the whole stream name.

Example: [https://github.com/message-db/message-db/blob/master/test/get-category-messages/get-category-messages.sh](https://github.com/message-db/message-db/blob/master/test/get-category-messages/get-category-messages.sh)

### Full Function Reference

- [write_message](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#write-a-message)
- [get_stream_messages](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-messages-from-a-stream)
- [get_category_messages](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-messages-from-a-category)
- [get_last_message](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-last-message-from-a-stream)
- [stream_version](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-stream-version-from-a-stream)
- [id](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-the-id-from-a-stream-name)
- [cardinal_id](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-the-cardinal-id-from-a-stream-name)
- [category](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-the-category-from-a-stream-name)
- [is_category](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#determine-whether-a-stream-name-is-a-category)
- [acquire_lock](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#acquire-a-lock-for-a-stream-name)
- [hash_64](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#calculate-a-64-bit-hash-for-a-stream-name)
- [message_store_version](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-message-store-database-schema-version)

## Structure

The message store is a single table named `messages`.

## Messages Table

| Column | Description | Type | Default | Nullable |
| --- | --- | --- | --- | --- |
| id | Identifier of a message record | UUID | gen_random_uuid() | No |
| stream_name | Name of stream to which the message belongs | varchar | | No |
| type | The type of the message | varchar | | No |
| position | The ordinal position of the message in its stream. Position is gapless. | bigint | | No |
| global_position | Primary key. The ordinal position of the message in the entire message store. Global position may have gaps. | bigint | | No |
| data | Message payload | jsonb | NULL | Yes |
| metadata | Message metadata | jsonb | NULL | Yes |
| time | Timestamp when the message was written. The timestamp does not include a time zone. | timestamp | now() AT TIME ZONE 'utc' | No |

## Indexes

| Name | Columns | Unique | Note |
| --- | --- | --- | --- |
| messages_id | id | Yes | Enforce uniqueness as secondary key |
| messages_stream | stream_name, position | Yes | Ensures uniqueness of position number in a stream |
| messages_category | category(stream_name), global_position, category(metadata->>'correlationStreamName') | No | Used when retrieving by category name |

## Database

By default, the message store database is named `message_store`.

See the [installation guide](./install.md#database-name) for more info on varying the database name.

## Schema

All message store database objects are contained within a schema named `message_store`.

## User/Role

By default, a role named `message_store` is created. The `message_store` role is the owner of the `message_store` schema. The role is granted all necessary privileges to the database objects.

## Source Code

View complete source code at: <br />
[https://github.com/message-db/message-db/tree/master/database](https://github.com/message-db/message-db/tree/master/database)

## License

The Postgres Message Store is released under the [MIT License](https://github.com/message-db/message-db/blob/master/MIT-License.txt).

