jQuery(document).ready(function ($) {

    jQuery('#btn_continue').click(function () {
        var isValid = payfortFortMerchantPage2.validateCcForm();
        if (isValid) {
            getPaymentPage();
        }

    });
});