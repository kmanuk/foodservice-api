TOKENIZATION_RESPONSE = {
    r: 'tokenization_response',
    response_code: '18000',
    signature: 'a2495ef11ee1509709ee46f4ae4e47e6fb06770475bbc60cf5e6c8710e256e1dd4ce6577e22e1a931699088a8ebc08f37536a3195e25a5a563dff78577d1b4a4',
    remember_me: 'YES',
    card_number: '400555******0001',
    card_holder_name: 'Test',
    merchant_identifier: 'TMclWFPP',
    expiry_date: '1705',
    access_code: 'wzBTueYAgOw1eD9Msp6m',
    language: 'en',
    service_command: 'TOKENIZATION',
    response_message: 'Success',
    merchant_reference: '5e3lovi03rcpho0m',
    token_name: '4CDFC96AAC3C6B6EE053321E320AF70E',
    return_url: 'https://api.staging.foodinhoods.com/api/v1/payments/callback?r=tokenization_response',
    card_bin: '400555',
    status: '18'
}
TOKENIZATION_RESPONSE_2 =
    {r: 'tokenization_response',
     response_code: '18000',
     signature: 'f76e31662f95c98ba6219b2f67beec972725216098d8d2c37c6f4ac72bb4e1c3062f95d14038f6aa2a4b7a48d1a8603541d3f810735690036ccfc3d36e2d8a54',
     remember_me: 'NO',
     card_number: '400555******0001',
     card_holder_name: 'tsest',
     merchant_identifier: 'TMclWFPP',
     expiry_date: '2105',
     access_code: 'wzBTueYAgOw1eD9Msp6m',
     language: 'en',
     service_command: 'TOKENIZATION',
     response_message: 'Success',
     merchant_reference: 'ml1cv6uonc6nrfj4',
     token_name: '5030F096F84F5F27E053321E320A0359',
     return_url: 'http://localhost:3000/api/v1/payments/callback?r=tokenization_response',
     card_bin: '400555',
     status: '18'}

AUTHORIZATION_RESPONSE = {
    r: 'authorization_response',
    response_code: '02000',
    signature: '5720793dd70d5ef57c5fe5dca05748198a1e09965412122ca3eaccb91caf3fbe022ffe978e3e781714dab7c71ce599755a0aef7430d7e636a7736e7cf186276b',
    remember_me: 'NO',
    card_number: '455701******8902',
    authorization_code: '303581',
    card_holder_name: 'Test',
    merchant_identifier: 'TMclWFPP',
    expiry_date: '1705',
    access_code: 'wzBTueYAgOw1eD9Msp6m',
    language: 'en',
    response_message: 'Success',
    merchant_reference: 'o2qt1l4u7s1eahpt',
    status: '02',
    amount: '800',
    payment_option: 'VISA',
    customer_ip: '127.0.0.1',
    eci: 'ECOMMERCE',
    fort_id: '149548823100003453',
    command: 'AUTHORIZATION',
    customer_email: 'denys.khraponenko@customertimes.com',
    currency: 'SAR',
    customer_name: 'Denys K'
}

D_SECURE_REQUESTED = {
    amount: '800',
    response_code: '20064',
    card_number: '455701******8902',
    card_holder_name: 'Test',
    signature: '14a3816206e26d22af48deb8e23e111bb466c190e0e697370a9870958313c8e4b7841087349423df86b48ea2f55a0736ffeed2bf2b51cc6176eb436c7a302510',
    merchant_identifier: 'TMclWFPP',
    access_code: 'wzBTueYAgOw1eD9Msp6m',
    expiry_date: '1705',
    payment_option: 'VISA',
    customer_ip: '127.0.0.1',
    language: 'en',
    eci: 'ECOMMERCE',
    fort_id: '149548823100003453',
    command: 'AUTHORIZATION',
    '3ds_url' => 'https://testfort.payfort.com/secure3dsSimulator?FORTSESSIONID=hfsjpjbkhbueu9g6e8a1hfg675&paymentId=5740559166725965820&DOID=C70BAA4D83511CCADAEC071226C925FB&o=pt&action=retry',
    response_message: '3-D Secure check requested',
    merchant_reference: 'o2qt1l4u7s1eahpt',
    customer_email: 'denys.khraponenko@customertimes.com',
    currency: 'SAR',
    customer_name: 'Denys K',
    remember_me: 'NO',
    status: '20'
}


