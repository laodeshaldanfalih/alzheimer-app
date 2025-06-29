import os
import tempfile
import numpy as np
from PIL import Image
import tensorflow as tf
from io import BytesIO
import firebase_admin
from firebase_admin import credentials, storage
import traceback
import logging
import json

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global variables
MODEL_PATH = "models/model/prediction_model_3.tflite"
LABELS_PATH = "models/model/labels.txt"

# Cache
interpreter_cache = None
labels_cache = None
bucket = None

def get_bucket():
    """Get or initialize the Firebase Storage bucket."""
    global bucket
    if bucket is None:
        try:
            if not firebase_admin._apps:
                if os.path.exists("serviceAccountKey.json"):
                    cred = credentials.Certificate("serviceAccountKey.json")
                    firebase_admin.initialize_app(
                        cred, {"storageBucket": "medika-alzheimerapp.firebasestorage.app"}
                    )
                else:
                    firebase_admin.initialize_app(
                        options={"storageBucket": "medika-alzheimerapp.firebasestorage.app"}
                    )
            bucket = storage.bucket()
            logger.info("Firebase initialized successfully")
        except Exception as e:
            logger.error(f"Firebase initialization error: {str(e)}")
            traceback.print_exc()
    return bucket


def check_file_exists(path):
    """Check if a file exists in Firebase Storage."""
    bucket = get_bucket()
    try:
        return bucket.blob(path).exists()
    except Exception as e:
        logger.error(f"Error checking file: {str(e)}")
        return False


def download_file(path):
    """Download a file from Firebase Storage."""
    bucket = get_bucket()
    try:
        if not check_file_exists(path):
            logger.warning(f"File not found: {path}")
            blobs = list(bucket.list_blobs(prefix="models/"))
            logger.info("Available files:")
            for blob in blobs:
                logger.info(f" - {blob.name}")
            raise FileNotFoundError(f"File {path} not found in bucket")

        blob = bucket.blob(path)
        _, temp_path = tempfile.mkstemp()
        blob.download_to_filename(temp_path)
        logger.info(f"Downloaded to {temp_path}")
        return temp_path
    except Exception as e:
        logger.error(f"Download failed: {str(e)}")
        raise


def load_labels():
    """Load classification labels."""
    global labels_cache, LABELS_PATH
    if labels_cache:
        return labels_cache

    try:
        bucket = get_bucket()
        if not check_file_exists(LABELS_PATH):
            blobs = list(bucket.list_blobs(prefix="models/"))
            for b in blobs:
                if "label" in b.name.lower():
                    LABELS_PATH = b.name
                    logger.info(f"Using fallback label path: {LABELS_PATH}")
                    break

        blob = bucket.blob(LABELS_PATH)
        content = blob.download_as_string().decode("utf-8")
        labels = {}
        for line in content.strip().split("\n"):
            parts = line.strip().split(" ", 1)
            if len(parts) == 2:
                idx, label = parts
                labels[int(idx)] = label
        labels_cache = labels
        logger.info("Labels loaded.")
        return labels
    except Exception as e:
        logger.warning(f"Label load failed: {str(e)}")
        fallback = {
            0: "Gejala Ringan",
            1: "Gejala Sedang",
            2: "Tidak Gejala",
            3: "Gejala Sangat Ringan",
            4: "Bukan MRI Otak",
        }
        labels_cache = fallback
        logger.info("Using fallback labels.")
        return fallback


def load_interpreter():
    """Load the TensorFlow Lite interpreter."""
    global interpreter_cache, MODEL_PATH
    if interpreter_cache:
        return interpreter_cache

    try:
        bucket = get_bucket()
        if not check_file_exists(MODEL_PATH):
            blobs = list(bucket.list_blobs(prefix="models/"))
            for b in blobs:
                if "model" in b.name.lower() and b.name.endswith(".tflite"):
                    MODEL_PATH = b.name
                    logger.info(f"Using fallback model path: {MODEL_PATH}")
                    break

        model_path = download_file(MODEL_PATH)
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        interpreter_cache = interpreter
        logger.info("Model loaded.")
        return interpreter
    except Exception as e:
        logger.error(f"Model load failed: {str(e)}")
        raise


def preprocess_image(image_bytes):
    """Preprocess image for model input."""
    try:
        img = Image.open(BytesIO(image_bytes)).convert("RGB")
        img = img.resize((224, 224))
        arr = np.array(img, dtype=np.float32) / 255.0
        return np.expand_dims(arr, axis=0)
    except Exception as e:
        logger.error(f"Preprocessing error: {str(e)}")
        raise


def predict(image_array):
    """Run prediction on preprocessed image."""
    try:
        interpreter = load_interpreter()
        labels = load_labels()

        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()

        if input_details[0]["dtype"] == np.float32:
            image_array = image_array.astype(np.float32)

        interpreter.set_tensor(input_details[0]["index"], image_array)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]["index"])

        idx = int(np.argmax(output))
        conf = float(np.max(output))
        name = labels.get(idx, f"Class {idx}")

        logger.info(f"Prediction: {idx} - {name} ({conf:.2f})")
        return {"class_id": idx, "class_name": name, "confidence": conf}
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        return {
            "error": str(e),
            "class_id": -1,
            "class_name": "Unknown",
            "confidence": 0.0,
        }