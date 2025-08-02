import requests
import os
import time
from prometheus_client import Gauge, start_http_server

API_KEY = os.environ.get("WEATHER_API_KEY")
FETCH_INTERVAL = int(os.environ.get("FETCH_INTERVAL", 10))
PROMETHEUS_PORT = int(os.environ.get("PROMETHEUS_PORT", 8000))

if not API_KEY:
    raise ValueError("WEATHER_API_KEY is not set in the environment.")

url = (
    f"https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/"
    f"timeline/tallinn?unitGroup=metric&key={API_KEY}&contentType=json"
)
temperature_gauge = Gauge("weather_temperature_celsius", "Temperature in Celsius")
humidity_gauge = Gauge("weather_humidity_percent", "Humidity in percent")
pressure_gauge = Gauge("weather_pressure_mb", "Pressure in millibars")

def fetch_weather():
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()

        current = data.get("currentConditions")
        if current:
            temp = current.get("temp")
            hum = current.get("humidity")
            pres = current.get("pressure")
            desc = current.get("conditions")

            print(f"Temperature (C): {temp}")
            print(f"Humidity (%): {hum}")
            print(f"Pressure (mb): {pres}")
            print(f"Weather description: {desc}")

            if temp is not None:
                temperature_gauge.set(temp)
            if hum is not None:
                humidity_gauge.set(hum)
            if pres is not None:
                pressure_gauge.set(pres)
        else:
            print("Current conditions not found.")
    except Exception as e:
        print(f"Error fetching weather data: {e}")

if __name__ == "__main__":
    start_http_server(PROMETHEUS_PORT)
    print(f"Prometheus metrics available at :{PROMETHEUS_PORT}/metrics")
    while True:
        fetch_weather()
        time.sleep(FETCH_INTERVAL)