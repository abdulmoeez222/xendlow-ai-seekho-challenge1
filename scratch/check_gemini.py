import os
import sys
from dotenv import load_dotenv

# Add backend directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))
load_dotenv(os.path.join(os.path.dirname(__file__), '..', 'backend', '.env'))

log_file = os.path.join(os.path.dirname(__file__), 'gemini_status.txt')

def log(msg):
    print(msg)
    with open(log_file, "a") as f:
        f.write(msg + "\n")

# Clear status file
with open(log_file, "w") as f:
    f.write("=== GEMINI SDK TEST ===\n")

log("Starting Gemini diagnosis...")
log(f"GEMINI_API_KEY exists: {os.getenv('GEMINI_API_KEY') is not None}")
if os.getenv('GEMINI_API_KEY'):
    log(f"GEMINI_API_KEY length: {len(os.getenv('GEMINI_API_KEY'))}")
    log(f"GEMINI_API_KEY starts with: {os.getenv('GEMINI_API_KEY')[:8]}...")

try:
    log("Importing google.genai...")
    from google import genai
    from google.genai import types
    log("Import successful!")
except Exception as e:
    log(f"Import failed: {e}")
    import traceback
    log(traceback.format_exc())
    sys.exit(1)

try:
    log("Initializing genai.Client...")
    api_key = os.getenv("GEMINI_API_KEY")
    if api_key:
        client = genai.Client(api_key=api_key)
        log("Client initialized with API Key.")
    else:
        client = genai.Client(
            vertexai=True,
            project="ai-seekho-challenge",
            location="us-central1",
        )
        log("Client initialized with Vertex AI.")
except Exception as e:
    log(f"Client initialization failed: {e}")
    import traceback
    log(traceback.format_exc())
    sys.exit(1)

try:
    log("Calling generate_content with 'gemini-2.5-flash'...")
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents="Hi, say 'Gemini is working!' if you receive this.",
    )
    log("Generate content successful!")
    log(f"Response text: {response.text}")
except Exception as e:
    log(f"Generate content failed: {e}")
    import traceback
    log(traceback.format_exc())
