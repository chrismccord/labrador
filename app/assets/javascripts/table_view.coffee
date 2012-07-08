class @TableView extends Backbone.View
  
  maxChars: 120

  initialize: (attributes) ->
    @model.on 'change:data', => @render(@model.get('data').fields, @model.get('data').items)
    @model.on 'before:send', => 
      @emptyBody()
      @showLoading(5)


  truncate: (str, limit, endWith = "...") ->
    str = str.toString()
    return str if str.length <= limit + endWith.length
    str.substring(0, limit) + endWith


  setTableHeaderWidth: ->
    $headers = ($(h) for h in @$el.find("thead tr th"))
    for td, i in @$el.find("tbody tr:first td")
      width = $(td).width() - 1
      $headers[i].css('min-width': width, 'max-width': width)


  bind: ->
    @$el.unbind()
    $tableContainer = @$el.parent(".fixed-table-container")
    $row = $tableContainer.find("thead tr")
    $tableContainer[0].removeEventListener('scroll', this)
    $tableContainer[0].addEventListener 'scroll', (=>
      $row.css(top: $tableContainer.scrollTop())
      @trigger('scroll')
    ), capture = true

    @$el.find("tbody tr").off('click').on 'click', (e) =>
      e.preventDefault()
      $target = $(e.currentTarget)
      $target.attr("data-active", true)
      @$el.find("tr[data-active=true]").not($target).removeAttr("data-active")
     

    @$el.find("th").off('click').on 'click', (e) =>
      e.preventDefault()
      $target = $(e.currentTarget)
      field = $target.attr("data-field")
      direction = $target.attr('data-direction')
      @$el
        .removeAttr("data-direction")
        .find("th [data-action=asc], [data-action=desc]").hide()
      if direction is 'asc'
        $target.attr('data-direction', 'desc')
        $target.find("[data-action='desc']").show()
        @model.filterPrevious(order_by: field, direction: 'desc')
      else
        $target.attr('data-direction', 'asc')
        $target.find("[data-action='asc']").show()
        @model.filterPrevious(order_by: field, direction: 'asc')
 
    @$el.find("thead th [data-action='expand']").off('click').on 'click', (e) =>
      e.stopPropagation()
      $parent = $(e.target).parents("th")
      field = $parent.attr("data-field")
      @$el.find("[data-field='#{field}']").attr("data-expanded", true)
      @setTableHeaderWidth()


    @$el.find("thead th [data-action='contract']").off('click').on 'click', (e) =>
      e.stopPropagation()
      $parent = $(e.target).parents("th")
      field = $parent.attr("data-field")
      @$el.find("[data-field='#{field}']").removeAttr("data-expanded")
      @setTableHeaderWidth()

    @doubleClicked = false
    @$el[0].removeEventListener('dblclick', this)
    @$el[0].addEventListener 'dblclick', ((e) =>
      return if @doubleClicked
      console.log 'init dblclick'
      @doubleClicked = true
      @$el.find("td").off('dblclick').on 'dblclick', (e) => 
        App.hideTooltips()
        $pop = $(e.currentTarget)
        App.popover($pop, placement: 'bottom', trigger: 'manual', title: $pop.attr('data-field'))
        App.popover($pop, 'show')
        $(e.currentTarget).find("[rel=popover]").on('mouseout').popover('hide')   
    ), capture = true


  anyFieldChanged: (newFields) ->
    (newFields.some (field) => @$el.find("th[data-field='#{field}']").length is 0)

  
  expandedFields: ->
    ($(th).attr('data-field') for th in @$el.find("th[data-expanded=true]"))
    
  
  headerTemplate: (fields) ->
    thead = ""
    for field in fields        
      thead += """
        <th data-field='#{field}'>
          <span class='pull-left'>
            <i class='icon-chevron-up' data-action='asc'></i>
            <i class='icon-chevron-down' data-action='desc'></i>
          </span>
          <span class='pull-left'>#{field}</span>
          <span class='pull-right'>
            <i class='icon-arrow-right' data-action='expand'></i>
            <i class='icon-arrow-left' data-action='contract'></i>
          </span>
        </th>
      """

    thead


  bodyTemplate: (fields, items, callback) ->
    rows = []
    count = 0
    expandedFields = @expandedFields()
    processRows = (item, done) =>
      rows.push "<tr class='#{if count % 2 is 0 then '' else 'odd'}'>"
      for field in fields
        val = item[field] ? ""
        type = if $.isNumeric(val) then 'number' else 'string'
        expanded = if expandedFields.indexOf(field) >= 0 then 'true' else 'false'
        rows.push """
          <td data-type='#{type}' data-field='#{field}' data-expanded='#{expanded}' rel='popover' data-content='#{_.escape(val)}'>
            <div class='value'>#{_.escape(@truncate(val, @maxChars))}</div>
            <div class='truncated'>#{_.escape(@truncate(val, 16))}</div>
          </td>
        """
      rows .push "</tr>"
      count += 1
      if Math.round((count / items.length) * 100) % 5 is 0
        @showLoading(Math.round((count / items.length) * 100))
      setTimeout(done, 20)

    q = async.queue(processRows, concurrency = 25)
    q.push(items)
    q.drain = -> callback(rows.join(''))
    

  emptyBody: ->
    @$el.find("tbody").empty()


  render: (fields, items) ->
    App.hideTooltips()
    @emptyBody()
    return @zeroState() if fields.length is 0 or items.length is 0

    if @anyFieldChanged(fields)
      @$el.find("thead tr").html(@headerTemplate(fields))

    @bodyTemplate fields, items, (body) =>
      @$el.find("tbody").append(body)
      @setTableHeaderWidth()
      @bind()
      @hideLoading()
      @trigger('render')

  showLoading: (percentage) ->
    App.views.progressView.show(percentage)

  
  hideLoading: ->
    App.views.progressView.hide()


  zeroState: ->
    @hideLoading()
    @trigger('render')


