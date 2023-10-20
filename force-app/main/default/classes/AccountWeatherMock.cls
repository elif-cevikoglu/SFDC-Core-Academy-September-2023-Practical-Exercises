@IsTest
global class AccountWeatherMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"coord\":{\"lon\":-118.2437,\"lat\":34.0522},\"weather\":[{\"id\":800,\"main\":\"Clear\",\"description\":\"clear sky\",\"icon\":\"01d\"}],\"base\":\"stations\",\"main\":{\"temp\":301.18,\"feels_like\":302.21,\"temp_min\":292.57,\"temp_max\":312.15,\"pressure\":1012,\"humidity\":56},\"visibility\":10000,\"wind\":{\"speed\":5.14,\"deg\":260},\"clouds\":{\"all\":0},\"dt\":1697671366,\"sys\":{\"type\":1,\"id\":3694,\"country\":\"US\",\"sunrise\":1697637612,\"sunset\":1697678145},\"timezone\":-25200,\"id\":5368361,\"name\":\"Los Angeles\",\"cod\":200}');
        response.setStatusCode(200);
        return response; 
    }
}
