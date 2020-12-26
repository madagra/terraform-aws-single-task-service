import uvicorn
import requests
from fastapi import FastAPI


app = FastAPI()

namespace = "sample_app"
name = "backend"
ext_port = 8001
ext_service = "frontend"

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
        resp = requests.get(f"http://{ext_service}.{namespace}:{ext_port}")
        msg = f"Successful contact with {ext_service}: {resp.text}"
    except Exception as e:
        msg = f"Error contacting the {ext_service}: {e}"

    res = { "message": msg }
    return res

if __name__ == '__main__':
    try:
        uvicorn.run(app)
    except Exception as e:
        print(f"Some error occured: {e}")
        raise e