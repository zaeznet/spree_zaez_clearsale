# Modelo base para os providers que utilizarao o ClearSale
class window.ClearSaleProvider

  # Callback disparado após a execução
  # do constructor de uma classe
  afterConstructor: ->

    # Callback disparado antes da execução
    # do constructor de uma classe
  beforeConstructor: ->

  # Constructor da classe
  constructor: (@provider) ->
    @beforeConstructor @provider
    @setAttributes @provider
    @afterConstructor @provider

  # Seta os attributos do provider passado
  # no construtor
  # @param provider Object
  setAttributes: (@provider) ->
    @id = @provider.id
    @name = @provider.text
    @payment_type = ''

  setPaymentType: (payment_type) ->
    @payment_type = payment_type