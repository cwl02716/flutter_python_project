from flask import Flask, jsonify, request
from pymongo import MongoClient
from flask_cors import CORS
import openai

app = Flask(__name__)
CORS(app)

openai.api_key = "FREE_ENDPOINT"
openai.api_base = "https://free.churchless.tech/v1"

client = MongoClient("mongodb://localhost:27017/")
collection = client.chatbot.messages


class Message:
    def __init__(self, role: str, content: str) -> None:
        self.role = role
        self.content = content


@app.route('/prompt', methods=['POST'])
def prompt():
    prompt = request.get_json()['prompt']
    user_message = Message("user", prompt)

    print("User:", prompt)

    messages: list[Message] = list(collection.find())

    messages.append(user_message.__dict__)
    collection.insert_one(user_message.__dict__)

    for message in messages:
        message.pop('_id')

    chat_completion = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=messages,
        temperature=0.9,
    )

    openai_response = chat_completion.choices[0].message.content
    openai_message = Message(
        chat_completion.choices[0].message.role, openai_response)

    print("OpenAI:", openai_response)

    messages.append(openai_message.__dict__)
    collection.insert_one(openai_message.__dict__)

    return jsonify({'response': openai_response})


@app.route('/start', methods=['POST'])
def start():
    messages: list[Message] = list(collection.find())

    rule_message = Message("assistant", "從現在起你是一位說書人，你要生成一份遊戲背景與規則，你需要每次生成數個選項來與使用者互動，每個選項接戶導致不同的結局")
    messages.append(rule_message.__dict__)
    collection.insert_one(rule_message.__dict__)

    start_message = Message("user", "開始遊戲")
    messages.append(start_message.__dict__)
    collection.insert_one(start_message.__dict__)

    for message in messages:
        message.pop('_id')

    chat_completion = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=messages,
        temperature=0.9,
    )

    openai_response = chat_completion.choices[0].message.content
    openai_message = Message(
        chat_completion.choices[0].message.role, openai_response)

    print("OpenAI:", openai_response)

    messages.append(openai_message.__dict__)
    collection.insert_one(openai_message.__dict__)

    return jsonify({'response': openai_response})


@app.route('/reset', methods=['POST'])
def reset():
    collection.drop()
    return jsonify({'response': 'Chatbot reset'})


@app.route('/history', methods=['GET'])
def history():
    messages = list(collection.find())

    for message in messages:
        message.pop('_id')
        
    return jsonify({'messages': messages})


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=9999)
