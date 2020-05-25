var payfortFort = (function () {
    return {
        validateCreditCard: function (element) {
            var isValid = false;
            var eleVal = $(element).val();
            eleVal = this.trimString(element.val());
            eleVal = eleVal.replace(/\s+/g, '');
            $(element).val(eleVal);
            $(element).validateCreditCard(function (result) {
                /*$('.log').html('Card type: ' + (result.card_type == null ? '-' : result.card_type.name)
                 + '<br>Valid: ' + result.valid
                 + '<br>Length valid: ' + result.length_valid
                 + '<br>Luhn valid: ' + result.luhn_valid);*/
                isValid = result.valid;
            });
            return isValid;
        },
        validateCardHolderName: function (element) {
            $(element).val(this.trimString(element.val()));
            var cardHolderName = $(element).val();
            if (cardHolderName.length > 50) {
                return false;
            }
            return true;
        },
        validateCvc: function (element) {
            $(element).val(this.trimString(element.val()));
            var cvc = $(element).val();
            if (cvc.length > 4 || cvc.length == 0) {
                return false;
            }
            if (!this.isPosInteger(cvc)) {
                return false;
            }
            return true;
        },
        isDefined: function (variable) {
            if (typeof (variable) === 'undefined' || typeof (variable) === null) {
                return false;
            }
            return true;
        },
        trimString: function (str) {
            return str.trim();
        },
        isPosInteger: function (data) {
            var objRegExp = /(^\d*$)/;
            return objRegExp.test(data);
        }
    };
})();

var payfortFortMerchantPage2 = (function () {
    return {
        validateCcForm: function () {
            this.hideError();
            var isValid = payfortFort.validateCardHolderName($('#payfort_fort_mp2_card_holder_name'));
            if (!isValid) {
                this.showError('Invalid Card Holder Name');
                return false;
            }
            isValid = payfortFort.validateCreditCard($('#payfort_fort_mp2_card_number'));
            if (!isValid) {
                this.showError('Invalid Credit Card Number');
                return false;
            }
            isValid = payfortFort.validateCvc($('#payfort_fort_mp2_cvv'));
            if (!isValid) {
                this.showError('Invalid Card CVV');
                return false;
            }
            return true;
        },
        showError: function (msg) {
            alert(msg);
        },
        hideError: function () {
            return;
        }
    };
})();