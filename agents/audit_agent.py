from tinydb import TinyDB
db = TinyDB("memory/logs.json")

def audit():
    logs = db.all()
    if len(logs) == 0:
        return "No logs yet"
    return f"{len(logs)} events recorded"
