# Changes

## 1.1.6

Mon Jan 6 2020

- Install and uninstall scripts explicitly connect to the postgres database when running the psql utility, and do not depend on the existence of a user database

## 1.1.5

Fri Dec 20 2019

- Changes applied to a pre-v1 message store are documented in database/update/1.0.0.md
- The v1 update script prints out a link to the changes doc

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
