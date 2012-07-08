class @Query extends Backbone.Model
  
  # @attributes
  #   options



  fetch: (options, callback) ->
    @set(options: options)
    @get('database').find @get('collection'), { options: @get('options') }, callback
    $.ajax
      url: "/data/#{@get('database').get('adapter')}?collection=#{collection}"
      data: options
      success: (data) -> callback?(null, data)
      error: (err) -> callback?(err)    

