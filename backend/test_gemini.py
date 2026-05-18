from dotenv import load_dotenv
load_dotenv()

from services.gemini_client import generate
import json

prompt = """
Return exactly:
{
  "test": "success"
}
"""

try:
    print("Testing Gemini...")
    res = generate(prompt)
    print("Response:", res)
except Exception as e:
    print("Gemini Error:", e)
