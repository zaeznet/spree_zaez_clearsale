#= require_self
class window.ClearSaleAddProvider

  # Adiciona um novo provider
  # @param event JqueryEvent
  addProvider: (event) ->
    event.preventDefault()
    if $('#provider').select2('data')? and $('#payment_type').select2('data')?
      $('.empty-fields-item').hide()
      provider = $('#provider').select2('data')
      payment_type = $('#payment_type').select2('data')
      provider = @findOrAdd provider
      provider.setPaymentType payment_type
      do @render
    else
      $('.empty-fields-item').show()

  afterConstructor: ->

  beforeConstructor: ->

  constructor: (@default_providers, defaultExecution = true) ->
    do @beforeConstructor
    do @defaultExecution if defaultExecution
    do @afterConstructor

  defaultExecution: ->
    do @setVariables
    do @setEvents
    do @setDefaultProviders

  findOrAdd: (provider) ->
    if existing = _.find(@providers, (v) ->
      v.id == provider.id)
      return existing
    else
      provider = new ClearSaleProvider($.extend({}, provider))
      @providers.push provider
      return provider

  # Remove um provider da tabela
  # @param event JqueryEvent
  removeProvider: (event) ->
    event.preventDefault()
    target = $ event.target
    provider_id = target.data('provider')
    @providers = (v for v in @providers when v.id isnt provider_id)
    do @render

  # Renderiza a tabela de itens
  render: ->
    if @providers.length > 0
      $('#clear-sale-providers-table').show()
      rendered = @template {providers: @providers}
      $('#clear_sale_providers_tbody').html(rendered)
    else
      $('#clear-sale-providers-table').hide()
      for item in $('input[name="providers[]"]')
        $(item).val('')
      for item in $('input[name="payment_types[]"]')
        $(item).val('')

  # Insere na tabela os providers ja salvos
  setDefaultProviders: ->
    for item in @default_providers
      provider = @findOrAdd item
      provider.setPaymentType item.payment_type
    do @render

  # Seta Eventos para as ações nas páginas
  setEvents: ->
    @addButton.on 'click', $.proxy(@addProvider, @)
    @itemTable.on 'click', '.clear_sale_remove_provider', $.proxy(@removeProvider, @)

  # Seta as variaveis da instância
  setVariables: ->
    @providers = []
    @template = Handlebars.compile $('#clear_sale_provider_template').html()
    @addButton = $ 'button.clear_sale_add_provider'
    @itemTable = $ '#clear-sale-providers-table'