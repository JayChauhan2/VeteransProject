import os
import secrets
from flask import Flask, render_template, request, url_for, redirect

app = Flask(__name__)
app.config['SECRET_KEY'] = 'ab8fbbb4d79d4120031e203d83d298e0' 

secret_key = secrets.token_hex(16)
print(secret_key)

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

if __name__ == '__main__':
    app.run(debug=True)


