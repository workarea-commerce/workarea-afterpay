Workarea Afterpay 2.1.2 (2020-05-06)
--------------------------------------------------------------------------------

*   Fix error showing admin config panel


    Ben Crouse



Workarea Afterpay 2.1.1 (2020-05-04)
--------------------------------------------------------------------------------

*   Respect payment declined in authorize transactions


    Ben Crouse

*   Respect decline payment responses in capture and purchase operations

    Fixes #3

    Ben Crouse

*   Add CI and rubocop linting


    Jeff Yucis



Workarea Afterpay 2.1.0 (2019-11-12)
--------------------------------------------------------------------------------

*   Update Afterpay API version to V2

    New API version allows for a traditional auth then capture
    model of handling payments. Updates also include idempotent
    payment operations
    Jeff Yucis

*   Update Afterpay API version to V2

    New API version allows for a traditional auth then capture
    model of handling payments. Updates also include idempotent
    payment operations
    Jeff Yucis

*   Update README

    Matt Duffy



Workarea Afterpay 2.0.2 (2019-08-21)
--------------------------------------------------------------------------------

*   Open Source!



Workarea Afterpay 2.0.1 (2019-06-11)
--------------------------------------------------------------------------------

*   Show correct dialog for Australia

    AFTERPAY-28
    Jeff Yucis



Workarea Afterpay 2.0.0 (2019-05-28)
--------------------------------------------------------------------------------

*   Afterpay 2.0.0

    no changes from Afterpay v2.0.0.beta.1
    Eric Pigeon



Workarea Afterpay 2.0.0.beta.1 (2019-05-24)
--------------------------------------------------------------------------------

*   Implement afterpay dialog designs

    * Add styleguide component for US and AUS
    * Add afterpay assets - images and raleway font
    * Add afterpay-dialog Sass component
    * Add afterpay_dialog controller
    * Add views for AUS and US dialogs
    * Update afterpay_helper to use afterpay_dialog routes
    * Remove redundant config
    * Display show more link inline with afterpay info in cart & clean up incomplete class
    * Add Helper in engine, remove decorator for application controller

    AFTERPAY-20
    Jake Beresford

*   Integrate with afterpay australia api

    Contextually switch the api endpoints based on a users location, which
    in derived from their currency. Commit also displays the correct
    terms for the users integration type.

    AFTERPAY-16
    Jeff Yucis

*   Remove ID attribute from from_checkout field to prevent duplicate ID errors when installed with Workarea-PayPal

    AFTERPAY-27
    Jake Beresford

*   Pass suburb to billing and shipping addresses

    Split out the billing and shipping address to use the data from
    payment and shipping respectively.

    AFTERPAY-17
    Jeff Yucis

*   Pass test flag to gateway when present in secrets.

    AFTERPAY-18
    Jeff Yucis



Workarea Afterpay 1.0.2 (2019-03-05)
--------------------------------------------------------------------------------

*   Fix casing of Afterpay in translation file

    AFTERPAY-14
    Jeff Yucis



Workarea Afterpay 1.0.1 (2019-02-19)
--------------------------------------------------------------------------------

*   Auto capture afterpay payments

    Afterpay recomends performing an auth with immediate capture when
    processing the payment. This allows refunds to be placed via the
    workarea admin.

    AFTERPAY-12
    Jeff Yucis

*   Clear credit card tender when adding afterpay

    AFTERPAY-13
    Jeff Yucis



Workarea Afterpay 1.0.0 (2018-11-28)
--------------------------------------------------------------------------------

*   Check that the order is in an eligible country

    Commit supresses afterpay from displaying if the currecny is not in a
    supported country.

    AFTERPAY-8
    Jeff Yucis

*   Place afterpay orders immediatly upon returning from afterpay

    AFTERPAY-9
    Jeff Yucis



Workarea Afterpay 1.0.0.beta.3 (2018-10-23)
--------------------------------------------------------------------------------

*   Correct api cache behavior for multisite

    AFTERPAY-7
    Jeff Yucis

*   Improve messaging around tenders on order conf, admin and mailers

    Commit also fixes bug in order balance check for elibility

    AFTERPAY-6
    Jeff Yucis



Workarea Afterpay 1.0.0.beta.2 (2018-10-08)
--------------------------------------------------------------------------------

*   Allow afterpay to be used with split tender orders.

    AFTERPAY-5
    Jeff Yucis



Workarea Afterpay 1.0.0.beta.1 (2018-10-03)
--------------------------------------------------------------------------------

*   Add afterpay as payment option

    Commit allows users to checkout with afterpay. Relevant options are
    displayed if a users order qualifies for afterpay

    AFTERPAY-3
    Jeff Yucis



