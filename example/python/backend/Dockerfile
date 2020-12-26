FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

EXPOSE 8000

CMD [ "uvicorn", "app:app", "--host", "0.0.0.0" ]
