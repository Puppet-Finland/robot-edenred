*** Settings ***

Resource  ../resources/common.robot

Task Setup     Begin Browser Web Test
Task Teardown  End Browser Web Test

*** Tasks ***

Charge Lounas Edenred
  Login To Edenred
  Go To Lounas Card
  Go To CSV Charging
  Charge Lounas Card With CSV

Verify Lounas Charge
  Login To Edenred
  Go To Lounas Card
  Go To CSV Charging
  Validate Latest CSV Order

Charge Tyomatka Edenred
  Login To Edenred
  Go To Tyomatka Card
  Go To CSV Charging
  Charge Tyomatka Card With CSV

Verify Tyomatka Charge
  Login To Edenred
  Go To Tyomatka Card
  Go To CSV Charging
  Validate Latest CSV Order
