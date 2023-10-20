@IsTest
private class AccountWeatherTest {
    @IsTest
    private static void testGetWeatherShipping() {
        Account acct = new Account(Name='TestAccount', ShippingCity='Los Angeles');
        insert acct;
        Test.setMock(HttpCalloutMock.class, new AccountWeatherMock());
        Test.startTest();
        String response = AccountWeatherHandler.getWeather(acct.Id);
        Test.stopTest();
        System.assertEquals('success;Los Angeles;301.18;clear sky;01d', response);
    }

    @IsTest
    private static void testGetWeatherBilling() {
        Account acct = new Account(Name='TestAccount', BillingCity='Los Angeles');
        insert acct;
        Test.setMock(HttpCalloutMock.class, new AccountWeatherMock());
        Test.startTest();
        String response = AccountWeatherHandler.getWeather(acct.Id);
        Test.stopTest();
        System.assertEquals('success;Los Angeles;301.18;clear sky;01d', response);
    }

    @IsTest
    private static void testGetWeatherNoCity() {
        Account acct = new Account(Name='TestAccount');
        insert acct;
        Test.setMock(HttpCalloutMock.class, new AccountWeatherMock());
        Test.startTest();
        String response = AccountWeatherHandler.getWeather(acct.Id);
        Test.stopTest();
        System.assertEquals('error;noCity', response);
    }
}