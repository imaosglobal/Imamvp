import gradio as gr
from tinydb import TinyDB
import datetime
import os

openai_api_key = os.getenv("OPENAI_API_KEY")
if not openai_api_key:
    print("⚠️ צריך לשים את OPENAI_API_KEY כמשתנה סביבה")
db = TinyDB("memory/logs.json")

class Ima:
    def __init__(self):
        self.name = "Ima"

    def log(self, event):
        db.insert({
            "time": str(datetime.datetime.now()),
            "event": event
        })

    def self_diagnose(self):
        issues = []
        if len(db) == 0:
            issues.append("No data collected yet")
        return issues

    def learn(self):
        issues = self.self_diagnose()
        if issues:
            self.log({"learning": issues})

    def reply(self, message):
        self.log({"user": message})
        self.learn()
        response = f"Ima heard: {message}"
        self.log({"ima": response})
        return response

ima = Ima()

def chat(message):
    return ima.reply(message)

interface = gr.Interface(
    fn=chat,
    inputs="text",
    outputs="text",
    title="Ima – MVP"
)

interface.launch(server_name="0.0.0.0", server_port=7860)
