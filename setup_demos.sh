#!/bin/bash

echo "[*] Installation des outils nécessaires..."
sudo apt update
sudo apt install -y hashcat hydra whois docker.io docker-compose john

echo "[*] Création des fichiers de démonstration..."

# Scénario 2 - Mots de passe faibles vs forts

echo -n "&#1500;&#1493;&#1500;&#1497;" | sha256sum | awk '{print $1}' > weak.txt
echo -n "9gV$LkW#q!@7mDz" | sha256sum | awk '{print $1}' > strong.txt
echo -e "azerty123\n9gV$LkW#q!@7mDz\npassword\n12345678" > dict.txt

# Scénario 3 - Mutation avec des règles
echo -n "John0100" | md5sum | awk '{print $1}' > rule_test.txt
echo -n "John0100!" | md5sum | awk '{print $1}' > rule_test2.txt
echo -n "J0hn0100!" | md5sum | awk '{print $1}' > rule_test3.txt

# Scénario 4 - Hash salé vs non salé

echo -n ')$@!#*@**$bb' | sha256sum | awk '{print $1}' > nosalt.txt
mkpasswd -m sha-256 ')$@!#*@**$bb' > salted.txt

# Scénario 5 - Brute force ciblé
echo -n "John1." | md5sum | awk '{print $1}' > structured.txt

# Scénario 6 - Combinaison de dictionnaires

echo -e "kylian\nvalerie\nalexandre" > noms.txt
echo -e "2023\n2024\n2025" > annees.txt
echo -n "kylian2023" | md5sum | awk '{print $1}' > combo.txt

# Scénario 7 - Règles personnalisées

echo -n "Fsociety2025!" | sha1sum | awk '{print $1}' > entreprise.txt
echo -e "fsociety" > entreprise_dict.txt
echo -e '$2$0$2$5$!c' > entreprise.rule

# Scénario 8 - Brute force web (Flask)

echo "[*] Mise en place du serveur Flask..."
mkdir -p flask_bruteforce_demo && cd flask_bruteforce_demo

cat <<EOF > app.py
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
EOF

cat <<EOF > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app.py .
RUN pip install flask
EXPOSE 5000
CMD ["python", "app.py"]
EOF

cat <<EOF > docker-compose.yml
version: '3'
services:
  flaskapp:
    build: .
    ports:
      - "5000:5000"
    container_name: flask_demo
EOF

echo "admin" > users.txt
echo -e "admin\nadmin123\nflask2023" > passwords.txt

echo "[*] Installation terminée. Prêt pour la démonstration."

