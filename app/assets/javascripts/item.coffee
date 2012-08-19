class @Item extends Backbone.Model

  # atrributes
  #   primaryKeyName
  #   primaryKeyValue
  #   data

  initialize: (attributes) ->
    if not @get('primaryKeyValue')? and @get('data')? and @get('primaryKeyName')?
      id = (val for key, val of @get('data') when key is @get('primaryKeyName'))[0]
      @set(primaryKeyValue: id)


  # Get value for field
  val: (field) ->
    return unless @get('data')?
    value = @get('data')[field]
    value = JSON.stringify(value) if typeof(value) is 'object'

    value

    