# Démonstrations — Craquage de mots de passe

Ce projet présente 8 scénarios afin de comprendre les différentes méthodes de craquage de mot de passe.
Il est possible d'utiliser le script `setup_demos.sh` pour installer les outils nécessaires et générer (ou modifier) les fichiers.

---

## Scénario 1 — Comparaison de vitesse entre algorithmes

### Objectif  

Comparer la vitesse des algorithmes de hachage pour comprendre leur résistance aux attaques.

- **Tous les algorithmes ne se valent pas**.
- **Plus un hash est rapide**, plus il est **dangereux** dans un contexte de sécurité.

### Commandes

```bash
hashcat -b -m 0       # MD5
hashcat (v6.2.5) starting in benchmark mode

-------------------
* Hash-Mode 0 (MD5)
-------------------

Speed.#1.........: 81893.9 kH/s (5.74ms) @ Accel:256 Loops:1024 Thr:1 Vec:8

```

| Élément      | Signification                                                |
| ------------ | ------------------------------------------------------------ |
| Speed.#1     | Résultat pour le device #1                                   |
| 81893.9 kH/s | = **81,893,900 hashs/seconde** (≈ 81,9 millions de tests de mot de passe par seconde) |
| (5.74ms)     | Temps d’exécution du bloc de benchmark                       |



```bash
hashcat -b -m 1800    # SHA-512 crypt (Linux)
hashcat (v6.2.5) starting in benchmark mode

--------------------------------------------------------------------
* Hash-Mode 1800 (sha512crypt $6$, SHA512 (Unix)) [Iterations: 5000]
--------------------------------------------------------------------

Speed.#1.........:      791 H/s (63.92ms) @ Accel:256 Loops:1024 Thr:1 Vec:4

```

Il effectue **5000 itérations SHA-512** (par défaut), ce qui le rend **bien plus lent** que SHA-512 simple.

| Élément      | Signification                          |
| ------------ | -------------------------------------- |
| Speed.#1     | Résultat pour le device #1             |
| 791 kH/s     | = **791 hashs/seconde**                |
| (63.92ms)    | Temps d’exécution du bloc de benchmark |

Exemple :

> Si un mot de passe est composé de **8 caractères alphanumériques** (≈ 2.8 milliards combinaisons) :

- Avec MD5 :
   `2.8e9 / 81e6 ≈ 35 secondes`
- Avec SHA-512 crypt :
   `2.8e9 / 791 ≈ 41 jours`

Les itérations sont comme une **armure mathématique** : elles ne rendent pas un mot de passe plus fort en soi, mais elles rendent chaque tentative **plus lente** à exécuter. Et dans un contexte de brute force, **ralentir = gagner du temps = augmenter la sécurité**.

```bash
hashcat -b -m 3200    # bcrypt
(v6.2.5) starting in benchmark mode
----------------------------------------------------------------
* Hash-Mode 3200 (bcrypt $2*$, Blowfish (Unix)) [Iterations: 32]
----------------------------------------------------------------

Speed.#1.........:        5 H/s (4.00ms) @ Accel:2 Loops:32 Thr:1 Vec:1

```

| Élément      | Signification                          |
| ------------ | -------------------------------------- |
| Speed.#1     | Résultat pour le device #1             |
| 5 H/s        | = **5 hashs/seconde**                  |
| (4.00ms)     | Temps d’exécution du bloc de benchmark |

bcrypt est lent non pas parce qu’il fait beaucoup d’itérations, mais parce que **chaque itération est lourde en calcul et en mémoire.**
C’est conçu ainsi pour **empêcher les attaques GPU massives**.
Même un attaquant avec une machine puissante ne peut tester que quelques mots de passe par seconde.

---

## Scénario 2 — Mots de passe faibles vs forts

### Objectif  

Illustrer la vulnérabilité des mots de passe simples face à un dictionnaire.

### Commandes

```bash
hashcat -m 1400 weak.txt dict.txt --force
hashcat -m 1400 strong.txt dict.txt --force
```

---

## Scénario 3 — Mutation avec des règles

### Objectif  

Tester automatiquement avec des variantes.

### Commandes

```bash
#création d'un fichier personnalisé
git clone https://github.com/Mebus/cupp.git
cd cupp
python3 cupp.py -i

#en se basant sur le fichier généré
hashcat -m 0 rule_test.txt cupp/john.txt --force

#en ajoutant des règles
hashcat -m 0 rule_test2.txt cupp/john.txt -r rules/custom.rule --force

#en ajoutant un ensemble de règles
hashcat -m 0 rule_test3.txt cupp/john.txt -r rules/oneinall.rule --force
```

---

## Scénario 4 — Hash salé vs non salé

### Objectif  

Comparer la résistance de deux hashs du même mot de passe, avec et sans sel.

### Commandes

```bash
hashcat -m 1400 nosalt.txt dict.txt --force
hashcat -m 1400 salted.txt dict.txt --force
hashcat -m 7400 salted.txt dict.txt --force
```

---

## Scénario 5 — Brute force ciblé (structure connue)

### Objectif  

Exploiter une structure prédictible de mot de passe (ex : prénom, chiffre, symbole).

### Commande

```bash
hashcat -m 0 -a 3 structured.txt ?u?l?l?l?d?s --force
```

---

## Scénario 6 — Combinaison de dictionnaires

### Objectif  

Assembler deux sources d’information pour deviner un mot de passe.

### Commande

```bash
hashcat -m 0 -a 1 combo.txt noms.txt annees.txt --force
```

---

## Scénario 7 — Attaque contextuelle avec règles personnalisées

### Objectif  

Tirer parti d’informations sur l’entreprise pour créer une attaque ciblée.

### Commande

```bash
hashcat -m 100 entreprise.txt entreprise_dict.txt -r entreprise.rule --force
```

---

## Scénario 8 — Brute force Web (Hydra + Flask)

### Objectif  

Simuler une attaque web automatisée sur un formulaire vulnérable.

### Commandes

```bash
cd flask_bruteforce_demo
sudo docker-compose up --build
```

Puis dans un autre terminal :

```bash
hydra -L users.txt -P passwords.txt -s 5000 localhost http-post-form "/login:login=^USER^&password=^PASS^:Identifiant incorrect"
```

