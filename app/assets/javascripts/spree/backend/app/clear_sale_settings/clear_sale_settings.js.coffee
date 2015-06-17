#= require ./clear_sale_add_provider
#= require ./clear_sale_provider
#= require_self
class window.ClearSaleSettings
  afterConstructor: ->

  beforeConstructor: ->

  constructor: (@providers, defaultExecution = true) ->
    do @beforeConstructor
    do @defaultExecution if defaultExecution
    do @afterConstructor

  defaultExecution: ->
    add_provider = new ClearSaleAddProvider(@providers)
    do @setBirthDate
    $('#enable_birth_date').change => do @setBirthDate
    do @setCategoryTaxonomy
    $('#enable_category_taxonomy').change => do @setCategoryTaxonomy

  # habilita/desabilita o campo
  # do atributo da data de nascimento do cliente
  # de acordo com o checkbox
  setBirthDate: ->
    if $('#enable_birth_date').is(':checked')
      $('#birth_date_container').show()
    else
      $('#birth_date_container').hide()
      $("#birth_date_customer_attr option[value='']").attr('selected', true)

  # habilita/desabilita o campo
  # que armazena o taxonomy que representa
  # as categorias dos produtos
  setCategoryTaxonomy: ->
    if $('#enable_category_taxonomy').is(':checked')
      $('#category_taxonomy_container').show()
    else
      $('#category_taxonomy_container').hide()
      $("#category_taxonomy_id option[value='']").attr('selected', true)