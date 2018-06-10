# message_store-postgres-database

Message store PostgreSQL database definition

## Usage

### Write a Message

```
SELECT write_message('uuid'::varchar, 'stream_name'::varchar, 'message_type'::varchar, '{"messageAttribute": "some value"}'::jsonb, '{"metaDataAttribute": "some meta data value"}'::jsonb);"
```

### Write a Message, Specifying the Expected Version of the Stream

```
SELECT write_message('uuid'::varchar, 'stream_name'::varchar, 'message_type'::varchar, '{"messageAttribute": "some value"}'::jsonb, '{"metaDataAttribute": "some meta data value"}'::jsonb, expected_version::bigint);"
```

NOTE: If the expected version does not match the stream version at the time of the write, an error is raised of the form:

```
'Wrong expected version: % (Stream: %, Stream Version: %)'
```

### Get Messages from a Stream

```
SELECT * FROM get_stream_messages('stream_name'::varchar, starting_position::bigint, batch_size::bigint, _condition => 'some additional SQL where clause fragment'::varchar);"
```

Optional arguments:
- starting_position
- batch_size
- condition

### Get Messages from a Category

```
SELECT * FROM get_category_messages('cateogry_name'::varchar, starting_position::bigint, batch_size::bigint, _condition => 'some additional SQL where clause fragment'::varchar);"
```

Optional arguments:
- starting_position
- batch_size
- condition

Note: Where `someThing-123` is a _stream name_, `someThing` is a _category_. Reading the `someThing` category retrieves messages from all streams whose names start with `someThing-`.

### Get Last Message from a Stream

```
SELECT * FROM get_last_message('someStream-123')
```

## Tools

### Install the Message Store Database
```
evt-pg-create-db
```

### Delete the Message Store Database
```
evt-pg-delete-db
```

### Recreate the Message Store Database
```
evt-pg-recreate-db
```

### Print the Messages Stored the Message Store Database
```
evt-pg-print-messages
```

### Write a Test Message
```
evt-pg-write-test-message
```

The number of messages and the stream name can be specified using environment variables.

Write a test messages to a stream named `someStream-111`
```
STREAM_NAME=someStream-111 evt-pg-write-test-message
```

Write 10 test messages:
```
INSTANCES=10 evt-pg-write-test-message
```

Write 10 test messages to a stream named `someStream-111`
```
STREAM_NAME=someStream-111 INSTANCES=10 evt-pg-write-test-message
```

### Open/View the Directory Containing the Database Definition Script Files
```
evt-pg-open-database-scripts-dir
```

## Database Definition Script Files

The database is defined by raw SQL scripts. You can examine them, or use them directly with the `psql` command line tool, at:

[https://github.com/eventide-project/message-store-postgres-database/tree/master/database](https://github.com/eventide-project/message-store-postgres-database/tree/master/database)

## License

The `message_store-postgres-database` library is released under the [MIT License](https://github.com/eventide-project/message-store-postgres-database/blob/master/MIT-License.txt).
