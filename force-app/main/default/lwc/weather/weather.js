import { LightningElement, api } from 'lwc';
import getWeatherApex from "@salesforce/apex/AccountWeatherHandler.getWeather";

export default class Weather extends LightningElement {
    @api recordId;

    isLoading = true;
    hasError = false;
    title = '';
    city = '';
    errorMessage = '';
    temperature = '';
    description = '';
    iconUrl = '';

    async connectedCallback() {
        try {
            const response = await getWeatherApex({recordId: this.recordId});
            const responseArr = response.split(';');
            if (responseArr[0] === 'error') {
                this.hasError = true;
                if (responseArr[1] == 'noCity') {
                    this.errorMessage = 'Please enter a Shipping City or Billing City to be able to see the weather.';
                    this.title = `Can't Get the Weather`;
                } else {
                    this.city = responseArr[2];
                    this.errorMessage = 'There was an error fetching the weather. Please contact your admin.';
                    this.title = `Can't Get the Weather in ${this.city}`;
                }
            } else {
                this.hasError = false;
                this.city = responseArr[1];
                this.temperature = responseArr[2];
                this.description = responseArr[3];
                this.iconUrl = `http://openweathermap.org/img/wn/${responseArr[4]}.png`;
                this.title = `Weather in ${this.city}`;
            }
            this.isLoading = false;
        } catch(error) {
            console.log(error);
        }
    }
}