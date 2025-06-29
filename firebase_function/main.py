
# main.py
import logging
from firebase_functions import https_fn
import json

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create two functions to avoid initialization issues
@https_fn.on_request(memory=256, timeout_sec=60, region="us-central1")
def health_check(request: https_fn.Request) -> https_fn.Response:
    """Simple health check endpoint that doesn't load TensorFlow."""
    # CORS handling
    if request.method == "OPTIONS":
        return https_fn.Response(
            status=204,
            headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET",
                "Access-Control-Allow-Headers": "Content-Type",
            },
        )
        
    return https_fn.Response(
        json.dumps({
            "status": "healthy",
            "message": "Health check successful"
        }),
        headers={
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
    )

@https_fn.on_request(memory=1024, timeout_sec=300, region="us-central1")
def predict_image(request: https_fn.Request) -> https_fn.Response:
    """Function to handle image prediction - loads TensorFlow on demand."""
    
    # CORS handling
    if request.method == "OPTIONS":
        return https_fn.Response(
            status=204,
            headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST",
                "Access-Control-Allow-Headers": "Content-Type",
            },
        )
    
    try:
        import model
        if request.method == "POST":
            if "image" not in request.files:
                return https_fn.Response(
                    json.dumps({"error": "No image provided"}),
                    status=400,
                    headers={
                        "Content-Type": "application/json",
                        "Access-Control-Allow-Origin": "*",
                    },
                )

            image_file = request.files["image"]
            image_bytes = image_file.read()
            img_array = model.preprocess_image(image_bytes)
            result = model.predict(img_array)

            return https_fn.Response(
                json.dumps(result),
                headers={
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                },
            )
        else:
            return https_fn.Response(
                json.dumps({"error": "Method not allowed"}),
                status=405,
                headers={
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                },
            )
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return https_fn.Response(
            json.dumps({"error": str(e)}),
            status=500,
            headers={
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
        )