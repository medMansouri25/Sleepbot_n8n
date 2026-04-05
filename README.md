# Sleep Tracker - Bot Telegram avec n8n

Bot Telegram de suivi du sommeil construit avec **n8n**. Il permet d'enregistrer ses heures de coucher et de reveil, calcule la duree de sommeil, et fournit des statistiques avec graphiques.

## Fonctionnalites

- **Enregistrement du coucher** : `dors HH:MM` (ex: `dors 23:30`)
- **Enregistrement du reveil** : `reveil HH:MM` (ex: `reveil 07:15`)
- **Statistiques** : `stats` — moyennes (semaine, mois, 6 mois), meilleure/pire nuit, graphiques

### Graphiques

La commande `stats` envoie deux graphiques generes via QuickChart :
- Historique journalier des 30 derniers jours (barres)
- Evolution des moyennes hebdomadaires sur 6 mois (courbe)

### Evaluation du sommeil

| Duree       | Evaluation                         |
|-------------|------------------------------------|
| >= 8h       | Excellente nuit !                  |
| >= 7h       | Bonne nuit !                       |
| >= 6h       | Correct, mais essaie de dormir plus |
| < 6h        | Insuffisant !                      |

## Pre-requis

- [Node.js](https://nodejs.org)
- [n8n](https://n8n.io) (`npm install -g n8n`)
- [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/) (pour exposer le webhook Telegram)
- Un bot Telegram (cree via [@BotFather](https://t.me/BotFather))

## Installation

1. Cloner le projet
2. Configurer les credentials Telegram dans n8n (token du bot)
3. Importer le workflow dans n8n :
   - `sleep_tracker_simple.json` — version sans credentials (a configurer manuellement)
   - `sleep_tracker_telegram.json` — version avec placeholders de credentials

## Lancement

Double-cliquer sur `start_n8n.bat` ou l'executer dans un terminal :

```bash
start_n8n.bat
```

Le script :
1. Verifie que Node.js et n8n sont installes
2. Lance un tunnel Cloudflare (URL publique temporaire)
3. Demarre n8n avec l'URL webhook du tunnel

L'URL du tunnel s'affiche dans la console — elle sert de webhook URL pour le bot Telegram.

## Architecture du workflow

```
Telegram Trigger
  -> Parser Message (detection commande + extraction heure)
    -> Est-ce "dors" ?
      -> Oui : Enregistrer Coucher -> Repondre confirmation
      -> Non : Est-ce "reveil" ?
        -> Oui : Calculer Sommeil -> Repondre resume
        -> Non : Est-ce "stats" ?
          -> Oui : Generer Stats -> Texte + Graphe Jours + Graphe Semaines
          -> Non : Repondre Aide
```

## Fichiers

| Fichier                        | Description                                      |
|--------------------------------|--------------------------------------------------|
| `sleep_tracker_simple.json`    | Workflow n8n (sans credentials)                   |
| `sleep_tracker_telegram.json`  | Workflow n8n (avec placeholders credentials)       |
| `start_n8n.bat`               | Script de lancement n8n + tunnel Cloudflare        |
| `cloudflared.log`             | Log du tunnel Cloudflare (genere au lancement)     |
