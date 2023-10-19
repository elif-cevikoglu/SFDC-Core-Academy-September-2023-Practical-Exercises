public with sharing class AccountWeatherHandler {
    @AuraEnabled
    public static String getWeather(String recordId) {
        try {
            String response;
            Account acct = [SELECT Id, ShippingCity, BillingCity FROM Account WHERE Id = :recordId];
            if (acct.ShippingCity == null || acct.ShippingCity == '') {
                if (acct.BillingCity == null || acct.BillingCity == '') {
                    response = 'error;noCity';
                } else {
                    response = fetchWeather(acct.BillingCity);
                }
            } else {
                response = fetchWeather(acct.ShippingCity);
            }
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String fetchWeather(String city) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.openweathermap.org/data/2.5/weather?q='+city+'&appid=bbb6f42610f26dbe8256cd4aa6b3dfcf');
        request.setMethod('GET');
        HTTPResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            AccountWeatherWrapper body = (AccountWeatherWrapper) System.JSON.deserialize(response.getBody(), AccountWeatherWrapper.class);

            String temperature = String.valueOf(body.Main.temp);
            String description = body.weather[0].description;
            String iconUrl = body.weather[0].icon;

            return 'success;'+city+';'+temperature+';'+description+';'+iconUrl;
        } else {
            return 'error;httpError;'+city;
        }
    }
}