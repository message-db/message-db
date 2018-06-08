# message_store-postgres-database

Message store PostgreSQL database definition

## Usage

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
