#!/usr/bin/env python3
"""AI MCP Server - Exposes Gemini and Ollama via Model Context Protocol."""

import os
import json
import base64
import httpx
from pathlib import Path
from abc import ABC, abstractmethod

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent


# Abstract provider interface
class AIProvider(ABC):
    @abstractmethod
    async def chat(self, prompt: str, model: str | None = None) -> str:
        pass

    @abstractmethod
    async def code(self, prompt: str, language: str | None = None) -> str:
        pass

    @abstractmethod
    async def vision(self, prompt: str, image_path: Path) -> str:
        pass

    @abstractmethod
    async def embed(self, text: str) -> list[float]:
        pass


class OllamaProvider(AIProvider):
    def __init__(self, base_url: str = "http://localhost:11434"):
        self.base_url = base_url
        self.default_model = os.environ.get("OLLAMA_MODEL", "llama3")
        self.vision_model = os.environ.get("OLLAMA_VISION_MODEL", "llava")

    async def _generate(self, prompt: str, model: str, images: list[str] | None = None) -> str:
        async with httpx.AsyncClient(timeout=120.0) as client:
            payload = {
                "model": model,
                "prompt": prompt,
                "stream": False,
            }
            if images:
                payload["images"] = images

            response = await client.post(f"{self.base_url}/api/generate", json=payload)
            response.raise_for_status()
            return response.json()["response"]

    async def chat(self, prompt: str, model: str | None = None) -> str:
        return await self._generate(prompt, model or self.default_model)

    async def code(self, prompt: str, language: str | None = None) -> str:
        lang_hint = f" in {language}" if language else ""
        full_prompt = f"You are an expert programmer. {prompt}{lang_hint}\n\nProvide clean, well-commented code."
        return await self._generate(full_prompt, self.default_model)

    async def vision(self, prompt: str, image_path: Path) -> str:
        with open(image_path, "rb") as f:
            image_b64 = base64.b64encode(f.read()).decode("utf-8")
        return await self._generate(prompt, self.vision_model, images=[image_b64])

    async def embed(self, text: str) -> list[float]:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                f"{self.base_url}/api/embeddings",
                json={"model": self.default_model, "prompt": text}
            )
            response.raise_for_status()
            return response.json()["embedding"]


class GeminiProvider(AIProvider):
    def __init__(self):
        import google.generativeai as genai
        self.genai = genai
        self.chat_model = "gemini-2.0-flash"
        self.vision_model = "gemini-2.0-flash"
        self.embed_model = "text-embedding-004"

        api_key = os.environ.get("GEMINI_API_KEY")
        if api_key:
            genai.configure(api_key=api_key)
        else:
            raise ValueError("GEMINI_API_KEY required for Gemini provider")

    async def chat(self, prompt: str, model: str | None = None) -> str:
        model_obj = self.genai.GenerativeModel(model or self.chat_model)
        response = model_obj.generate_content(prompt)
        return response.text

    async def code(self, prompt: str, language: str | None = None) -> str:
        lang_hint = f" in {language}" if language else ""
        full_prompt = f"You are an expert programmer. {prompt}{lang_hint}\n\nProvide clean, well-commented code."
        model = self.genai.GenerativeModel(self.chat_model)
        response = model.generate_content(full_prompt)
        return response.text

    async def vision(self, prompt: str, image_path: Path) -> str:
        model = self.genai.GenerativeModel(self.vision_model)

        with open(image_path, "rb") as f:
            image_data = f.read()

        mime_type = "image/jpeg"
        suffix = image_path.suffix.lower()
        mime_map = {".png": "image/png", ".gif": "image/gif", ".webp": "image/webp"}
        mime_type = mime_map.get(suffix, mime_type)

        image_part = {
            "mime_type": mime_type,
            "data": base64.b64encode(image_data).decode("utf-8"),
        }
        response = model.generate_content([prompt, image_part])
        return response.text

    async def embed(self, text: str) -> list[float]:
        result = self.genai.embed_content(model=self.embed_model, content=text)
        return result["embedding"]


def get_provider() -> tuple[AIProvider, str]:
    """Get the best available AI provider."""
    # Try Gemini first
    if os.environ.get("GEMINI_API_KEY"):
        try:
            return GeminiProvider(), "gemini"
        except Exception:
            pass

    # Try Ollama
    try:
        import httpx
        response = httpx.get("http://localhost:11434/api/tags", timeout=2.0)
        if response.status_code == 200:
            return OllamaProvider(), "ollama"
    except Exception:
        pass

    # Default to Ollama (will fail gracefully if not running)
    return OllamaProvider(), "ollama"


# Initialize provider
provider, provider_name = get_provider()
server = Server("ai-mcp")


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="ai_chat",
            description=f"Send a prompt to AI ({provider_name}) and get a response",
            inputSchema={
                "type": "object",
                "properties": {
                    "prompt": {"type": "string", "description": "The prompt to send"},
                    "model": {"type": "string", "description": "Model to use (optional)"},
                },
                "required": ["prompt"],
            },
        ),
        Tool(
            name="ai_code",
            description=f"Generate or explain code using AI ({provider_name})",
            inputSchema={
                "type": "object",
                "properties": {
                    "prompt": {"type": "string", "description": "Code task description"},
                    "language": {"type": "string", "description": "Programming language (optional)"},
                },
                "required": ["prompt"],
            },
        ),
        Tool(
            name="ai_vision",
            description=f"Analyze an image with AI vision ({provider_name})",
            inputSchema={
                "type": "object",
                "properties": {
                    "prompt": {"type": "string", "description": "Question about the image"},
                    "image_path": {"type": "string", "description": "Path to the image file"},
                },
                "required": ["prompt", "image_path"],
            },
        ),
        Tool(
            name="ai_embed",
            description=f"Generate embeddings for text ({provider_name})",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {"type": "string", "description": "Text to embed"},
                },
                "required": ["text"],
            },
        ),
        Tool(
            name="ai_status",
            description="Check which AI provider is active",
            inputSchema={"type": "object", "properties": {}},
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    try:
        if name == "ai_chat":
            result = await provider.chat(arguments["prompt"], arguments.get("model"))
            return [TextContent(type="text", text=result)]

        elif name == "ai_code":
            result = await provider.code(arguments["prompt"], arguments.get("language"))
            return [TextContent(type="text", text=result)]

        elif name == "ai_vision":
            image_path = Path(arguments["image_path"]).expanduser().resolve()
            if not image_path.exists():
                return [TextContent(type="text", text=f"Error: Image not found: {image_path}")]
            result = await provider.vision(arguments["prompt"], image_path)
            return [TextContent(type="text", text=result)]

        elif name == "ai_embed":
            embedding = await provider.embed(arguments["text"])
            return [TextContent(
                type="text",
                text=json.dumps({"embedding": embedding, "dimensions": len(embedding)})
            )]

        elif name == "ai_status":
            return [TextContent(
                type="text",
                text=json.dumps({
                    "provider": provider_name,
                    "gemini_configured": bool(os.environ.get("GEMINI_API_KEY")),
                    "ollama_url": "http://localhost:11434" if provider_name == "ollama" else None,
                })
            )]

        else:
            return [TextContent(type="text", text=f"Unknown tool: {name}")]

    except Exception as e:
        return [TextContent(type="text", text=f"Error: {str(e)}")]


async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


if __name__ == "__main__":
    import asyncio
    print(f"Starting AI MCP Server with provider: {provider_name}", flush=True)
    asyncio.run(main())
