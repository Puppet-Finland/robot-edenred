*** Settings ***

Library  Browser
Library  String

*** Variables ***

# Browser settings
${BROWSER}  firefox

# Relevant pages
${EDENRED_MAIN_PAGE}  https://ticket.edenred.fi

# Parameters are taken from environment variables
${EDENRED_USERNAME}        %{EDENRED_USERNAME}
${EDENRED_PASSWORD}        %{EDENRED_PASSWORD}
${LOUNAS_CSV_FILE_PATH}    %{LOUNAS_CSV_FILE_PATH}
${TYOMATKA_CSV_FILE_PATH}  %{TYOMATKA_CSV_FILE_PATH}

*** Keywords ***

Begin Browser Web Test
    Browser.New Browser  ${BROWSER}  false
    Browser.Set Browser Timeout  1m

End Browser Web Test
    Browser.Close Browser

Login To Edenred
  Browser.Set Browser Timeout         timeout=20s
  Browser.New Page                    ${EDENRED_MAIN_PAGE}
  Browser.Fill Text                   id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_LogonForm_Login1_UserName  ${EDENRED_USERNAME}
  Browser.Fill Text                   id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_LogonForm_Login1_Password  ${EDENRED_PASSWORD}
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_LogonForm_Login1_LoginButton
  Browser.Wait Until Network Is Idle  timeout=5s

Go To Lounas Card
  Browser.Click  id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_CardSelection_CardSelection_lnkTD

Go To Tyomatka Card
  Browser.Click  id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_CardSelection_CardSelection_lnkTT

Go To CSV Charging
  Browser.Click  text=Työntekijöiden hallinta
  Browser.Click  text=Päivitys csv-tiedostolla

Upload CSV
  [Arguments]  ${CSV_FILE_PATH}
  Upload File By Selector  id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_FileUpload  ${CSV_FILE_PATH}
  Browser.Click            id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_btnUpload

# There are two charge dates to select (Lounas and Virike)
Select Charge Date Lounas
  Browser.Click            id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_datePicker_btnNow
  Browser.Click            id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_datePicker2_btnNow
  Browser.Click            id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_btnSubmit

Select Charge Date Tyomatka
  Browser.Click            id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_datePicker_btnNow
  Browser.Click            id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_btnSubmit

Submit Charge Order
  Browser.Click            id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_cdlgSubmit_confirmCheckBox
  # Comment out the following line to test the whole process without actually submitting the order
  Browser.Click            id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_cdlgSubmit_btnSubmit
  # It looks like the orders fail often if the browser exits too quickly after placing the order
  BuiltIn.Sleep  3

Charge Lounas Card With CSV
  Upload CSV  ${LOUNAS_CSV_FILE_PATH}
  Select Charge Date Lounas
  Submit Charge Order

Charge Tyomatka Card With CSV
  Upload CSV  ${TYOMATKA_CSV_FILE_PATH}
  Select Charge Date Tyomatka
  Submit Charge Order

Validate Latest CSV Order
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
