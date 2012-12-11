@Session =
  
  adapters: [
    "postgresql"
    "mongodb"
    "mysql"
    "sqlite"
  ]

  init: -> 
    @$newSessionForm = $("[data-name=new-session-form]")
    @$adapterSelect = $("[data-name=adapter-select]")
    @$sessionName = @$newSessionForm.find("[name='session[name]']")
    @bind()
    @toggleDependentInputs(@$adapterSelect.val())


  bind: ->
    @$adapterSelect.on 'change', (e) => @toggleDependentInputs($(e.target).val())

    @$newSessionForm.on 'submit', (e) =>
      unless @isValid()
        e.preventDefault()
        Modal.alert
          title: I18n.t('modals.connection_name.invalid.title')
          body: I18n.t('modals.connection_name.invalid.body')


  isValid: -> @$sessionName.val().length > 0
  
  # Show and hide Adapter specific inputs for connections
  #
  # adapterName - The String adapter name to toggle inputs for
  #
  toggleDependentInputs: (adapterName) ->
    $unusedInputs = @$newSessionForm.find("[data-adapter-dependent]").not("[data-#{adapterName}]")
    $unusedInputs.hide()
    $unusedInputs.find("input, textarea, select, checkbox").val("")
    @$newSessionForm.find("[data-adapter-dependent][data-#{adapterName}]").show()




