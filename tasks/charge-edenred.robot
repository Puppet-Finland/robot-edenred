*** Settings ***

Resource  ../resources/common.robot

Task Setup     Begin Browser Web Test
Task Teardown  End Browser Web Test

*** Tasks ***

Login To Edenred
  Browser.Set Browser Timeout         timeout=20s
  Browser.New Page                    ${EDENRED_MAIN_PAGE}
  Browser.Fill Text                   id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_LogonForm_Login1_UserName  ${EDENRED_USERNAME}
  Browser.Fill Text                   id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_LogonForm_Login1_Password  ${EDENRED_PASSWORD}
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_LogonForm_Login1_LoginButton
  Browser.Wait Until Network Is Idle  timeout=5s
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneMain_EdenredFi_WOT_CardSelection_CardSelection_lnkTD
  Browser.Click                       text=Työntekijöiden hallinta
  Browser.Click                       text=Päivitys csv-tiedostolla
  Upload File By Selector             id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_FileUpload  ${CSV_FILE_PATH}
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_btnUpload
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_datePicker_btnNow
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_datePicker2_btnNow
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_btnSubmit
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_cdlgSubmit_confirmCheckBox
  Browser.Click                       id=p_lt_zoneContent_pageplaceholder_p_lt_zoneBottom_EdenredFi_WOT_CardHolderManagement_CardHolderFile_cdlgSubmit_btnSubmit
