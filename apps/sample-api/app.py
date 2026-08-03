from flask import Flask, jsonify
import time
import os

app = Flask(__name__)

START_TIME = time.time()
VERSION = os.environ.get("APP_VERSION", "v1.0.0")


@app.route("/")
def home():
    return jsonify({
        "message": "Hello from the GitOps demo platform",
        "version": VERSION,
        "uptime_seconds": round(time.time() - START_TIME, 2),
    })


@app.route("/healthz")
def health():
    # Used by the Kubernetes liveness/readiness probes
    return jsonify({"status": "ok"}), 200


@app.route("/metrics")
def metrics():
    # Minimal Prometheus-compatible metrics endpoint.
    # Swap this for prometheus_client in a real build for proper histograms/counters.
    uptime = time.time() - START_TIME
    body = (
        "# HELP app_uptime_seconds Time since the app started\n"
        "# TYPE app_uptime_seconds counter\n"
        f"app_uptime_seconds {uptime}\n"
    )
    return body, 200, {"Content-Type": "text/plain"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
