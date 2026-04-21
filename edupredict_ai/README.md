# 🎓 EduPredict Pro

![Flutter](https://img.shields.io/badge/Frontend-Flutter-blue)
![Python](https://img.shields.io/badge/Backend-Flask-green)
![ML](https://img.shields.io/badge/MachineLearning-ScikitLearn-orange)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success)

An AI-powered mobile application that predicts student performance and provides actionable academic insights using Machine Learning.

---

## 📱 App Overview

EduPredict Pro is a **smart academic assistant** that analyzes student data and predicts expected exam performance along with improvement insights.

It integrates:

* 📊 Machine Learning model trained on real dataset
* 📱 Flutter mobile application
* 🌐 Cloud backend (Render)

---

## ✨ Key Features

### 🧾 Student Profile

* Age, CGPA, Attendance tracking
* Auto-filled user data

### 📚 Study Analysis

* Study hours tracking
* Learning pattern analysis

### 📊 Academic Inputs

* Subject scores (Math, Science, English)
* Overall academic indicators

### 🏫 Background Data

* Gender
* Parent education
* School type
* Travel time

### 🎯 Extracurricular Factors

* Activities participation
* Internet access
* Study method

---

## 🤖 AI Prediction System

* Predicts **Exam Score (0–100)**
* Uses **real dataset (~25,000 records from Kaggle)**
* Includes preprocessing pipeline:

  * OneHot Encoding
  * Feature Scaling

### 📌 Output:

* Predicted Score
* Performance Level
* Improvement Potential

---

## 📊 Model Performance

* **R² Score:** ~0.97
* **RMSE:** ~3.0

👉 Indicates high accuracy on real-world student data.

---

## 📈 Analytics Dashboard

* 📊 Radar Chart visualization
* Strength vs Weakness analysis
* Performance breakdown
* Ideal vs Current comparison

---

## 🔄 Smart UI Features

* 🔁 Manual Refresh buttons:

  * Radar Analysis
  * History Screen
* 📊 Real-time data updates
* 📌 Reference comparison system

---

## 🕘 History Tracking

* Stores previous predictions
* Displays trends over time
* Refresh-enabled updates

---

## 👤 Profile Management

* Editable profile
* Auto-filled prediction inputs
* Clean user interface

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

* Render

---

## 🔄 App Workflow

1. User enters data
2. Flutter sends API request
3. Flask processes input
4. ML model predicts score
5. Response returned
6. App displays results

---

## 🔌 Live API

👉 https://edupredict-pro.onrender.com

Endpoint:

```
POST /predict
```

---

## 📥 Sample Request

```json
{
  "study_hours": 6,
  "attendance": 85,
  "cgpa": 8,
  "age": 16,
  "gender": "male",
  "school_type": "public",
  "parent_education": "high school",
  "internet_access": "yes",
  "travel_time": "15-30 min",
  "extra_activities": "no",
  "study_method": "notes",
  "math_score": 70,
  "science_score": 75,
  "english_score": 72
}
```

---

## 📤 Sample Response

```json
{
  "success": true,
  "prediction": 83.5,
  "predicted_overall_score": 83.5,
  "level": "Good",
  "improvement": "+16.5 marks possible"
}
```

---

## ⚙️ Run Locally

### 🔹 Backend

```
git clone https://github.com/YOUR_USERNAME/EduPredict-Pro.git
cd EduPredict-Pro/backend

pip install -r requirements.txt
python ml_pipeline.py
python app.py
```

---

### 🔹 Flutter

```
cd edupredict_ai

flutter pub get
flutter devices
flutter run
```

---

## 📱 Mobile Testing

### Local Backend

```
http://YOUR_LOCAL_IP:5000/predict
```

❌ Do NOT use:

```
http://127.0.0.1:5000
```

---

### Production

```
https://edupredict-pro.onrender.com/predict
```

---

## 📸 Screenshots (Add yours)

| Home                 | Analytics                 | History                 |
| -------------------- | ------------------------- | ----------------------- |
| ![](assets/home.png) | ![](assets/analytics.png) | ![](assets/history.png) |

---

## 📱 Notes

* Backend must be running for local testing
* Use correct API URL
* Internet required for deployed backend
* First request may be slow (Render free tier)

---

## 💡 Future Scope

* AI Study Planner
* Personalized recommendations
* Performance tracking
* Advanced analytics

---

## 👨‍💻 Author

**Kishan Kumar**
Engineering Student | AI/ML Developer

---

⭐ Star this repo if you like it!
