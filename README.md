# Labrador v0.1.0
A loyal database (agnostic) client for your Rails applications' development databases.

## Installation
Labrador can be installed by a single copy paste of aggregated shell commands. Detailed instructions can be found on 
[labrador's homepage](http://chrismccord.github.com/labrador/).

## Features
 
 - Automatic intregation with [pow](http://pow.cx), allowing you to hit (myapp.larabdor.dev) and be up and running
 - Listing/paging, update, and delete support of records/documents across all your development tables/collections.
 - *Support for creating/inserting new records and documents is targetted for the next point release
 - Automatic Rails application discovery within the current app's parent folder for easy app switching
 
## Supported Database Adapters
Labrador supports most mainstream database adapaters and Rails database configurations.
If you are using ActiveRecord, Datamapper, or Mongoid with standard database.yml or mongoid.yml 
configurations your databases will be connected to automatically.
 
 - Postregsql
 - MySQL
 - SQlite
 - MongoDB


## Testing
`rake test`

Add `adapter_test` configurations with credentials for each adapter to `config/database.yml`. ie:
    
    adapter_test:
      mysql:
        database: labrador_test
        host: localhost
        user: username
        password: password
        port: 3306
      postgres:
        database: labrador_test
        host: localhost
        user: username
        password: password
        port: 5432
      mongodb:
        database: labrador_test
        host: 127.0.0.1
        user: username
        password: password
        port: 27017

Note - The sqlite adapter uses a local .sqlite3 file in test/fixtures.



## Known Limitations
Labrador uses pure ruby adapters for mysql and postgres to avoid incompatibilities with users 
lacking postgres or mysql headers for native extension compilation. These implementations are unable 
to establish database connections over SSL.

