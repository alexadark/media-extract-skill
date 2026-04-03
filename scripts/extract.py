#!/usr/bin/env python3
"""
Visual Analyzer - Extract structured knowledge from videos using Gemini's native video understanding.
Supports single video files and folders (batch mode).
"""

import argparse
import json
import os
import sys
import time
from pathlib import Path

# Load .env from skill directory
SKILL_DIR = Path(__file__).resolve().parent.parent
ENV_FILE = SKILL_DIR / ".env"
if ENV_FILE.exists():
    with open(ENV_FILE) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, _, value = line.partition("=")
                os.environ.setdefault(key.strip(), value.strip())

try:
    from google import genai
    from google.genai import types
except ImportError:
    print("Error: google-genai package not installed.")
    print("Install with: pip install google-genai")
    sys.exit(1)

VIDEO_EXTENSIONS = {".mp4", ".mov", ".avi", ".mkv", ".webm", ".m4v", ".flv"}

TECHNICAL_PROMPT = """You are analyzing a technical video. Extract ALL valuable information - both from what is spoken AND what is shown on screen. Be thorough and precise.

Structure your response EXACTLY as follows:

## Overview
- Main topic and purpose of this video
- Technologies/tools covered
- Skill level assumed (beginner/intermediate/advanced)

## Key Concepts
- Every concept explained, with clear definitions
- Mental models or frameworks presented

## Code & Commands
Transcribe EXACTLY what appears on screen:
- Terminal/shell commands (with flags and arguments)
- Code snippets (preserve language, indentation, comments)
- File paths and directory structures shown
- Configuration files or settings shown
- API calls, endpoints, request/response examples

Use fenced code blocks with the correct language identifier.

## Architecture & Design
- System diagrams or architecture shown/described
- Data flow patterns
- Component relationships
- Database schemas or data models

## Step-by-Step Procedures
Number each procedure clearly:
1. Prerequisites mentioned
2. Installation/setup steps
3. Implementation workflow
4. Testing/verification steps

## Tips & Gotchas
- Best practices explicitly mentioned
- Common mistakes or pitfalls warned about
- Performance considerations
- Security notes

## References
- Tools, libraries, frameworks mentioned (with versions if shown)
- URLs or documentation links shown or mentioned
- Related resources recommended

## Transcript
Provide the COMPLETE transcript of all spoken content. Include timestamps where possible (approximate is fine). Do not summarize - transcribe everything said."""

GENERAL_PROMPT = """You are analyzing a video. Extract ALL valuable information - both from what is spoken AND what is shown on screen. Be thorough.

Structure your response EXACTLY as follows:

## Overview
- Main topic and purpose
- Target audience
- Core message or thesis

## Main Points
- Every significant point made, with supporting arguments
- Evidence or examples presented
- Logical structure of the argument

## Key Insights
- Notable ideas or perspectives
- Actionable takeaways the viewer can apply
- Counterintuitive or surprising points

## Quotes
- Memorable or impactful statements (exact wording)
- Key definitions or explanations given

## Visual Content
- Slides or graphics shown (describe content)
- Demonstrations or examples shown on screen
- Charts, data, or statistics displayed

## Structure
- How the content is organized
- Main sections or chapters
- Transitions between topics

## References
- People, books, articles mentioned
- Tools, websites, resources referenced
- Recommendations made

## Transcript
Provide the COMPLETE transcript of all spoken content. Include timestamps where possible (approximate is fine). Do not summarize - transcribe everything said."""


def get_video_files(path: Path) -> list[Path]:
    """Get video files from a path (single file or folder)."""
    if path.is_file() and path.suffix.lower() in VIDEO_EXTENSIONS:
        return [path]
    elif path.is_dir():
        videos = []
        for f in path.rglob("*"):
            if f.suffix.lower() in VIDEO_EXTENSIONS and f.is_file():
                videos.append(f)
        return sorted(videos, key=lambda p: str(p))
    return []


def upload_and_wait(client: genai.Client, video_path: Path) -> object:
    """Upload video to Gemini File API and wait for processing."""
    print(f"  Uploading {video_path.name} ({video_path.stat().st_size / 1024 / 1024:.1f} MB)...")

    video_file = client.files.upload(file=video_path)

    max_wait = 600
    waited = 0
    while video_file.state.name == "PROCESSING" and waited < max_wait:
        time.sleep(10)
        waited += 10
        video_file = client.files.get(name=video_file.name)
        print(f"  Processing... ({waited}s)", end="\r")

    print()

    if video_file.state.name == "FAILED":
        raise ValueError(f"Video processing failed: {video_file.state.name}")

    if video_file.state.name == "PROCESSING":
        raise TimeoutError(f"Video still processing after {max_wait}s")

    return video_file


