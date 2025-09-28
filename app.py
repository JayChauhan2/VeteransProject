import os
import secrets
from groq import Groq
from flask import Flask, render_template, request, url_for, redirect, jsonify, session
from dotenv import load_dotenv
import traceback
import calendar
import datetime
import psycopg2
from werkzeug.security import generate_password_hash, check_password_hash

load_dotenv()
client = Groq(api_key=os.getenv('groq_api_key'))

app = Flask(__name__)
app.config['SECRET_KEY'] = 'ab8fbbb4d79d4120031e203d83d298e0'

secret_key = secrets.token_hex(16)

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )

# -------------------- Redirect root to login -------------------- #
@app.route('/')
def root():
    return redirect(url_for('login'))

# -------------------- Base Pages -------------------- #
@app.route('/index')
def index():
    return render_template('index.html')

@app.route('/chat/')
def chat():
    return render_template('chat.html')

@app.route('/more')
def more():
    return render_template('more.html')

@app.route('/breathing')
def breathing():
    return render_template('breathing.html')

@app.route('/resources')
def resources():
    return render_template('resources.html')

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


# -------------------- LLM Chat -------------------- #
@app.route("/getLLMResponse", methods=["POST"])
def getLLMResponse():
    try:
        inp = request.json["message"]
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{
                "role": "user",
                "content": "You are a trauma-informed virtual assistant designed to support veterans with PTSD. Always speak in a calm, respectful, and supportive tone. Prioritize emotional safety. Limit responses to 500 chars. " + inp
            }],
            temperature=1,
            max_completion_tokens=1024,
            top_p=1,
            stream=False,
            stop=None
        )
        return jsonify({"response": completion.choices[0].message.content})
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": "Unable to load summary"}), 500

# -------------------- Authentication -------------------- #
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        hashed_pw = generate_password_hash(password)
        
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO CACusers (username, email, password_hash) VALUES (%s, %s, %s)",
            (username, email, hashed_pw)
        )
        conn.commit()
        cur.close()
        conn.close()
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, password_hash, is_admin FROM CACusers WHERE username=%s", (username,))
        user = cur.fetchone()
        cur.close()
        conn.close()
        
        if user and check_password_hash(user[1], password):
            session['user_id'] = user[0]
            session['is_admin'] = user[2]
            session.pop('guest', None)
            return redirect(url_for('index'))
        else:
            return "Invalid credentials", 401
    return render_template('login.html')

