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

Verify Charge
  Login To Edenred
  Go To Lounas Card
  Go To CSV Charging

  # Get the latest order date and status
  ${order_history_table}=    BuiltIn.Set Variable  id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_historyGrid_uniGridControl_v

  # Get the text in the topmost row's "Päivämäärä" ("date") column
  ${latest_order_time_table_element_id}=  Browser.Get Table Cell Element  ${order_history_table}  0  1
  ${latest_order_time}=  Browser.Get Text  ${latest_order_time_table_element_id}

  # Get text from the topmost row's "Tila" (status) column
  ${latest_order_status_table_element_id}=  Browser.Get Table Cell Element  ${order_history_table}  2  1
  ${latest_order_status}=  Browser.Get Text  ${latest_order_status_table_element_id}

  # Check that the timestamp of the latest order is today: if not we're looking
  # at and obsolete entry. Edenred web interface displays dates in dd.mm.yyyy
  # hh:mm:ss format _without_ zero padding so we need to convert Get Time's
  # zero padded values on the fly. Examples of what ${current_date} will look
  # like this:
  #
  # 7.11.2022
  # 19.11.2022
  #
  # To verify that a charge was made _today_ we ensure that the latest order on
  # the web interface starts with the above date string - we don't care about
  # the hours, minutes or seconds.
  #
  # To test padding and failures get earlier or later date, replacing NOW with
  # NOW - 12d or similar
  #
  ${current_day_zero_padded}=  BuiltIn.Get Time  day  NOW
  ${current_day}=  String.Replace String Using Regexp  ${current_day_zero_padded}  ^0  ${EMPTY}
  ${current_month_zero_padded}=  BuiltIn.Get Time  month  NOW
  ${current_month}=  String.Replace String Using Regexp  ${current_month_zero_padded}  ^0  ${EMPTY}
  ${current_year}=  BuiltIn.Get Time  year  NOW
  ${current_date}=  BuiltIn.Catenate  SEPARATOR=.  ${current_day}  ${current_month}  ${current_year}

  # Check if the latest order is from today
  BuiltIn.Should Start With  ${latest_order_time}  ${current_date}

  # Check if the latest order was successful
  BuiltIn.Should Be Equal As Strings  ${latest_order_status}  onnistunut
