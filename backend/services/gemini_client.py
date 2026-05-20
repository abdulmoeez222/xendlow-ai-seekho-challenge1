import os
from google import genai

_client = None


def get_client():
    global _client
    if _client is None:
        api_key = os.getenv("GEMINI_API_KEY")
        if api_key:
            _client = genai.Client(api_key=api_key)
        else:
            _client = genai.Client(
                vertexai=True,
                project="ai-seekho-challenge",
                location="us-central1",
            )
    return _client


from google.genai import types

def generate(prompt: str, is_json: bool = False, temperature: float = 0.3) -> str:
    client = get_client()
    
    config_params = {
        "max_output_tokens": 8192,
        "temperature": temperature,
    }
    
    if is_json:
        config_params["response_mime_type"] = "application/json"
        
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
        config=types.GenerateContentConfig(**config_params)
    )
    return response.text
