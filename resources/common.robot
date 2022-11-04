*** Settings ***

Library  Browser

*** Variables ***

# Browser settings
${BROWSER}  firefox

# Relevant pages
${EDENRED_MAIN_PAGE}  https://ticket.edenred.fi

# Parameters are taken from environment variables
${EDENRED_USERNAME}   %{EDENRED_USERNAME}
${EDENRED_PASSWORD}   %{EDENRED_PASSWORD}
${CSV_FILE_PATH}      %{CSV_FILE_PATH}

*** Keywords ***

Begin Browser Web Test
    Browser.New Browser  ${BROWSER}  false

End Browser Web Test
    Browser.Close Browser
