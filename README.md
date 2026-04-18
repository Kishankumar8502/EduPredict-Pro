# 🎓 EduPredict Pro

An AI-powered mobile application that predicts student performance and provides actionable academic insights using Machine Learning.

---

## 📱 App Overview

EduPredict Pro is a **smart academic assistant** that analyzes student data and predicts expected exam performance along with improvement insights.

It combines:

* 📊 Machine Learning predictions
* 📱 Flutter mobile interface
* 🌐 Cloud-based backend (Render)

---

## ✨ Key Features

### 🧾 Student Profile

* Age, CGPA, Attendance tracking
* Personalized student data storage

### 📚 Study Habits Analysis

* Study hours
* Sleep hours
* Daily learning patterns

### 📊 Academic Performance Input

* Subject scores (Math, Science, English)
* Overall academic indicators

### 🏫 Background Information

* Gender
* Parent education
* School type
* Travel time

### 🎯 Extracurricular Insights

* Activities participation
* Internet access
* Study method

---

## 🤖 AI Prediction System

* Predicts **Exam Score (0–100)**
* Shows:

  * Current Level
  * Potential Level
  * Improvement Potential
* Provides motivational feedback

---

## 📈 Analytics Dashboard

* 📊 Radar Chart Visualization
* Strength vs Weakness analysis
* Performance breakdown

---

## 🕘 History Tracking

* Stores previous predictions
* Displays trends over time
* Quick comparison of performance

---

## 👤 Profile Management

* User profile system
* Editable personal data
* Clean UI experience

---

## 🛠 Tech Stack

### 📱 Frontend

* Flutter (Dart)
* Material UI

### ⚙️ Backend

* Python
* Flask
* Scikit-learn
* NumPy, Pandas

### ☁️ Deployment

* Render (Cloud Hosting)

---

## 🔄 App Workflow

1. User enters academic & personal data
2. Flutter sends API request
3. Flask backend processes input
4. ML model predicts score
5. Response sent back
6. App displays:

   * Score
   * Insights
   * Analytics

---

## 🔌 Live Backend API

👉 Base URL:
https://edupredict-pro.onrender.com

👉 Endpoint:
POST /predict

---

## 📥 Sample Request

```json
{
  "study_hours": 4,
  "sleep_hours": 7,
  "attendance": 85,
  "cgpa": 7.0
}
```

---

## 📤 Sample Response

```json
{
  "success": true,
  "prediction": 61.8,
  "predicted_overall_score": 61.8
}
```

---

## ⚙️ Run Project Locally

### 🔹 Backend (Flask)

```bash
git clone https://github.com/YOUR_USERNAME/EduPredict-Pro.git
cd EduPredict-Pro/backend

pip install -r requirements.txt
python app.py
```

---

### 🔹 Flutter App (Step-by-Step)

```bash
cd edupredict_ai
```

### 1️⃣ Install dependencies

```bash
flutter pub get
```

### 2️⃣ Check connected devices

```bash
flutter devices
```

### 3️⃣ Run app on device/emulator

```bash
flutter run
```

---

### 📱 Important for Mobile Testing

If running backend locally:

✔ Replace API URL in `api_service.dart`:

```dart
http://YOUR_LOCAL_IP:5000/predict
```

Example:

```dart
http://192.168.1.5:5000/predict
```

❌ DO NOT use:

```
http://127.0.0.1:5000
```

---

### 🌐 For Production (Render)

Use:

```
https://edupredict-pro.onrender.com/predict
```

---

## 📱 Notes

* Ensure backend is running before app testing
* Keep API URL correct based on environment
* Internet connection required for deployed backend

---

## 💡 Future Enhancements

* Real dataset-based prediction
* AI study planner
* Performance tracking over time
* Personalized recommendations

---

## 👨‍💻 Author

Kishan Kumar
Engineering Student | AI/ML Developer

---

⭐ If you like this project, give it a star on GitHub!
