from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware

from server.services.video_stream import start_stream_capture

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    while True:
        data = await websocket.receive_bytes()
        object_names = start_stream_capture(data)
        await websocket.send_text(object_names)
