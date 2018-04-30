[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org) [![Badges](http://img.shields.io/:badges-9/9-ff6799.svg?style=flat-square)](https://github.com/badges/badgerbadgerbadger)

# Still Pending - Assignment 3
---







## Table of Contents

- [Assumptions](#assumptions)
- [Contribution](#contribution)

---


## Assumptions

CALC_PERCENT_OF_GOAL_PF:
Assumption: Returning a negative number to denote an error is acceptable for the function.

VIEW_CART_PP:
Assumption: The gratuity entries in the donation carts are records that will exist in the database as part of the Donation tables and as such are not explicitly coded into the package procedure.

ADD_WEBSITE_PP:
Assumption: The original website order is already in sequence (as illustrated in assignment 2) and the procedure is not responsible for re-sequencing orders that are modified outside of the procedure. This means, if the existing order is 1-2-4, there is no expectation that the procedure corrects the order to 1-2-3-4 when a new website is added.

ADD_DONATION_PP:
Assumption: Due to some confusion on whether or not we were allowed to add new tables, we initially designed this table for I_DONATION_DETAIL, while later discovering that we were allowed to create new tables if we wanted to, provided that the pre-existing structure was untouched.
This provided some issues during development, which were unfortunately unsolved as of 11.04.2018.

UPDATE_DONATION_PP:
Assumption: Same as ADD_DONATION_PP.

CHECKOUT_PP
Assumption: Confusion with the structure made it difficult to execute this procedure completely


STATUS_UNDERWAY_PP
Assumption: I had some confusion with the updating the status to “open” and “underway and the select count in status underway. The problem was solved by using SUM and Update in a correct way. 

PROJ_TYPE_PP
Assumption: straightforward, from assignment 2.

---

## Contribution

Ali Al-Musawi 

Eirik Fintland 

Peter Kwasa 

Osman Younas

---


