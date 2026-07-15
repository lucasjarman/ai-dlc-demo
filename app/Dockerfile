FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Install Wiz Runtime Sensor (embedded mode for Cloud Run)
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -fsSL "https://downloads.wiz.io/sensor/latest/linux/amd64/wiz-sensor" -o /wiz-sensor && \
    chmod +x /wiz-sensor && \
    apt-get purge -y curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

# Wiz sensor wraps the app process — set WIZ_SENSOR_KEY at runtime
ENTRYPOINT ["/wiz-sensor", "--"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
