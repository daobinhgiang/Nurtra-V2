# Scheduled Notifications

Daily notifications sent at **8am**, **12pm**, and **11:45pm EST** to all users.

## Deploy
```bash
cd functions && npm run deploy
```

## Quick Test
```bash
gcloud scheduler jobs run sendMorningNotifications --project=nurtra-75777
gcloud scheduler jobs run sendNoonNotifications --project=nurtra-75777
gcloud scheduler jobs run sendNightNotifications --project=nurtra-75777
```

## View Logs
```bash
firebase functions:log --only sendMorningNotifications,sendNoonNotifications,sendNightNotifications
```

**Logs show**: Start time (🌅/☀️/🌙) → User count → Per-user results → Summary (X sent, Y failed, Zms)

