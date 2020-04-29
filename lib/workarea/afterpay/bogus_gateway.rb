module Workarea
  module Afterpay
    class BogusGateway
      def initialize(*)
      end

      def get_configuration
        b = {
            "minimumAmount": {
                 "amount": "5.00",
                 "currency": "USD"
             },
            "maximumAmount": {
                "amount": "500.00",
                "currency": "USD"
            }
          }

        Response.new(response(b))
      end

      def get_order(token, options = {})
        b = {
              "billing": {
                  "countryCode": "US",
                  "line1": "29 fort mott road",
                  "name": "Jeffrey Yucis",
                  "phoneNumber": "3027507743",
                  "postcode": "08070",
                  "state": "NJ",
                  "suburb": "pennsville"
              },
              "consumer": {
                  "email": "jyucis@gmail.com",
                  "givenNames": "Jeffrey",
                  "phoneNumber": "3027507743",
                  "surname": "Yucis"
              },
              "courier": {},
              "discounts": [],
              "expires": "2019-04-02T16:52:43.920Z",
              "items": [
                  {
                      "name": "Small Wool Coat",
                      "price": {
                          "amount": "89.30",
                          "currency": "USD"
                      },
                      "quantity": 1,
                      "sku": "139364945-9"
                  }
              ],
              "merchant": {
                  "redirectCancelUrl": "http://localhost:3000/afterpay/cancel",
                  "redirectConfirmUrl": "http://localhost:3000/afterpay/complete"
              },
              "merchantReference": "63837A272F",
              "paymentType": "PAY_BY_INSTALLMENT",
              "shipping": {
                  "countryCode": "US",
                  "line1": "29 fort mott road",
                  "name": "Jeffrey Yucis",
                  "phoneNumber": "3027507743",
                  "postcode": "08070",
                  "state": "NJ",
                  "suburb": "pennsville"
              },
              "shippingAmount": {
                  "amount": "6.00",
                  "currency": "USD"
              },
              "taxAmount": {
                  "amount": "0.00",
                  "currency": "USD"
              },
              "token": "9tlqhfgebl6mu2g9t98rre2ia25ri2hvadc4aaimvpca1p9fma5j",
              "amount": {
                  "amount": "95.30",
                  "currency": "USD"
              }
          }
        Response.new(response(b))
      end

      def create_order(order)
        b = {
          "token": "q54l9qd907m6iqqqlcrm5tpbjjsnfo47vsm59gqrfnd2rqefk9hu",
          "expires": "2016-05-10T13:14:01Z"
        }

        Response.new(response(b))
      end

      def capture(payment_id, amount, request_id)
        if payment_id == 'declined'
          Response.new(response(payment_response_body(status: 'DECLINED'), 200))
        else
          Response.new(response(payment_response_body, 200))
        end
      end

      def authorize(token, order_id = "", request_id)
        if token == "error_token"
          Response.new(response(capture_error_response_body, 402))
        elsif token == "timeout_token"
          Response.new(response(nil, 502))
        else
          Response.new(response(payment_response_body, 200))
        end
      end

      def purchase(token, order_id = "", request_id)
        if token == "error_token"
          Response.new(response(capture_error_response_body, 402))
        elsif token == 'declined'
          Response.new(response(payment_response_body(status: 'DECLINED'), 200))
        else
          Response.new(response(payment_response_body, 200))
        end
      end

      def refund(afterpay_order_id, amount, request_id)
        b = {
          "requestId": "61cdad2d-8e10-42ec-a97b-8712dd7a8ca9",
          "amount": {
              "amount": "10.00",
              "currency": "USD"
          },
          "merchantReference": "RF127261AD22",
          "refundId": "56785678",
          "refundedAt": "2015-07-10T15:01:14.123Z"
        }

        Response.new(response(b))
      end

      def void(payment_id)
        Response.new(response(payment_response_body))
      end

      private

        def response(body, status = 200)
          response = Faraday.new do |builder|
            builder.adapter :test do |stub|
              stub.get("/v1/bogus") { |env| [ status, {}, body.to_json ] }
            end
          end
          response.get("/v1/bogus")
        end

        def capture_error_response_body
          {
            "errorCode": "declined",
            "errorId": "c4d64cbc3e61a26f",
            "message": "Payment declined",
            "httpStatusCode":  402
          }
        end

        def payment_response_body(status: 'APPROVED')
          {
            "id": "12345678",
             "token": "q54l9qd907m6iqqqlcrm5tpbjjsnfo47vsm59gqrfnd2rqefk9hu",
             "status": status,
             "created": "2015-07-14T10:08:14.123Z",
             "totalAmount": {
                "amount": "21.85",
                "currency": "USD"
             },
             "merchantReference": "merchantOrder-1234",
             "refunds": [],
             "orderDetails": {
                  "consumer": {
                     "phoneNumber": "0200000000",
                     "givenNames": "Joe",
                     "surname": "Consumer",
                     "email": "test@afterpay.com"
                  },
                 "billing": {
                     "name": "Joe Consumer",
                     "line1": "75 Queen St",
                     "state": "New York",
                     "postcode": "10001",
                     "countryCode": "US",
                     "phoneNumber": "2120000000"
                 },
                 "shipping": {
                     "name": "Joe Consumer",
                     "line1": "75 Queen St",
                     "state": "New York",
                     "postcode": "10001",
                     "countryCode": "US",
                     "phoneNumber": "2120000000"
                 },
                 "courier": {},
                 "items": [
                    {
                        "name": "widget",
                        "sku": "12341234",
                        "quantity": 1,
                        "price": {
                            "amount": "10.00",
                            "currency": "USD"
                        }
                    }
                 ],
                 "discounts": [
                    {
                        "displayName": "10% Off Subtotal",
                        "amount": {
                            "amount": "1.00",
                            "currency": "USD"
                        }
                    }
                 ],
                 "shippingAmount": {
                    "amount": "10.00",
                    "currency": "USD"
                 },
                 "taxAmount": {
                    "amount": "2.85",
                    "currency": "USD"
                 }
             },
            "events": []
          }
        end
    end
  end
end
