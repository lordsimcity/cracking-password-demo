from flask import Flask, request, render_template_string

app = Flask(__name__)
VALID_USERNAME = "admin"
VALID_PASSWORD = "flask2023"
HTML_FORM = '''

<!DOCTYPE html>
<html><body>
<form method="POST" action="/login">
<input type="text" name="login" />
<input type="password" name="password" />
<input type="submit" value="Se connecter" />
</form>
{% if error %}
<p style="color:red">{{ error }}</p>
{% endif %}
</body></html>
'''


@app.route('/login', methods=['GET', 'POST'])
def login():
    error = ""
    if request.method == 'POST':
        login = request.form.get('login')
        password = request.form.get('password')
        if login == VALID_USERNAME and password == VALID_PASSWORD:
            return "Connexion réussie !"
        else:
            error = "Identifiant incorrect"
    return render_template_string(HTML_FORM, error=error)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
