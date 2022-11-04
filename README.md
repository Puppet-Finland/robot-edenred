# robot-edenred

This repository contains [Robot Framework](https://robotframework.org/)
scripts for automating Edenred operations.

These scripts have been created because charging Edenred cards manually is
such a painful and confusing operation that we often did not get our benefits
because of user errors, or simply because we forgot to charge the cards in
time. So, we wanted to make the process standardized, automated and reliable.
These scripts are a core part of that process. Automation can be handled from
cron by a Linux-based Robot with a graphical desktop (e.g. xfce4). While
Robot scripts tend to be fairly reliable, we recommend monitoring them with
[Prometheus](https://prometheus.io/) using our Textfile Collector script called
[robot-collector](https://github.com/Puppet-Finland/robot-collector). That
way, if the Edenred website ever changes and the script break, you get an
alert.

# Mass operations using CSV files

The [ticket.edenred.fi](ticket.edenred.fi) service allows manipulating users
and charging their Edenred cards by uploading a specially formatted CSV file
(see [cardholder list page](https://ticket.edenred.fi/cardholder-management/cardholder-list/) for details).

## charge-edenred.robot

This Robot script allows you to charge employee Edenred cards. It depends on
the
[Browser](https://marketsquare.github.io/robotframework-browser/Browser.html)
library. Credentials and the path to the CSV file are passed as environment
variables.

This script probably will not work for other CSV operations which may or may
not present the user (or Robot) with completely different prompts.

Example usage from a Linux terminal:

    EDENRED_USERNAME=my_email EDENRED_PASSWORD=secret CSV_FILE_PATH=charge.csv robot tasks/charge-edenred.robot
