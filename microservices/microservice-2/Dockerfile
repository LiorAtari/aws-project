FROM python:3.9.20-alpine3.20

WORKDIR /app

COPY . .

RUN pip3 install -r requirements.txt

EXPOSE 8080

ENTRYPOINT ["python3", "app.py"]