# Labrador
A loyal database (agnostic) client for your Rails applications' development databases.

## Installation
Labrador can be installed by a single copy paste of aggregated shell commands. Detailed instructions can be found on 
[labrador's homepage](http://chrismccord.github.com/labrador/).


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



