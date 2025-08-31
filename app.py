import os
import secrets
from groq import Groq
from flask import Flask, render_template, request, url_for, redirect
from dotenv import load_dotenv

load_dotenv()
client = Groq(
    api_key=os.getenv('groq_api_key')
)

app = Flask(__name__)
app.config['SECRET_KEY'] = 'ab8fbbb4d79d4120031e203d83d298e0' 

secret_key = secrets.token_hex(16)
# print(secret_key)

# Home page route
@app.route('/')
def index():
    return render_template('index.html')

# Chat page route
@app.route('/chat/')
def chat():
    return render_template('chat.html')

# Calendar page route
@app.route('/calendar')
def calendar():
    return render_template('calendar.html')

# More options page route
@app.route('/more')
def more():
    return render_template('more.html')

# Breathing exercises page route
@app.route('/breathing')
def breathing():
    return render_template('breathing.html')

@app.route('/breathing/box')
def box():
    return render_template('breathing.html')

@app.route('/breathing/deep')
def deep():
    return render_template('breathing.html')

@app.route('/breathing/winHof')
def winHof():
    return render_template('breathing.html')

@app.route('/breathing/resources')
def resources():
    return render_template('resourcehotline.html')

if __name__ == '__main__':
    app.run(debug=True)



def createLLMResponse(inp):
    try:
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
            {
                "role": "user",
                "content": "You are a trauma-informed virtual assistant designed to support veterans with PTSD. Always speak in a calm, respectful, and supportive tone. Prioritize emotional safety." + inp
            }
            ],
            temperature=1,
            max_completion_tokens=1024,
            top_p=1,
            stream=false,
            stop=None
        )
        return completion.choices[0].message
    except:
        return "Unable to load summary"
