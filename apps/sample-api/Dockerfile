FROM python:3.12-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV APP_VERSION=v1.0.0
EXPOSE 8080

RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]