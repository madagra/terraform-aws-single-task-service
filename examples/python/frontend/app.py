import os
import pika
import uvicorn
import requests
from fastapi import FastAPI


app = FastAPI()

port = os.environ.get("EXAMPLE_PORT", 8000)
protocol = os.environ.get("HTTP_PROTOCOL", "http")
namespace = os.environ.get("SAMPLE_NAMESPACE", "sample_app")
name = "frontend"

ext_port = os.environ.get("EXAMPLE_PORT_EXT", 8001)
ext_service = "backend"

@app.get("/")
async def root():
    res = { "message": f"Hello World from API {name}" }
    return res

@app.get("/health")
async def health_check():
    res = { "message": f"The {name} API is healthy" }
    return res

@app.get("/ping")
async def health_check():

    try:
        resp = requests.get(f"{protocol}://{ext_service}.{namespace}:{ext_port}")
        msg = f"Successful contact with {ext_service}: {resp.text}"
    except Exception as e:
        msg = f"Error contacting the {ext_service}: {e}"

    res = { "message": msg }
    return res

@app.get("/queue")
async def queue():

    connection = pika.BlockingConnection(pika.ConnectionParameters(host=f"queue.{namespace}"))
    if connection.is_open:
        msg = "Successful contact with message queue"
    else:
        msg = "Error contacting message queue"

    res = { "message": msg }
    return res


if __name__ == '__main__':
    try:
        uvicorn.run(app, host="0.0.0.0", port=port)
    except Exception as e:
        print(f"Some error occured: {e}")
        raise e