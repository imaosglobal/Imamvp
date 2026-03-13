from tinydb import TinyDB
db = TinyDB("memory/logs.json")

def data_status():
    return len(db)