CAPTURE_SUCCESS_RESPONSE = {response_code: '04000',
                            amount: '3300',
                            signature: '8dc76bf952c6a9a6b8b0c789c34dc673f0ee044e1dfdce5a70e6145a74c206407ea203a1afdd2f850c030f51478eee7bc7f6d8f80212ecb33333179e84ab9923',
                            merchant_identifier: 'TMclWFPP',
                            access_code: 'wzBTueYAgOw1eD9Msp6m',
                            language: 'en',
                            fort_id: '149310848300056962',
                            command: 'CAPTURE',
                            response_message: 'Success',
                            merchant_reference: '1wdpgxzwy5wxuxp0',
                            currency: 'SAR',
                            status: '04'}

CANCEL_SUCCESS_RESPONSE = {response_code: '08000',
                           response_message: 'Success',
                           signature: '9e2c05d6bc9e05ef56034d8a0e3ca532be7299bed3da679c2ff8b92ca83c60d8835ae93ecf30b963baa39a5813097ccbdaab4a758f538dd9e27945125f68c1d7',
                           merchant_identifier: 'TMclWFPP',
                           merchant_reference: 'qqpcbhcjqx28v241',
                           access_code: 'wzBTueYAgOw1eD9Msp6m',
                           language: 'en',
                           fort_id: '149311601200057346',
                           command: 'VOID_AUTHORIZATION',
                           status: '08'}

CALLBACK_PAYFORT_AUTHORIZATION__SUCCESS = {amount: '1900',
                                           response_code: '02000',
                                           card_number: '400555******0001',
                                           card_holder_name: 'Test',
                                           signature: 'cd48af2fba7a99dd5613314f6687790dda0b45ed2fa34d362b91ddac0ad87da76e5c7d1b93e85ff06c9f5bce2635c4c1d1f1445ba9dc06aae1ab70a9a9cec083',
                                           merchant_identifier: 'TMclWFPP',
                                           access_code: 'wzBTueYAgOw1eD9Msp6m',
                                           expiry_date: '2105',
                                           payment_option: 'VISA',
                                           customer_ip: '127.0.0.1',
                                           language: 'en',
                                           eci: 'ECOMMERCE',
                                           fort_id: '149552702500004194',
                                           command: 'AUTHORIZATION',
                                           response_message: 'Success',
                                           merchant_reference: 'eain1vcyijv5ry9n',
                                           authorization_code: '308571',
                                           customer_email: 'gaylord@lefflerhermiston.co',
                                           currency: 'SAR',
                                           remember_me: 'NO',
                                           customer_name: 'Arvel Becker',
                                           status: '02'}


CUSTOM_PAYFORT_AUTHORIZATION_RESPONSE_FAIL = {
    amount: '800',
    response_code: '00044',
    signature: '6143bc5f1dfd1c07f0f8214136520012424e87ce306f06ef667162ff906527de4e9598c9e7d7d52d3f29bdcfa6be61c0416394a8f9d0de700a6a80f08d61e334',
    merchant_identifier: 'TMclWFPP',
    access_code: 'wzBTueYAgOw1eD9Msp6m',
    customer_ip: '127.0.0.1',
    language: 'en',
    eci: 'ECOMMERCE',
    command: 'AUTHORIZATION',
    response_message: 'Token name does not exist',
    merchant_reference: 'o2qt1l4u7s1eahpt',
    customer_email: 'denys.khraponenko@customertimes.com',
    currency: 'SAR',
    customer_name: 'Denys K',
    remember_me: 'NO',
    status: '00'
}



