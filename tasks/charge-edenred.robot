*** Settings ***

Resource  ../resources/common.robot

Task Setup     Begin Browser Web Test
Task Teardown  End Browser Web Test

*** Tasks ***

Charge Lounas Edenred
  Login To Edenred
  Select Finnish Language
  Go To Lounas Card
  Go To CSV Charging
  Charge Lounas Card With CSV

Charge Tyomatka Edenred
  Login To Edenred
  Select Finnish Language
  Go To Tyomatka Card
  Go To CSV Charging
  Charge Tyomatka Card With CSV

# Orders appear in Edenred webui rather slowly and we don't want to fail
# verification because of that
Wait Before Verifying
  BuiltIn.Sleep  10

Verify Lounas Charge
  Login To Edenred
  Select Finnish Language
  Go To Lounas Card
  Go To CSV Charging
  Validate Latest CSV Order

Verify Tyomatka Charge
  Login To Edenred
  Select Finnish Language
  Go To Tyomatka Card
  Go To CSV Charging
  Validate Latest CSV Order