def analyze_video(client: genai.Client, video_file, prompt: str, model: str) -> str:
    """Analyze video with Gemini."""
    response = client.models.generate_content(
        model=model,
        contents=[
            types.Content(
                parts=[
                    types.Part.from_uri(
                        file_uri=video_file.uri,
                        mime_type=video_file.mime_type,
                    ),
                    types.Part.from_text(text=prompt),
                ]
            )
        ],
        config=types.GenerateContentConfig(
            temperature=0.2,
            max_output_tokens=65536,
        ),
    )
    return response.text


def cleanup_file(client: genai.Client, file_name: str):
    """Delete uploaded file from Gemini."""
    try:
        client.files.delete(name=file_name)
    except Exception:
        pass


def main():
    parser = argparse.ArgumentParser(
        description="Extract knowledge from videos using Gemini"
    )
    parser.add_argument("path", help="Path to a video file or folder containing videos")
    parser.add_argument(
        "--type",
        choices=["technical", "general"],
        default="technical",
        help="Content type (default: technical)",
    )
    parser.add_argument(
        "--output", help="Output file path (default: auto-generated)"
    )
    parser.add_argument(
        "--model",
        default="gemini-3.1-flash-lite-preview",
        help="Gemini model to use (default: gemini-3.1-flash-lite-preview)",
    )
    parser.add_argument(
        "--cleanup",
        action="store_true",
        help="Delete video files after analysis (for temp downloads)",
    )
    args = parser.parse_args()

    target = Path(args.path).resolve()
    if not target.exists():
        print(f"Error: Path does not exist: {target}")
        sys.exit(1)

    videos = get_video_files(target)
    if not videos:
        print(f"No video files found at {target}")
        print(f"Supported formats: {', '.join(sorted(VIDEO_EXTENSIONS))}")
        sys.exit(1)

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable not set")
        sys.exit(1)

    client = genai.Client(api_key=api_key)
    prompt = TECHNICAL_PROMPT if args.type == "technical" else GENERAL_PROMPT

    # Determine output path
    if args.output:
        output_path = Path(args.output)
    elif target.is_file():
        output_path = target.parent / f"visual-{target.stem}.md"
    else:
        output_path = target / f"intel-{target.name}.md"

    is_batch = len(videos) > 1
    print(f"Found {len(videos)} video(s)")
    print(f"Mode: {args.type} | Model: {args.model}")
    print(f"Output: {output_path}\n")

    results = []
    failures = []

    for i, video_path in enumerate(videos, 1):
        label = video_path.name if not is_batch else str(video_path.relative_to(target))
        print(f"[{i}/{len(videos)}] {label}")

        try:
            video_file = upload_and_wait(client, video_path)
            print(f"  Analyzing ({args.type} mode)...")

            content = analyze_video(client, video_file, prompt, args.model)
            results.append(
                {"filename": label, "index": i, "content": content}
            )

            cleanup_file(client, video_file.name)
            print(f"  Done.\n")

        except Exception as e:
            print(f"  ERROR: {e}\n")
            failures.append({"filename": label, "index": i, "error": str(e)})

        if i < len(videos):
            time.sleep(5)

    # Write output
    with open(output_path, "w") as f:
        if is_batch:
            folder_name = target.name if target.is_dir() else target.parent.name
            f.write(f"# Visual Analysis: {folder_name}\n\n")
        else:
            f.write(f"# Visual Analysis: {videos[0].stem}\n\n")

        f.write(f"**Type**: {args.type}  \n")
        f.write(f"**Model**: {args.model}  \n")
        f.write(f"**Videos processed**: {len(results)}/{len(videos)}  \n")
        if failures:
            f.write(
                f"**Failures**: {len(failures)} ({', '.join(x['filename'] for x in failures)})  \n"
            )
        f.write(f"**Generated**: {time.strftime('%Y-%m-%d %H:%M')}  \n\n")
        f.write("---\n\n")

        for result in results:
            if is_batch:
                f.write(f"# Video {result['index']}: {result['filename']}\n\n")
            f.write(result["content"])
            f.write("\n\n---\n\n")

        if failures:
            f.write("# Failures\n\n")
            for fail in failures:
                f.write(f"- **{fail['filename']}**: {fail['error']}\n")

    print(f"\nOutput saved to: {output_path}")
    print(f"Processed: {len(results)}/{len(videos)} videos")
    if failures:
        print(f"Failed: {len(failures)} videos")

    # Cleanup temp video files if requested
    if args.cleanup:
        print("\nCleaning up video files...")
        for v in videos:
            try:
                v.unlink()
                print(f"  Deleted: {v.name}")
            except Exception as e:
                print(f"  Failed to delete {v.name}: {e}")

    # Output result as JSON for programmatic use
    result_json = {
        "output_file": str(output_path),
        "videos_processed": len(results),
        "videos_failed": len(failures),
        "cleanup": args.cleanup,
    }
    print(f"\n__RESULT_JSON__:{json.dumps(result_json)}")


if __name__ == "__main__":
    main()
