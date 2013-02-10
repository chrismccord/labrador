# Labrador v0.2.1
A loyal database (agnostic) client for your Rails development databases.

## Installation
Labrador can be installed by a single copy paste of aggregated shell commands. Detailed instructions can be found on 
[labrador's homepage](http://chrismccord.github.com/labrador/).


### Upgrading

    $ cd ~/.labrador
    $ git pull origin master
    $ mkdir -p tmp/
    $ touch tmp/restart.txt
    
## Features
 
 - Automatic intregation with [pow](http://pow.cx), allowing you to hit (myapp.larabdor.dev) and be up and running
 - Listing/paging, update, and delete support of records/documents across all your development tables/collections.
 - Easy schema viewing for all your SQL database tables
 - Automatic Rails application discovery within the current app's parent folder for easy app switching
 - Manual database connections for non-Rails application support by simply visiting labrador.dev/
 
### Supported Database Adapters
Labrador supports most mainstream database adapters and Rails database configurations.
If you are using ActiveRecord, Datamapper, or Mongoid with standard database.yml or mongoid.yml 
configurations your databases will be connected to automatically.
 
 - Postregsql
 - MySQL
 - SQlite
 - MongoDB
 - RethinkDB

### OSX Support
Zero setup is required after installation when [pow](http://pow.cx) is installed. Simply install and then load up 
myapp.labrador.dev.

### Other Linux/Unix Support
Add this to your .bash_profile or equivalent
    
    alias labrador-start="cd $HOME/.labrador && bundle exec rails s -e production -p 7488"
    
After the server is started, you can then load up localhost:7488/~/Path/to/myapp

## Roadmap
  - ~~Manual database connections~~ (completed in v0.2.0)
  - Arbitrary queries
  - Record creation  
  - Redis support

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
      rethinkdb:
        database: labrador_test
        host: localhost
        port: 28015

Note - The sqlite adapter uses a local .sqlite3 file in test/fixtures.



## Known Limitations
Labrador uses pure ruby adapters for mysql and postgres to avoid incompatibilities with users 
lacking postgres or mysql headers for native extension compilation. These implementations are unable 
to establish database connections over SSL.

