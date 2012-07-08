class @Database extends Backbone.Model
  
  defaults:
    limit: 500

  fetchCollections: (callback) ->
    $.ajax
      url: "/data/#{@get('adapter')}/collections"
      success: (data) -> callback?(null, data)
      error: (err) -> callback?(err)


  find: (collection, options, callback) ->
    if typeof options is 'function'
      callback = options 
      options = {}
    options.skip ?= 0
    options.limit ?= @defauls.limit
    @set(lastFind: {collection, options, callback})
    @trigger('before:send', options)
    $.ajax
      url: "/data/#{@get('adapter')}?collection=#{collection}"
      data: options
      success: (data) ->         
        data.timestamp = (new Date()).valueOf() # Trigger 'change' if even data is the same
        callback?(null, data)
      error: (err) -> callback?(err)    


  filterPrevious: (newOptions = {}) ->
    return unless @get('lastFind')?
    {collection, options, callback} = @get('lastFind')
    @find(collection, _.extend(options, newOptions), callback)