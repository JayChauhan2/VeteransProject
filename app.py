import os
import secrets
from groq import Groq
from flask import Flask, render_template, request, url_for, redirect, jsonify
from dotenv import load_dotenv
import traceback


load_dotenv()
client = Groq(
    api_key=os.getenv('groq_api_key')
)

app = Flask(__name__)
app.config['SECRET_KEY'] = 'ab8fbbb4d79d4120031e203d83d298e0' 

secret_key = secrets.token_hex(16)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat/')
def chat():
    return render_template('chat.html')

@app.route('/calendar')
def calendar():
    return render_template('calendar.html')

@app.route('/more')
def more():
    return render_template('more.html')

@app.route('/breathing')
def breathing():
    return render_template('breathing.html')

# repeats steps
def build_steps(base_steps, step_id):
    if step_id == 0:
        return base_steps[0], len(base_steps)

    repeat_steps = base_steps[1:] * 3
    all_steps = [base_steps[0]] + repeat_steps

    if step_id >= len(all_steps):
        return "Exercise complete!", len(all_steps)

    return all_steps[step_id], len(all_steps)


@app.route('/deep/')
@app.route('/deep/<int:step_id>')
def deep(step_id=0):
    steps = [
        'Sit Comfortably or lie down.',
        'Place one hand on your stomach and one hand on your chest.',
        "Breathe in slowly through your nose. Feel your stomach expand as you inhale.\n"
        "If you are breathing from the stomach, the hand on your chest shouldn't move. "
        "Focus on filling your lower lungs with air.",
        'Slowly exhale, releasing all the air through your mouth. Use your hand to feel your stomach fall as you exhale.'
    ]
    text, total = build_steps(steps, step_id)
    return render_template('deep.html', text=text, step_id=step_id, steps=steps, total=total)


@app.route('/box/')
@app.route('/box/<int:step_id>')
def box(step_id=0):
    steps = [
        'Find a comfortable seated or lying down position.',
        'Inhale slowly and deeply through your nose for a count of 4',
        'Hold your breath for a count of 4',
        'Exhale slowly and completely through your mouth for a count of 4',
        'Hold your breath again for a count of 4'
    ]
    text, total = build_steps(steps, step_id)
    return render_template('box.html', text=text, step_id=step_id, steps=steps, total=total)


@app.route('/winHof/')
@app.route('/winHof/<int:step_id>')
def winHof(step_id=0):
    steps = [
        'Start by sitting or lying down in a comfortable, quiet place where you won’t be disturbed.',
        'Inhale deeply through your nose, expanding your belly as you breathe in. '
        'Then exhale fully through your mouth. Repeat this cycle for 30-40 breaths.',
        'Breath Retention: After your last exhale, let the air out fully and hold your breath as long as you can.',
        'Relax and let your body adjust to the sensation.',
        'Inhale deeply and hold your breath for about 15 seconds before exhaling. This completes one round.'
    ]
    text, total = build_steps(steps, step_id)
    return render_template('winHof.html', text=text, step_id=step_id, steps=steps, total=total)


@app.route('/resources')
def resources():
    return render_template('resources.html')



@app.route("/getLLMResponse", methods=["POST"])
def getLLMResponse():
    try:
        inp = request.json["message"]
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
            {
                "role": "user",
                "content": "You are a trauma-informed virtual assistant designed to support veterans with PTSD. Always speak in a calm, respectful, and supportive tone. Prioritize emotional safety. Limit responses to 500 chars. " + inp
            }
            ],
            temperature=1,
            max_completion_tokens=1024,
            top_p=1,
            stream=False,
            stop=None
        )
        print("this: " + str(completion))
        return jsonify({
            "response": completion.choices[0].message.content
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": "Unable to load summary"}), 500


if __name__ == '__main__':
    app.run(debug=True, port=5001)