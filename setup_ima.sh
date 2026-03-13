#!/data/data/com.termux/files/usr/bin/bash

echo "Installing dependencies..."
pkg update -y
pkg install python git -y

pip install --upgrade pip
pip install gradio tinydb requests

echo "Creating project structure..."

mkdir -p ima/agents
mkdir -p ima/memory
mkdir -p ima/ui

cd ima

# צור קובץ דרישות
cat > requirements.txt << 'EOF'
gradio
tinydb
requests
EOF

# צור קובץ הראשי של Ima
cat > ima.py << 'EOF'
import gradio as gr
from tinydb import TinyDB
import datetime
import os

DB_PATH = "memory/logs.json"

if not os.path.exists("memory"):
    os.makedirs("memory")

db = TinyDB(DB_PATH)

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
    title="Ima"
)

interface.launch(server_name="0.0.0.0", server_port=7860)
EOF

# צור סקריפטים ראשוניים לסוכנים
cat > agents/audit_agent.py << 'EOF'
from tinydb import TinyDB

db = TinyDB("memory/logs.json")

def audit():
    logs = db.all()
    if len(logs) == 0:
        return "No logs yet"
    return f"{len(logs)} events recorded"
EOF

cat > agents/data_agent.py << 'EOF'
from tinydb import TinyDB

db = TinyDB("memory/logs.json")

def data_status():
    return len(db)
EOF

cat > agents/code_agent.py << 'EOF'
def review():
    return "Code review placeholder"
EOF

cat > agents/product_agent.py << 'EOF'
def evaluate():
    return "Product analysis placeholder"
EOF

echo "Setup complete."
echo "Run Ima with:"
echo "cd ~/ima/ima"
echo "python ima.py"
