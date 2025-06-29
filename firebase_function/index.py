
# index.py - Main Firebase Functions file
import logging
from firebase_functions import https_fn
# Setup minimal logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@https_fn.on_request(memory=1024, timeout_sec=300, region="us-central1")
def predict_image(request: https_fn.Request) -> https_fn.Response:
    """
    Simple health check function to test deployment
    """
    return https_fn.Response(
        '{"status": "healthy", "message": "Basic function deployed successfully"}',
        status=200,
        headers={
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
    )