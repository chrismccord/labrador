class @Database extends Backbone.Model

  name: -> 
    I18n.t("adapters.#{@get('adapter')}.title")


  collectionName: (count = 1) -> 
    I18n.t("adapters.#{@get('adapter')}.collection", count: count)


  resultName: (count = 1) -> 
    I18n.t("adapters.#{@get('adapter')}.result", count: count)   


  fetchCollections: (callback) ->
    $.ajax
      url: "/data/#{@get('adapter')}/collections"
      success: (data) -> callback?(null, data)
      error: (err) -> callback?(err)

  
  # Returns String collection name from last find
  collection: -> @get('data')?.collection


  # Returns name of field that is primary key from last find
  primaryKey: -> @get('data')?.primary_key


  find: (collection, options, callback) ->
    if typeof options is 'function'
      callback = options 
      options = {}
    options.skip ?= 0
    options.limit ?= app.get('limit')
    @set(lastFind: {collection, options, callback})
    @trigger('before:send', collection, options)
    options.path = @get('path')
    $.ajax
      url: "/data/#{@get('adapter')}?collection=#{collection}"
      type: "GET"
      data: options
      success: (data) ->         
        data.timestamp = (new Date()).valueOf() # Trigger 'change' if even data is the same
        callback?(null, data)
      error: (error) =>
        @trigger('error', error)
        callback?(error) 


  filterPrevious: (newOptions = {}) ->
    return unless @get('lastFind')?
    {collection, options, callback} = @get('lastFind')
    options.limit = app.get('limit')
    @find(collection, _.extend(options, newOptions), callback)


  create: (collection, data = {}, callback) ->
    $.ajax
      url: "/data/#{@get('adapter')}?collection=#{collection}"
      type: "POST"
      data: {data}
      success: (response) =>
        @trigger('error', error: response.error) if response.error
        callback?(response.error)
      error: (error) =>
        @trigger('error', error)
        callback?(error)    


  update: (collection, id, data = {}, callback) ->
    $.ajax
      url: "/data/#{@get('adapter')}/#{id}?collection=#{collection}"
      type: "PUT"
      data: {data}
      success: (response) =>
        @trigger('error', error: response.error) if response.error
        callback?(response.error)
      error: (error) =>
        @trigger('error', error)
        callback?(error)    


  delete: (collection, id, callback) ->
    $.ajax
      url: "/data/#{@get('adapter')}/#{id}?collection=#{collection}"
      type: "DELETE"
      success: (response) =>
        @trigger('error', error: response.error) if response.error
        callback?(response.error)
      error: (error) =>
        @trigger('error', error)
        callback?(error)      