@app.route('/guest_login')
def guest_login():
    session['guest'] = True
    session['user_id'] = None
    session['is_admin'] = False
    return redirect(url_for('index'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

# -------------------- Calendar -------------------- #
@app.route('/show_calendar_redirect')
def show_calendar_redirect():
    today = datetime.date.today()
    return redirect(url_for('show_calendar', year=today.year, month=today.month))

@app.route('/show_calendar/<int:year>/<int:month>/')
def show_calendar(year, month):
    today = datetime.date.today()
    cal = calendar.Calendar(firstweekday=6)
    month_days = cal.monthdatescalendar(year, month)

    selected_date_str = request.args.get('date', None)
    if selected_date_str:
        try:
            selected_date = datetime.datetime.strptime(selected_date_str, "%Y-%m-%d").date()
        except ValueError:
            selected_date = today
    else:
        selected_date = today

    events = []
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        if 'user_id' in session:
            user_id = session['user_id']
            cur.execute("""
                SELECT id, title, start_time, end_time, details, location, user_id
                FROM CACEvents
                WHERE date=%s AND (user_id=%s OR is_public=TRUE)
                ORDER BY start_time
            """, (selected_date, user_id))
        else:
            cur.execute("""
                SELECT id, title, start_time, end_time, details, location, user_id
                FROM CACEvents
                WHERE date=%s AND is_public=TRUE
                ORDER BY start_time
            """, (selected_date,))
        events = cur.fetchall()
        cur.close()
        conn.close()
    except:
        events = []

    return render_template(
        "calendar.html",
        year=year,
        month=month,
        month_days=month_days,
        today=today,
        selected_date=selected_date,
        events=events
    )

# -------------------- Event Routes -------------------- #
@app.route('/addevent/<date>/', methods=["GET", "POST"])
def add_event(date):
    if 'user_id' not in session:
        return redirect(url_for('login'))

    try:
        selected_date = datetime.datetime.strptime(date, "%Y-%m-%d").date()
    except ValueError:
        return "Invalid date", 400

    if request.method == "POST":
        title = request.form.get("title", "").strip()
        start_time = request.form.get("start_time", None)
        end_time = request.form.get("end_time", None)
        details = request.form.get("details", "").strip()
        location = request.form.get("location", "").strip()
        is_public = bool(request.form.get("is_public"))
        user_id = session.get('user_id')

        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO CACEvents (date, title, start_time, end_time, details, location, user_id, is_public)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (selected_date, title, start_time, end_time, details, location, user_id, is_public))
        conn.commit()
        cur.close()
        conn.close()

        return redirect(url_for("show_calendar", year=selected_date.year, month=selected_date.month, date=str(selected_date)))

    return render_template("addevent.html", date=selected_date)

@app.route('/edit_event/<int:event_id>/', methods=["GET", "POST"])
def edit_event(event_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT id, title, start_time, end_time, details, location, user_id, is_public, date
        FROM CACEvents
        WHERE id=%s
    """, (event_id,))
    row = cur.fetchone()

    if not row:
        cur.close()
        conn.close()
        return "Event not found", 404

    # Only owner or admin can edit
    if row[6] != session['user_id'] and not session.get('is_admin', False):
        cur.close()
        conn.close()
        return "Unauthorized", 403

    # Map row to dict
    event = {
        'id': row[0],
        'title': row[1],
        'start_time': row[2],
        'end_time': row[3],
        'details': row[4],
        'location': row[5],
        'user_id': row[6],
        'is_public': row[7],
        'date': row[8],
        'start_hour': row[2].hour if row[2] else 0,
        'start_minute': row[2].minute if row[2] else 0,
        'end_hour': row[3].hour if row[3] else 0,
        'end_minute': row[3].minute if row[3] else 0
    }

    if request.method == "POST":
        # Collect updated form values
        title = request.form.get("title", "").strip()
        start_hour = int(request.form.get("start_hour", 0))
        start_minute = int(request.form.get("start_minute", 0))
        end_hour = int(request.form.get("end_hour", 0))
        end_minute = int(request.form.get("end_minute", 0))
        details = request.form.get("details", "").strip()
        location = request.form.get("location", "").strip()
        is_public = bool(request.form.get("is_public"))

        # Rebuild time objects
        start_time = datetime.time(start_hour, start_minute)
        end_time = datetime.time(end_hour, end_minute)

        # Update DB
        cur.execute("""
            UPDATE CACEvents
            SET title=%s, start_time=%s, end_time=%s, details=%s, location=%s, is_public=%s
            WHERE id=%s
        """, (title, start_time, end_time, details, location, is_public, event_id))
        conn.commit()
        cur.close()
        conn.close()

        return redirect(url_for('show_calendar', year=event['date'].year, month=event['date'].month, date=event['date']))

    cur.close()
    conn.close()
    return render_template("edit_event.html", event=event)


@app.route('/delete_event/<int:id>/', methods=["POST"])
def delete_event(id):
    if 'user_id' not in session:
        return "Unauthorized", 403

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT user_id, date FROM CACEvents WHERE id=%s", (id,))
    event = cur.fetchone()
    if not event:
        cur.close()
        conn.close()
        return "Event not found", 404

    if event[0] != session['user_id'] and not session.get('is_admin', False):
        cur.close()
        conn.close()
        return "Unauthorized", 403

    cur.execute("DELETE FROM CACEvents WHERE id=%s", (id,))
    conn.commit()
    cur.close()
    conn.close()

    return redirect(url_for('show_calendar', year=event[1].year, month=event[1].month, date=event[1]))

# -------------------- Breathing Exercise Steps -------------------- #
def build_steps(base_steps, step_id):
    if step_id == 0:
        return base_steps[0], len(base_steps)
    repeat_steps = base_steps[1:] * 3
    all_steps = [base_steps[0]] + repeat_steps
    if step_id >= len(all_steps):
        return "Exercise complete!", len(all_steps)
    return all_steps[step_id], len(all_steps)

if __name__ == '__main__':
    app.run(debug=True, port=5001)
#pls work