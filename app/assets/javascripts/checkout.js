function getPaymentPage() {
    // var check3ds = getUrlParameter('3ds');
    // var url = 'route.php?r=getPaymentPage';
    // if (check3ds == 'no') {
    //     url = url + '&3ds=no';
    // }
    $.ajax({
        url: '/api/v1/payments',
        type: 'post',
        dataType: 'json',
        success: function (response) {
            if (response.form) {
                $('body').append(response.form);
                var expDate = $('#payfort_fort_mp2_expiry_year').val() + '' + $('#payfort_fort_mp2_expiry_month').val();
                var mp2_params = {};
                mp2_params.card_holder_name = $('#payfort_fort_mp2_card_holder_name').val();
                mp2_params.card_number = $('#payfort_fort_mp2_card_number').val();
                mp2_params.expiry_date = expDate;
                mp2_params.card_security_code = $('#payfort_fort_mp2_cvv').val();
                $.each(mp2_params, function (k, v) {
                    $('<input>').attr({
                        type: 'hidden',
                        id: k,
                        name: k,
                        value: v
                    }).appendTo('#payfort_payment_form');
                });
                $('#payfort_payment_form input[type=submit]').click();

            }
        }
    });
}

var payfortFortMerchantPage2 = (function () {
    return {
        validateCcForm: function () {
            this.hideError();
            var isValid = payfortFort.validateCardHolderName($('#payfort_fort_mp2_card_holder_name'));
            if(!isValid) {
                this.showError('Invalid Card Holder Name');
                return false;
            }
            isValid = payfortFort.validateCreditCard($('#payfort_fort_mp2_card_number'));
            if(!isValid) {
                this.showError('Invalid Credit Card Number');
                return false;
            }
            isValid = payfortFort.validateCvc($('#payfort_fort_mp2_cvv'));
            if(!isValid) {
                this.showError('Invalid Card CVV');
                return false;
            }
            return true;
        },
        showError: function(msg) {
            alert(msg);
        },
        hideError: function() {
            return;
        }
    };
})();

