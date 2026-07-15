# Stage 1: Wiz Runtime Sensor (pulled from authenticated Wiz registry)
# Registry credentials come from: BWS wiz-registry-username / wiz-registry-password
# Build with: --secret id=wiz_reg_pass,env=WIZ_REGISTRY_PASS
# or pre-login: docker login wizio.azurecr.io -u <user> -p <pass>
FROM wizio.azurecr.io/sensor-serverless AS wiz-sensor

# Stage 2: Application image
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Copy Wiz Runtime Sensor binary from stage 1
COPY --from=wiz-sensor /opt/wiz/sensor /opt/wiz/sensor

EXPOSE 8080

# Sensor wraps the app process.
# At runtime, set WIZ_API_CLIENT_ID and WIZ_API_CLIENT_SECRET env vars
# (from a Wiz Service Account with type=Sensor).
ENTRYPOINT ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
