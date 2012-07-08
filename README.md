## Testing

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