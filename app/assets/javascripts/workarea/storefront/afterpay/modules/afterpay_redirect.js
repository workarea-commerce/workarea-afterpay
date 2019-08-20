/**
 * @namespace WORKAREA.afterpayRedirect
 */
WORKAREA.registerModule('afterpayRedirect', (function () {
    'use strict';

    var redirectToAfterpay = function(token, country){
            window.AfterPay.initialize({countryCode: country});
            window.AfterPay.redirect({token: token});
        },

        getAfterpay = function(token, country) {
            $.getScript(WORKAREA.config.afterpay.afterpayScript, _.partial(redirectToAfterpay, token, country));
        },


        init = function ($scope) {
            var $afterpayMethod = $('[data-afterpay-token]', $scope),
                token = $afterpayMethod.data('afterpayToken'),
                country = $afterpayMethod.data('afterpayCountry');

            if (_.isEmpty(token)) { return; }

            getAfterpay(token, country);
        };

    return {
        init: init
    };
}()));
