#= require_self
class window.PhoneMaskAddress
  afterConstructor: ->

  beforeConstructor: ->

  constructor: (defaultExecution = true) ->
    do @beforeConstructor
    do @defaultExecution if defaultExecution
    do @afterConstructor

  defaultExecution: ->
    # insere as mascaras dos telefones
    $('#order_bill_address_attributes_phone').inputmask
      mask: ["(99) 9999-9999", "(99) 99999-9999"]
      keepStatic: true
    $('#order_ship_address_attributes_phone').inputmask
      mask: ["(99) 9999-9999", "(99) 99999-9999"]
      keepStatic: true
    # insere as mascaras dos telefones alternativos
    $('#order_bill_address_attributes_alternative_phone').inputmask
      mask: ["(99) 9999-9999", "(99) 99999-9999"]
      keepStatic: true
    $('#order_ship_address_attributes_alternative_phone').inputmask
      mask: ["(99) 9999-9999", "(99) 99999-9999"]
      keepStatic: true