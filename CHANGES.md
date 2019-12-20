# Changes

## 1.1.4

Fri Dec 20 2019

- The update script is deprecated in preparation of versioned update scripts
- Update scripts are located in database/updates
- The update code for the v1.0.0 database is moved to database/updates/1.0.0.sh

## 1.1.3

Fri Dec 20 2019

- The update script is corrected for its referencing of the gen_random_uuid from the message_store schema

## 1.1.2

Thu Dec 19 2019

- The pgcrypto extension is not installed into the message_store schema

## 1.1.1

Wed Dec 18 2019

- Vestigial debug output is removed from write_message

## 1.1.0

Wed Dec 11 2019

- The message_store role does not own the schema

# 1.0.0

Tue Dec 10 2019

- Initial release
