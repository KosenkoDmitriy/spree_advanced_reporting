# Advanced Reporting

Advanced reporting for Spree.

## Includes:
* Base reports of Revenue, Units, Profit into Daily, Weekly, Monthly, and Yearly increments
* Geo reports of Revenue, Units divided into states and countries
* Two "top" reports for top products and top customers
* All customer report that displays the number of orders in a period of time as well if customer was a new customer during that time peroid.
* The ability to limit reports by order date, "store" (multi-store extension), product, and taxon.
* The ability to export data in PDF or CSV format.


## Dependencies:
* Ruport and Ruport-util
* Google Visualization
* Ruby 1.9.3+


## NOTES:

This extension seems in flux, having many forks, but no official rails3/rails4 update.
This branch is for use with **Spree 3.0.0**. It will likely not work with
earlier versions.


### 2.2-related changes:

1. Complete overhaul to report GUI
2. Update references to `AVAILABLE_REPORTS`
3. Fix Taxon and Product searches to work with Spree 2.2
4. Fix Daily/Weekly/Monthly/Quarterly/Yearly reports to work with Spree 2.2
5. Cleaned up `README`


### Earlier changes

Forked from what appeared to the be the most up to date for, and made the following general changes:

1. Removed PDF generation, which isn't working under Ruby 1.9.x
2. Removed the route that overrides the main admin overview page
3. Fixed a warning about ```ADVANCED_REPORTS``` being redefined
4. Fixed the en.yml translation lookups
5. Change the I18 default locale to use the Rails setting
